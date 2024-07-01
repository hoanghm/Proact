'''
    Gemini API client. 
    - This class focuses on communications with the Gemini API and prompt engineering. 
    - It may use other tools (such as SearchClient) to enrich the prompts sent to the Gemini API. 
'''
import os
import json
import time
import logging.config
import google.api_core
from tenacity import retry, wait_fixed, stop_after_attempt

from attrs import define, field, NOTHING
from typing import List, Callable, Union

import google
import google.generativeai as genai

from SearchClient import SearchClient


GEMINI_MODEL:dict = {
    "flash": "gemini-1.5-flash" 
}


@define
class GeminiClient:
    
    # input params
    gemini_api_key: str = field(default=NOTHING, eq=False)
    tavily_api_key:str = field(default=None, eq=False)
    model: str = field(default="flash", eq=str.lower)
    tools: List[Callable] = field(factory=list)

    # internal
    logger: logging.Logger = field(init=False)
    client: Union[genai.GenerativeModel, None] = field(init=False) # original gemini client
    search_client: SearchClient = field(init=False)

    def __attrs_post_init__(self):
        ''' Run right after __init__() '''
        # initialize logger
        self.logger = logging.getLogger("proact.gemini_client")

        # initialize other clients
        if self.tavily_api_key is None:
            self.logger.warning("Tavily API Key not provided, internet search tool will not be available.")
        else:
            self.search_client = SearchClient(api_key=self.tavily_api_key)
            self.tools.append(self.internet_search_tool)
            self.logger.info("`Tavily search tool` appended to toolbox.")
        
        # initialize gemini client
        genai.configure(api_key=self.gemini_api_key)
        self.client = genai.GenerativeModel(
            model_name = GEMINI_MODEL[self.model],
            tools = self.tools # may be empty
        )
        self.logger.info("Gemini client initialized")
            

    def get_new_mission_for_user(
            self, 
            user_id:str, 
            num_missions:int = 3
        ) -> List[dict]:
        '''
        Get `num_missions` new missions for user with id `user_id`
        '''
        # hard coded for now, but can go to firestore to get these values
        personal_info = {
        'location': 'New York City',
        'occupation': 'College Student'
        }
        interests = [
            'Biking around the city',
            'Playing guitar'
        ]
        
        valid_missions_generated = False
        while not valid_missions_generated:
            # generate new missions
            new_missions_str = self._generate_new_missions(
                personal_info=personal_info,
                interests = interests,
                num_missions= num_missions
            )
            # Missions parsing check
            try:
                if '```json' in new_missions_str: # common error 
                    self.logger.warning("The prefix`'''json` encountered in the generated output, removing it...")    
                    new_missions_str = new_missions_str.replace('```json', '')
                new_missions = json.loads(new_missions_str) # Should be List[dict]
                valid_missions_generated = True
            except json.decoder.JSONDecodeError:
                self.logger.warning(f"Error parsing missions from type `{type(new_missions_str)}` to `List(dict)`.")
                self.logger.info("Regenrating missions...")

        self.logger.info(f"Successfully generated {len(new_missions)} missions.")
        self.logger.debug(f"Generated missions: \n {json.dumps(new_missions, indent=4)}")

        return new_missions
    

    @retry(wait=wait_fixed(2), stop=stop_after_attempt(3))
    def _submit_prompt(self, prompt:str) -> str:
        '''
        Submit a regular prompt to the Gemini API. Function calling is automatic but is implemented manually.
        '''
        self.logger.debug(f"Received prompt: {prompt}")
        start_time = time.perf_counter()
        
        # format message and send to gemini api
        messages = [
            {"role": "user", "parts": [prompt]}
        ]
        try:
            response = self.client.generate_content(messages)
            response_text = response.text
        except google.api_core.exceptions.InvalidArgument as e:# usually for invalid API key
            self.logger.error(f"Error occured when sending prompt to Gemini API: {e}")
            raise google.api_core.exceptions.InvalidArgument(e)
        
        # get elapsed time and log answer
        elapsed_time = time.perf_counter() - start_time
        self.logger.info(f"Answer generated in ({elapsed_time:.2f}s)")
        self.logger.debug(f"Answer: {response_text}")

        return response_text
    

    # TODO: Implement this function to use gemini ChatSession with automatic function calling
    @retry(wait=wait_fixed(2), stop=stop_after_attempt(3))
    def _submit_chat(self, msg:str) -> str:
        '''
        Initiate a chat session and send a chat to the Gemini API. Function calling is automatic by default.
        '''
        chat = self.client.start_chat(enable_automatic_function_calling=True)
        chat.send_message(msg)
        pass


    def _generate_new_missions(self, num_missions:int, personal_info:dict, interests:List[str]) -> str:
        # Info formatted as str
        personal_info_str = '\n'.join([f'- {k}: {v}' for k,v in personal_info.items()])
        interest_info_str = '\n'.join([f'- {item}' for item in interests])

        # Prompt template
        weekly_prompt = f'''
        Your goal is to suggest {num_missions} missions for me to do this week to help the environment and reduce global warming. 
        Each mission should ideally be personalized to my personal information and interests listed below. 

        Personal information:
        {personal_info_str}

        My Interests:
        {interest_info_str}

        These missions ideally should (in one or a few ways):
        - Are clear enough for me to keep track of my progress with.
        - Relate to my occupation. 
        - Relate to environmental problems that my location is known to have.
        - Relate to me personally, you can ask follow up questions about me if you want to know more about me. 
        
        Some hints for you about the steps to take:
        1. Do an internet search for environemntal problem near my location. 
        2. Determine the environemntal problems that I can make an impact in.
        3. Devise a set of missions for me to do with a clear description why the mission is important, is relevant (and perhaps even helpful) to me, and clear steps for me to take.  

        MAKE SURE to structure your answer in the following JSON format and do not add "```json" in the beginning:

        [   // a list of missions as json objects
            {{
                "Title": // the title of the mission
                "Description": // what this ,
                "Steps": [
                    // an array of steps as string
                ]
            }}
        ]
        '''

        # Submit prompt
        missions_str = self._submit_prompt(weekly_prompt)

        return missions_str
    

    # Gemini Tool 
    def internet_search_tool(self, query:str) -> str:
        '''
        Perform an internet search given a query. 
        
        Args:
            self: ignore this parameter
            query (str): A clear and concise query
        '''
        start_time = time.perf_counter()
        self.logger.info('Internet search requested with query: "{query}"')

        if not hasattr(self, 'search_client'):
            error_msg = 'Search client was not initialized'
            self.logger.error(error_msg)
            raise ValueError(error_msg)
        
        # just do a quick qna search for now
        result = self.search_client.quick_search(
            query=query, 
            search_depth='advanced'
        )

        # get elapsed time 
        elapsed_time = time.perf_counter() - start_time
        self.logger.info(f"Search result obtained ({elapsed_time:.2f}s)")
        self.logger.debug(f"Result: {result}")

        # make sure result is of type str
        if not isinstance(result, str):
            error_msg = f'Expect searchr result to be of type `str`, got `{type(result)}` instead.'
            self.logger.error(error_msg)
            raise ValueError(error_msg)
    
        return result


# test driver
if __name__ == "__main__":
    from dotenv import load_dotenv
    from utils import init_logging
    load_dotenv()
    init_logging()

    # Set the level of all loggers
    loggers = [logging.getLogger(name) for name in logging.root.manager.loggerDict]
    for logger in loggers:
        logger.setLevel(logging.DEBUG)

    # Initiate gemini client
    client = GeminiClient(
        gemini_api_key=os.getenv("GEMINI_API_KEY"),
        tavily_api_key=os.getenv("TAVILY_API_KEY")
    )
    
    # Try get some new missions
    client.get_new_mission_for_user("123")

    # client.logger.debug("This is a debug.")
    # client.logger.warning("This is a warning.")
    # client.logger.error("This is an error.")
    # client.logger.critical("This is critical.")