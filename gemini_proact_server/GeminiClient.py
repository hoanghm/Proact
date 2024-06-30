"""Gemini API client.
"""
import os
import json
import time
import logging.config
from tenacity import retry, wait_fixed, stop_after_attempt


from attrs import define, field, NOTHING
from typing import List, Callable, Union

import google.generativeai as genai


GEMINI_MODEL:dict = {
    "flash": "gemini-1.5-flash" 
}


@define
class GeminiClient:
    
    # inputs
    api_key: str = field(default=NOTHING, eq=True)
    model: str = field(default="flash", eq=str.lower)
    tools: List[Callable] = field(factory=list)

    # internal
    logger: logging.Logger = field(default=logging.getLogger("proact.gemini_client"))
    client: Union[genai.GenerativeModel, None] = field(default=None)

    def __attrs_post_init__(self):
        # define gemini model
        genai.configure(api_key=self.api_key)
        self.client = genai.GenerativeModel(GEMINI_MODEL[self.model])
        self.logger.info("Gemini client initialized")

    
    def get_new_mission_for_user(self, user_id:str, num_missions:int = 3) -> List[dict]:
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
                new_missions = json.loads(new_missions_str) # Should be List[dict]
                valid_missions_generated = True
            except json.decoder.JSONDecodeError:
                self.logger.warning("Parsing error, object cannot be parsed to type List[dict]")
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
        response = self.client.generate_content(messages)
        response_text = response.text
        
        # get elapsed time and log answer
        elapsed_time = time.perf_counter() - start_time
        self.logger.info(f"Answer generated in ({elapsed_time:.2f}s)")
        self.logger.debug(f"Answer: {response_text}")

        return response_text
    

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
        api_key=os.getenv("GEMINI_API_KEY")
    )
    
    # Try get some new missions
    client.get_new_mission_for_user("123")

    # client.logger.debug("This is a debug.")
    # client.logger.warning("This is a warning.")
    # client.logger.error("This is an error.")
    # client.logger.critical("This is critical.")