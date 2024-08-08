from enum import Enum
import os
import json
import time
import logging.config
from tenacity import retry, wait_fixed, stop_after_attempt
from datetime import datetime, timedelta

from attrs import define, field, NOTHING
from typing import List, Callable, Union, Dict, Literal

import google
import google.generativeai as genai
from google.ai.generativelanguage_v1beta.types.content import FunctionCall
from google.protobuf.struct_pb2 import Struct

from SearchClient import SearchClient
from database.FirebaseClient import FirebaseClient
from database.entities.Mission import *

GEMINI_MODEL:dict = {
    "flash": "gemini-1.5-flash" 
}

@define
class GeminiClient:
    '''Gemini API client. 

    - This class focuses on communications with the Gemini API and prompt engineering. 
    - It may use other tools (such as SearchClient) to enrich the prompts sent to the Gemini API. 
    '''

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
            self.logger.info('tavily api enabled for internet search tool.')
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


    def _get_user_information_as_strs(self, user_id:str):
        '''
        Retrieve User's `personal_info` and interests as strs, ready to be used in prompts
        '''
        user = self.fb_client.get_user_by_id(user_id)
        
        # personal information
        personal_info = {
            "location": user.location,
            "occupation": user.occupation
        }
        personal_info_str = '\n'.join([f'- {k}: {v}' for k,v in personal_info.items()])

        # interests
        interest_info_str = '\n'.join([f'- {item}' for item in user.interests])

        return {
            "personal_info": personal_info_str,
            "interests": interest_info_str
        }
    

    def _get_user_past_missions_as_strs(
        self, 
        user_id:str,
        depth:int = 2 # latest number of missions to retrieve
    ):
        '''
        Retrieve User's `past_missions` as a single string, ready to be used in prompts
        '''
        user = self.fb_client.get_user_by_id(user_id)

        # TODO: remove depth and add a param for how far in the past to retrieve
        self.fb_client.fetch_user_missions(user, depth=1) 
        
        # TODO: filter by 'weekly mission' type
        past_missions = user.missions_mission
        self.logger.info(f'found {len(past_missions)} past missions for user with id {user}')

        if len(past_missions) == 0:
            return ["There has not been any missions in the past."]
        past_missions_as_strs = []
        for i, mission in enumerate(past_missions):
            mission_str = f"{i+1}. {mission.title}"   # each mission starts with a number
            for step in mission.missions_mission:          # each step starts with "-"
                mission_str += '\n' + f"- {step.title}"
            past_missions_as_strs.append(mission_str)
        
        past_missions_str = '\n'.join(past_missions_as_strs)

        return past_missions_str    
    

    def _parse_str_as_json(self, json_str:str) -> dict:
        if '```json' in json_str: # common error 
            json_str = json_str.replace('```json', '').replace('```', '')
        result = json.loads(json_str)
        return result
    

    def _parse_mission(
        self,   
        mission_str:str = None,
        raw_mission:dict = None,
        deadline: datetime = None
    ) -> Mission:
        if mission_str is None and raw_mission is None:
            raise ValueError("Either `mission_str` or `raw_mission` must not be None")
        
        if raw_mission is None:    
            raw_mission = self._parse_str_as_json(mission_str)

        mission = WeeklyMission(
            title = raw_mission['title'],
            description = raw_mission['description'],
            deadline = deadline
        )
        # Get mission ecopoint
        mission.ecoPoints = self._evaluate_mission_ecopoint(
            mission_str=json.dumps(raw_mission, indent=4)
        )[0]         
        # Create mission steps
        steps = []
        for step_str in raw_mission['steps']:
            step = Step(title=step_str)
            steps.append(step)
        # Add steps to mission
        mission.add_steps(steps)

        return mission
    

    def _parse_weekly_project(
        self, 
        missions_str: List[str], # list of projects
        project_title: str,
        project_desc: str = "",
        deadline: datetime = None
    ) -> WeeklyProject:
        '''Parse missions from gemini response.

        :raises: `JsonDecodeError` on parse failure.
        '''
        # convert missions_str to a dict
        raw_missions = self._parse_str_as_json(missions_str)

        # first create empty project without missions
        project = WeeklyProject(
            title = project_title,
            description = project_desc,
            deadline = deadline
        )

        # Create each mission
        missions = []
        for raw_mission in raw_missions:
            mission = self._parse_mission(raw_mission=raw_mission)
            # Add mission to list
            missions.append(mission)
        
        # Add missions to projects
        project.add_steps(missions)

        return project
    

    def regenerate_mission(
        self,
        user_id:str,
        project_id:str,
        mission_id:str
    ) -> Mission:
        # Get relevant user + mission objs
        user = self.fb_client.get_user_by_id(user_id)
        old_mission = self.fb_client.get_mission_entity_by_id(mission_id)

        # Personal Info formatted as str
        user_info_dict = self._get_user_information_as_strs(user_id=user_id)
        personal_info_str = user_info_dict['personal_info']
        interest_info_str = user_info_dict['interests']
        # TODO: Get Past weekly missions formatted as str
        past_missions_str = "None"
        # past_missions_str = self._get_user_past_missions_as_strs(
        #     user_id = user_id,
        #     mission_type = MissionPeriodType.WEEKLY,
        #     order = MissionHierachyOrder.PROJECT
        # )

        prompt = f'''
        Earlier you suggested the mission below for me, but I don't like it and want a different one. The mission you suggested was:
        {str(old_mission)}

        -----
        Your goal now is to suggest a different missions for me to do this a week to help the environment and reduce global warming. 
        
        Note that the mission should:
        - Be clear enough for me to keep track of my progress.
        - (Important) Be easy and straight-forward enough for me to finish in a week.
        - Be personalized to my personal information and interests listed below. 
        - Focus on the environmental problems near my location.

        The steps you should take:
        1. (IMPORTANT) Do an internet search for environmental problem near my location. 
        2. Determine the environmental problems that I can make an impact in.
        3. Devise a missionfor me to do with a clear description why each mission is important, is relevant (and perhaps even helpful) to me, and clear steps for me to take.  

        My Personal information:
        {personal_info_str}

        My Interests:
        {interest_info_str}

        Below are some missions you have given me in the past, try to generate new missions that are different than these:
        {past_missions_str}


        MAKE SURE to structure your answer in the following JSON format and do not add "```json" in the beginning:
            {{
                "title": // title of the mission
                "description": // description of the mission
                "steps": [
                    // an array of steps as strings 
                ]
            }}
        '''

        # Submit prompt until successfully parsed or MAX_ATTEMPT reached
        MAX_ATTEMPT = 5
        valid_mission_generated = False
        attempt = 0
        mission: Mission
        while not valid_mission_generated and attempt < MAX_ATTEMPT:
            attempt += 1
            self.logger.info(f'generate weekly missions attempt {attempt}/{MAX_ATTEMPT}')

            # Submit prompt
            mission_str = self._submit_prompt(prompt)
            
            # missions parsing check
            try:
                mission = self._parse_mission(
                    mission_str=mission_str,
                    deadline = old_mission.deadline 
                )
                valid_mission_generated = True
            
            except json.decoder.JSONDecodeError:
                self.logger.warning(f"Error parsing missions from gemini answer")
        # Update the new mission to db then return mission
        self.fb_client.replace_mission_of_project(
            project_id=project_id,
            old_mission_id=mission_id,
            new_mission=mission
        )
        return mission
    

    def generate_weekly_project(
        self,
        user_id: str,
        num_missions: int = 3,
        debug:bool = False, # if true, do not populate missions to db
    ) -> WeeklyProject:
        '''
        Generate a Weekly Project as a set of weekly missions
        '''
        user = self.fb_client.get_user_by_id(user_id)

        # Personal Info formatted as str
        user_info_dict = self._get_user_information_as_strs(user_id=user_id)
        personal_info_str = user_info_dict['personal_info']
        interest_info_str = user_info_dict['interests']

        # TODO: Get Past weekly missions formatted as str
        past_missions_str = "None"
        # past_missions_str = self._get_user_past_missions_as_strs(
        #     user_id = user_id,
        #     mission_type = MissionPeriodType.WEEKLY,
        #     order = MissionHierachyOrder.PROJECT
        # )
        

        # Prompt template
        prompt = f'''
        Your goal is to suggest {num_missions} missions for me to do in a week to help the environment and reduce global warming. 

        Note that each mission should:
        - Be clear enough for me to keep track of my progress.
        - (Important) Be easy and straight-forward enough for me to finish in a week.
        - Be personalized to my personal information and interests listed below. 
        - Focus on the environmental problems near my location.

        The steps you should take:
        1. (IMPORTANT) Do an internet search for environmental problem near my location. 
        2. Determine the environmental problems that I can make an impact in.
        3. Devise a set of missions {num_missions} for me to do with a clear description why each mission is important, is relevant (and perhaps even helpful) to me, and clear steps for me to take.  

        MAKE SURE to structure your answer in the following JSON format and do not add "```json" in the beginning:

        [   // a list of missions as json objects
            {{
                "title": // title of the mission
                "description": // description of the mission
                "steps": [
                    // an array of steps as strings 
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

        # Submit prompt until successfully parsed or MAX_ATTEMPT reached
        MAX_ATTEMPT = 5
        valid_project_generated = False
        attempt = 0
        missions: List[BaseMission]
        while not valid_project_generated and attempt < MAX_ATTEMPT:
            attempt += 1
            self.logger.info(f'generate weekly missions attempt {attempt}/{MAX_ATTEMPT}')

            # Submit prompt
            missions_str = self._submit_prompt(prompt)
            
            # missions parsing check
            try:
                week_of_the_year = self._get_current_week_of_the_year()
                end_of_week = self._get_end_of_week_datetime()
                project = self._parse_weekly_project(
                    missions_str=missions_str,
                    project_title=f"Weekly project {week_of_the_year}",
                    deadline = end_of_week 
                )
                valid_project_generated = True
            
            except json.decoder.JSONDecodeError:
                self.logger.warning(f"Error parsing missions from gemini answer")
        
        # Add project and all its child missions, steps to db
        self.fb_client.add_mission_entity_to_db(
            mission_entity = project,
            debug = debug
        )
        self.fb_client.add_project_to_user(
            project=project,
            user_id=user_id, 
            debug=debug
        )

        self.logger.info(f"Successfully generated Weekly Project '{project.title}' with {len(project.steps)} child missions")
        return project
        

    def generate_ongoing_project(
        self,
        user_id: str,
        debug = False # if true, do not populate mission to db 
    ):
        '''
        Generate a single ongoing project consisting of multiple missions
        '''
        raise NotImplementedError("Method still in progress, not ready to be used.") 



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
                # end if function call
            # end for part in response
        # end while no answer

        # Get final response's text  
        response_text = response.text  

        # get elapsed time and log answer
        elapsed_time = time.perf_counter() - start_time
        self.logger.info(f"Answer generated in ({elapsed_time:.2f}s)")
        self.logger.debug(f"Answer: {response_text}")

        return response_text


    def _get_current_week_of_the_year(self) -> int:
        now = datetime.now()
        return now.isocalendar().week


    def _get_end_of_week_datetime(self) -> datetime:
        now = datetime.now()
        end_of_sunday = now + timedelta(days = 6 - now.weekday()) # 0 is Monday, 6 is Friday
        end_of_sunday = end_of_sunday.replace(hour=23, minute=59, second=0, microsecond=0)
        return end_of_sunday


    def _generate_ongoing_project():
        '''
        Generate a single ongoing project, which is a set of missions leading toward a goal
        '''
        pass


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


    def _evaluate_mission_ecopoint(self, mission_str:str, max_retry:int=3) -> Tuple[int, str]:
        '''
        Given a mission as str, return a tuple of 2 values: [EcoPoint, reason]
        '''
        prompt = f'''
        Your job is to evaluate how many meaningful an environmental mission mentioned below is worth 
        based on its environmental impact and difficulty to complete. 
        Difficulty to complete should be on a scale of 1 to 10. 
        Environmental impact should be on a scale of 1 to 10. 

        Examples of how many points to give:
        - Host a clothing swap among your friends --> Difficulty = 3, Impact = 6
        - Plant a tree --> Difficulty = 8, Impact = 8
        - Bike to work/school instead of driving --> Difficulty = 9, Impact = 10
        
        Give your answer in JSON format:
        {{
            'difficulty': <an integer from 1 to 10>,
            'impact': <an integer from 1 to 10,
            'reason': <brief explanation>
        }} 
        
        Environmental mission:
        {mission_str}
        '''
        # get answer from Gemini
        answer = self._submit_prompt(prompt)

        # parse answer and calculate ecopoint
        ecopoint: int 
        reason: str
        try:
            evaluation = self._parse_str_as_json(json_str=answer)
            difficulty = evaluation['difficulty']
            impact = evaluation['impact']
            reason = evaluation['reason']
            ecopoint = difficulty * 5 + impact * 5 # ranges from 20 to 100
        except Exception as e: # recursively try again until good or `max_retry` is reached 
            # too many errors occured
            if max_retry == 0:
                msg = f"Max retry occured when evaluating mission EcoPoint.\n mission_str: \n {mission_str}"
                self.logger.error(msg)
                raise RuntimeError(msg)
            else:
                self.logger.warning(f"Encountered error when evaluating ecopoint. Retry left after this attempt = {max_retry-1}. \n Error: {e}")
                ecopoint, reason = self._evaluate_mission_EcoPoint(
                    mission_str=mission_str,
                    max_retry=max_retry-1
                )
        self.logger.debug(f"For mission {mission_str[:50]}..., ecoPoint evaluated = {ecopoint}.")
        return ecopoint, reason


        






# test driver
if __name__ == "__main__":
    from dotenv import load_dotenv
    from utils.init_logging import init_logging, set_global_logging_level
    load_dotenv()
    init_logging()

    # Set the level of all loggers
    set_global_logging_level(logging.DEBUG)

    # Initiate gemini client
    client = GeminiClient(
        gemini_api_key=os.getenv("GEMINI_API_KEY"),
        tavily_api_key=os.getenv("TAVILY_API_KEY")
    )

    # # Try get new ongoing missions
    # project = client.generate_weekly_project(
    #     user_id="ED0wLoYYm4Ur1atUGeKvGUVDYd83",
    #     num_missions=3,
    #     debug=True
    # )

    client.regenerate_mission(
        user_id="ED0wLoYYm4Ur1atUGeKvGUVDYd83",
        project_id="PFOQoMWZ6h5uA80N6wDB",
        mission_id="zrajMaySvEZlTlMAejec"
    )
    breakpoint()
