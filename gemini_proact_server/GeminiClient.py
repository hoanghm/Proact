'''
    Gemini API client. 
    - This class focuses on communications with the Gemini API and prompt engineering. 
    - It may use other tools (such as SearchClient) to enrich the prompts sent to the Gemini API. 
'''
import os
import json
import time
import logging.config
from tenacity import retry, wait_fixed, stop_after_attempt

from attrs import define, field, NOTHING
from typing import List, Callable, Union, Dict, Literal

import google
import google.generativeai as genai
from google.ai.generativelanguage_v1beta.types.content import FunctionCall
from google.protobuf.struct_pb2 import Struct

from SearchClient import SearchClient
from FirebaseClient import FirebaseClient


GEMINI_MODEL:dict = {
    "flash": "gemini-1.5-flash" 
}


@define
class GeminiClient:
    
    # input params
    gemini_api_key: str = field(default=NOTHING, eq=False)
    tavily_api_key:str = field(default=None, eq=False)
    model: str = field(default="flash", eq=str.lower)
    
    # internal
    logger: logging.Logger = field(init=False)
    client: Union[genai.GenerativeModel, None] = field(init=False) # original gemini client
    search_client: SearchClient = field(init=False)
    fb_client: FirebaseClient = field(init=False)
    tools: List[Callable] = field(factory=list)
    tools_dict: dict = field(factory=dict)

    def __attrs_post_init__(self):
        ''' Run right after __init__() '''
        # initialize logger
        self.logger = logging.getLogger("proact.gemini_client")

        # initialize search client
        if self.tavily_api_key is None:
            self.logger.warning("Tavily API Key not provided, internet search tool will not be available.")
        else:
            self.search_client = SearchClient(api_key=self.tavily_api_key)
            self.add_tool_to_toolbox(self.internet_search_tool, "internet_search_tool")
        
        # initialize firebase client
        self.fb_client = FirebaseClient()

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
            mission_type:Literal['weekly', 'ongoing'],
            num_missions:int = 3,
            debug = False # if true, do not populate missions to db
        ) -> List[dict]:
        '''
        Retrieve information about an user, then generate `num_missions` of ['weekly', 'ongoing'] missions in JSON format
        '''
        self.logger.info(f"Received request to generate {num_missions} '{mission_type}' missions.")
        
        # retrieve user information
        user = self.fb_client.get_user_by_id(user_id)
        personal_info = {
            "location": user['location'],
            "occupation": user['occupation']
        }
        interests = user['interests']
        past_missions = self._get_user_past_missions_as_strs(user_id)

        # determine the mission_generation_func
        missions_generation_func = None # either weekly or ongoing
        if mission_type == 'weekly':
            missions_generation_func = self._generate_weekly_missions
        elif mission_type == 'ongoing':
            missions_generation_func = self._generate_ongoing_missions
        else:
            msg = "mission type must be in either 'weekly' or 'ongoing'"
            self.logger.error(msg)
            raise ValueError(msg)

        # generate new missions
        valid_missions_generated = False
        while not valid_missions_generated:
            new_missions_str = missions_generation_func(
                personal_info=personal_info,
                interests = interests,
                past_missions = past_missions,
                num_missions = num_missions
            )
            # Missions parsing check
            try:
                if '```json' in new_missions_str: # common error 
                    new_missions_str = new_missions_str.replace('```json', '').replace('```', '')
                new_missions = json.loads(new_missions_str) # Should be List[dict]
                valid_missions_generated = True
            except json.decoder.JSONDecodeError:
                self.logger.warning(f"Error parsing missions from type `{type(new_missions_str)}` to `List(dict)`.")
                self.logger.info("Regenerating missions...")
        
        # add new missions to db and also format each mission to be consistent with db schema
        for mission in new_missions:
            self.fb_client.add_mission_to_db( # missions will be formatted inplace
                mission=mission,
                user_id=user_id,
                debug = debug
            ) 

        self.logger.info(f"Successfully generated {len(new_missions)} missions.")
        self.logger.debug(f"Generated missions: \n {json.dumps(new_missions, indent=4)}")

        return new_missions


    # @retry(wait=wait_fixed(2), stop=stop_after_attempt(3))
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

        answer_available:bool = False # true if not more tool call is requested
        max_depth = 5 # max number of prompt submissions until an answer is available
        cur_depth = 0

        while not answer_available: # keep submitting new prompt until an answer is available
            cur_depth += 1
            if cur_depth > max_depth:   # possibility of infinite loop
                msg = f"Max prompt submission depth of {max_depth} reached."
                self.logger.error(msg)
                raise RuntimeError(msg)
            
            try: # sending a prompt to the Gemini API
                response = self.client.generate_content(messages)
                answer_available = True
            except google.api_core.exceptions.InvalidArgument as e:# usually for invalid API key
                self.logger.error(f"Error occured when sending prompt to Gemini API: {e}")
                raise google.api_core.exceptions.InvalidArgument(e)

            # check for tool call request
            for part in response.parts:
                if part.function_call:  # tool call requested
                    answer_available = False
                    tool_output = self._execute_tool(part.function_call)
                    messages.append( # Need to keep track of conversation manually
                        {"role": "model", "parts": response.parts},
                    )
                    
                    # Put the result in a protobuf Struct
                    tool_response = Struct()
                    tool_response.update({"result": tool_output})

                    # Create a function_response part
                    function_response = genai.protos.Part(
                        function_response=genai.protos.FunctionResponse(
                            name=part.function_call.name, 
                            response=tool_response
                        )
                    )

                    # Append tool_call output to messages
                    messages.append(
                        {"role": "user", "parts": [function_response]}
                    )
                    # May need to loop until there is no fn call since the API may request many function calls in a row

        # Get final response's text  
        response_text = response.text  

        # get elapsed time and log answer
        elapsed_time = time.perf_counter() - start_time
        self.logger.info(f"Answer generated in ({elapsed_time:.2f}s)")
        self.logger.debug(f"Answer: {response_text}")

        return response_text
    

    def _get_user_past_missions_as_strs(self, user_id:str) -> List[str]:
        '''
        Get and format past missions of user `user_id` as a single string, ready to be used in prompts
        '''
        past_missions = self.fb_client.get_user_past_missions(user_id)
        self.logger.info(f"Found {len(past_missions)} past missions for user with id {user_id}")

        if len(past_missions) == 0:
            return "There has not been any missions in the past."
        past_missions_as_strs = []
        for i, mission in enumerate(past_missions):
            mission_str = f"{i+1}. {mission['title']}"   # each mission starts with a number
            for step in mission['steps']:          # each step starts with "-"
                mission_str += '\n' + f"- {step['title']}"
            past_missions_as_strs.append(mission_str)

        return past_missions_as_strs


    # TODO: Implement this function to use gemini ChatSession with automatic function calling
    @retry(wait=wait_fixed(2), stop=stop_after_attempt(3))
    def _submit_chat(self, msg:str) -> str:
        '''
        Initiate a chat session and send a chat to the Gemini API. Function calling is automatic by default.
        '''
        chat = self.client.start_chat(enable_automatic_function_calling=True)
        chat.send_message(msg)
        pass


    def _generate_weekly_missions(
            self, 
            num_missions:int, 
            personal_info:dict, 
            interests:List[str],
            past_missions:List[str]
        ) -> str:
        # Info formatted as str
        personal_info_str = '\n'.join([f'- {k}: {v}' for k,v in personal_info.items()])
        interest_info_str = '\n'.join([f'- {item}' for item in interests])
        past_missions_str = '\n'.join(past_missions)

        # Prompt template
        weekly_prompt = f'''
        Your goal is to suggest {num_missions} missions for me to do THIS WEEK to help the environment and reduce global warming. 

        Note that each mission should:
        - Be clear enough for me to keep track of my progress with.
        - (Important) Be easy and straight-forward enough for for me to get done in a week. 
        - Be personalized to my personal information and interests listed below. 
        - Focus on the environmental problems near my location.

        The steps you should take:
        1. (IMPORTANT) Do an internet search for environemntal problem near my location. 
        2. Determine the environemntal problems that I can make an impact in.
        3. Devise a set of missions for me to do with a clear description why the mission is important, is relevant (and perhaps even helpful) to me, and clear steps for me to take.  

        MAKE SURE to structure your answer in the following JSON format and do not add "```json" in the beginning:

        [   // a list of missions as json objects
            {{
                "title": // the title of the mission
                "description": // what this ,
                "steps": [
                    // an array of steps as string
                ]
            }}
        ]

        Personal information:
        {personal_info_str}

        My Interests:
        {interest_info_str}

        Below are some missions you have given me in the past, try to generate new missions that are different than these:
        {past_missions_str}
        '''

        # Submit prompt
        missions_str = self._submit_prompt(weekly_prompt)

        return missions_str
    

    def _generate_ongoing_missions(
            self, 
            num_missions:int, 
            personal_info:dict, 
            interests:List[str],
            past_missions: str,
        ) -> str:
        # Info formatted as str
        personal_info_str = '\n'.join([f'- {k}: {v}' for k,v in personal_info.items()])
        interest_info_str = '\n'.join([f'- {item}' for item in interests])
        past_missions_str = '\n'.join(past_missions)

        # Prompt template
        ongoing_prompt = f'''
        Your goal is to suggest {num_missions} detailed missions for me to do for the next few months to help the environment and reduce global warming. 

        Note that each mission should:
        - Be clear enough for me to keep track of my progress with.
        - Be detailed and big enough for me to work on for a few months. 
        - Be personalized to my personal information and interests listed below. 
        - Focus on the environmental problems near my location.

        The steps you should take:
        1. (IMPORTANT) Do an internet search for the major environemntal problems near my location. 
        2. Focus on one or a few most critical environmental problems that I can make an impact in.
        3. Devise a set of missions for me to do with a clear description why the mission is important, is relevant (and perhaps even helpful) to me, and clear steps for me to take.  

        MAKE SURE to structure your answer in the following JSON format and do not add "```json" in the beginning:

        [   // a list of missions as json objects
            {{
                "title": // the title of the mission
                "description": // what this ,
                "steps": [
                    // an array of steps as string
                ]
            }}
        ]

        My Personal information:
        {personal_info_str}

        My Interests:
        {interest_info_str}

        Below are some missions you have given me in the past, try to generate new missions that are different than these:
        {past_missions_str}
        '''

        # Submit prompt
        missions_str = self._submit_prompt(ongoing_prompt)

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
        self.logger.info(f'Internet search requested with query: "{query}"')

        if not hasattr(self, 'search_client'):
            error_msg = 'Search client was not initialized'
            self.logger.error(error_msg)
            raise RuntimeError(error_msg)
        
        # just do a quick qna search for now
        result = self.search_client.quick_search(
            query=query, 
            search_depth='advanced'
        )

        # get elapsed time 
        elapsed_time = time.perf_counter() - start_time
        self.logger.info(f"Search result obtained in ({elapsed_time:.2f}s)")
        self.logger.debug(f"Search result: {result}")

        # make sure result is of type str
        if not isinstance(result, str):
            error_msg = f'Expect searchr result to be of type `str`, got `{type(result)}` instead.'
            self.logger.error(error_msg)
            raise ValueError(error_msg)
    
        return result
    

    def add_tool_to_toolbox(self, tool: Callable, tool_name:str) -> None:
        '''
        Add a tool (function) to a list (for the gemini api) and also a dict (for executing those tools) of tools
        '''
        self.tools.append(tool)
        self.tools_dict[tool_name] = tool
        self.logger.info(f'Tool `{tool_name}` added to toolbox')


    def _execute_tool(self, tool_call: FunctionCall) -> str:
        '''
        Execute the tool requested by Gemini, output should always be of type `str`
        '''
        # get tool call details
        tool_name = tool_call.name
        tool_args = tool_call.args
        self.logger.info(f"Tool call requested for `{tool_name}` with params = {dict(tool_args)}")
        
        # execute the tool
        tool_output = self.tools_dict[tool_name](**tool_args) # pass the params to actual function
        return tool_output




# test driver
if __name__ == "__main__":
    from dotenv import load_dotenv
    from utils import init_logging, set_global_logging_level
    load_dotenv()
    init_logging()

    # Set the level of all loggers
    set_global_logging_level(logging.DEBUG)

    # Initiate gemini client
    client = GeminiClient(
        gemini_api_key=os.getenv("GEMINI_API_KEY"),
        tavily_api_key=os.getenv("TAVILY_API_KEY")
    )

    # client._submit_prompt("What are some trending cookie recipes on the internet? Provide detaisl on how to make one of them.")

    # Try get new ongoing missions
    client.get_new_mission_for_user(
        mission_type='ongoing',
        user_id='a0Zt4yVpfZVsf3xL3hwdmWnFstF2',
        num_missions=2,
        debug = True
    )