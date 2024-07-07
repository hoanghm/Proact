'''
This class handles all interactions with Firebase including Cloud Firestore, Cloud Storage 
'''

import os
import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore import Client, DocumentReference, FieldFilter
from google.protobuf.timestamp_pb2 import Timestamp
from google.api_core import exceptions
import logging
from attrs import define, field, NOTHING
from typing import *
from database.Mission import Mission, UserMission
import uuid

@define
class FirebaseClient:
    # input
    firebase_cert_path: str = field(default='service_account_keys/firebase_admin_cert.json', eq=False)

    # internal
    logger: logging.Logger = field(init=False)
    db: Client = field(init=False)

    def __attrs_post_init__(self):
        ''' Run right after __init__() '''
        # Initialize logger
        self.logger = logging.getLogger("proact.firebase_client")

        # Authenticate and initalize firebase_admin
        self.firebase_cert_path = os.environ.get('FIREBASE_ADMIN_CERT_PATH', self.firebase_cert_path)
        self.logger.debug(f'load firebase admin credentials from {self.firebase_cert_path}')
        cred = credentials.Certificate(self.firebase_cert_path)
        try:
            firebase_admin.initialize_app(cred)
        except ValueError: 
            pass # firebase app already exists, just move on

        # Initialize Cloud Firestore instance
        self.db = firestore.client()
        self.logger.info("Firebase client initialized")
    

    def get_user_by_id(self, user_id:str) -> dict:
        '''
        Get user information as dict given a `user_id`.

        TODO use User class instead of dict.
        '''
        user = self.db.collection('User').document(user_id).get()

        if not user.exists:
            raise ValueError(f"No user found with user_id {user_id}")

        matched_user = user.to_dict()
        self.logger.info(f"Successfully retrieved user username={matched_user['username']} email={matched_user['email']}")
        return matched_user
    # end def

    def get_missions(self, mission_ids: List[str], depth: int=0) -> List[Mission]:
        missions = []
        mission_ref = self.db.collection(Mission.table_name())

        for mission_id in mission_ids:
            try:
                mission_raw = mission_ref.document(document_id=mission_id).get()
                if mission_raw.exists:
                    mission = Mission.from_dict(mission_raw.to_dict(), steps_are_raw=False)
                    if depth > 0 and len(mission.steps_id) > 0:
                        self.logger.debug(f'fetch steps until depth={depth} for {mission}')
                        mission.steps_mission = self.get_missions(mission.steps_id, depth=depth-1)
                    
                    missions.append(mission)
                else:
                    self.logger.error(f'failed to fetch mission {mission_id}')
            except exceptions.InvalidArgument as e:
                self.logger.error(f'failed to fetch mission {mission_id}. {e}')
        # end for mission step

        return missions
    # end def

    def get_user_past_missions(self, user_id: str, depth: int=0) -> List[Mission]:
        '''Get user missions as list if dicts given a `user_id`.

        :depth: How far to follow `mission.steps` references. `0` means mission steps are not fetched.
        `1` means child steps are fetched, but grandchild steps are not fetched.
        '''

        user_mission_ref = self.db.collection(UserMission.table_name())
        query = user_mission_ref.where(filter=FieldFilter('userId', '==', user_id))

        missions: List[Mission] = []
        for user_mission_raw in query.stream():
            user_mission = UserMission.from_dict(user_mission_raw.to_dict())
            mission_singleton = self.get_missions([user_mission.mission_id], depth=depth)
            if len(mission_singleton) > 0:
                missions.append(mission_singleton[0])
        # end for user mission

        self.logger.info(f'fetched {len(missions)} missions for user {user_id}') 
        return missions
    # end def

    def add_mission_to_db(
        self, 
        mission: Mission, 
        user_id: str,
        skip_assignment: bool=False,
        debug: bool=False
    ) -> Tuple[str, Optional[str]]:
        '''Add a new mission, to Cloud Firestore as well as assignment to the given user.

        :param skip_assignment: Whether to skip creation of the user-mission entry (used to skip assignment for child missions
        if user is already assigned to parent mission).
        :param debug: If true, do not add mission to db.
        :return: Generated mission id, user-mission id.
        '''

        # persist steps
        if len(mission.steps_mission) > 0:
            self.logger.debug(f'mission {mission} as {len(mission.steps_mission)} steps')
            # recursive call to first persist steps as child missions
            for step_idx, step in enumerate(mission.steps_mission):
                step_id, user_step_id = self.add_mission_to_db(
                    mission=step,
                    user_id=user_id,
                    skip_assignment=True,
                    debug=debug
                )

                # add generated step id to parent mission
                mission.steps_id[step_idx] = step_id
            # end for
        else:
            self.logger.info(f'mission {mission} has no steps')

        # persist mission
        if not debug:
            mission_ref = self.db.collection(Mission.table_name())

            ts_dr: Tuple[Timestamp, DocumentReference] = mission_ref.add(mission.to_dict())
            doc_ref = ts_dr[1]
            mission.id = doc_ref.id
            self.logger.info(f"new mission {mission} added to db")
        else:   # if debug = True, do not add new mission to db
            mission.id = str(uuid.uuid1())
            self.logger.info(f"test mission {mission} was not added to db in debug mode")
        
        if not skip_assignment:
            # create and persist user-mission
            user_mission = UserMission.from_dict({
                'userId': user_id,
                'missionId': mission.id
            })
            if not debug:
                user_mission_ref = self.db.collection(UserMission.table_name())
                ts_dr = user_mission_ref.add(user_mission.to_dict())
                doc_ref = ts_dr[1]
                user_mission.id = doc_ref.id
                self.logger.info(f'new user-mission {user_mission} added to db')
            else:
                user_mission.id = str(uuid.uuid1())
                self.logger.info(f'test user-mission {user_mission} was not added to db in debug mode')
        else:
            self.logger.debug(f'skip user-mission for {mission}')
            user_mission = None

        return mission.id, (user_mission.id if user_mission is not None else None)
# end class

# test driver
if __name__ == "__main__":
    from dotenv import load_dotenv
    from utils import init_logging, set_global_logging_level

    load_dotenv()
    init_logging()

    # Set the level of all loggers
    set_global_logging_level(logging.DEBUG)

    fb_client = FirebaseClient()
    user = fb_client.get_user_by_id(os.getenv('USER_ID'))
    missions = fb_client.get_user_past_missions(os.getenv('USER_ID'), depth=2)
# end if __main__
