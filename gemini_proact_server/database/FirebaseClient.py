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
from database.Mission import Mission
from database.User import User
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
    

    def get_user_by_id(self, user_id:str) -> User:
        '''
        Get user information as `User` instance given a `user_id`.
        '''

        user_snap = self.db.collection(User.table_name()).document(user_id).get()

        if not user_snap.exists:
            raise ValueError(f"No user found with id={user_id}")

        user_data = user_snap.to_dict()
        # user document id is not necessarily stored as an attribute within the document
        user_data.update({
            'id': user_id
        })
        user = User.from_dict(user_data)
        self.logger.info(f"Successfully retrieved {user}")
        return user
    # end def

    def get_missions(self, mission_ids: List[str], depth: int=0) -> List[Mission]:
        missions = []
        mission_ref = self.db.collection(Mission.table_name())

        for mission_id in mission_ids:
            try:
                mission_raw = mission_ref.document(document_id=mission_id).get()
                if mission_raw.exists:
                    mission = Mission.from_dict(mission_raw.to_dict(), steps_are_raw=False)
                    if depth > 0 and len(mission.missions_id) > 0:
                        self.logger.debug(f'fetch steps until depth={depth} for {mission}')
                        mission.missions_mission = self.get_missions(mission.missions_id, depth=depth-1)
                    
                    missions.append(mission)
                else:
                    self.logger.error(f'failed to fetch mission {mission_id}')
            except exceptions.InvalidArgument as e:
                self.logger.error(f'failed to fetch mission {mission_id}. {e}')
        # end for mission step

        return missions
    # end def

    def fetch_user_missions(self, user: User, depth: int=0):
        '''Populate `user.missions_mission` by fetching from references.

        :depth: How far to follow `mission.steps` references. `0` means mission steps are not fetched.
        `1` means child steps are fetched, but grandchild steps are not fetched.
        '''
        
        user.missions_mission = self.get_missions(
            mission_ids=user.missions_id,
            depth=depth
        )
    # end def

    def add_mission_to_db(
        self, 
        mission: Mission, 
        user: User,
        skip_assignment: bool=False,
        debug: bool=False
    ) -> str:
        '''Add a new mission, to Cloud Firestore as well as assignment to the given user.

        :param skip_assignment: Whether to skip creation of the user-mission entry (used to skip assignment for child missions
        if user is already assigned to parent mission).
        :param debug: If true, do not add mission to db.
        :return: Generated mission id.
        '''

        # persist steps
        if len(mission.missions_mission) > 0:
            self.logger.debug(f'mission {mission} as {len(mission.missions_mission)} steps')
            # recursive call to first persist steps as child missions
            for step_idx, step in enumerate(mission.missions_mission):
                step_id = self.add_mission_to_db(
                    mission=step,
                    user=user,
                    skip_assignment=True,
                    debug=debug
                )

                # add generated step id to parent mission
                mission.missions_id[step_idx] = step_id
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
            user.add_mission(mission=mission)

            # update user in db
            if not debug:
                user_doc = self.db.collection(User.table_name()).document(user.id)
                res = user_doc.set(
                    document_data={
                        'missions': user.missions_id
                    },
                    merge=True
                )
                self.logger.info(f'new mission added to user {user_doc.id} in db at {res.update_time}')
            else:
                self.logger.info(f'new mission in user {user} was not written to db in debug mode')
        else:
            self.logger.debug(f'skip user assignment for {mission}')

        return mission.id
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
    fb_client.fetch_user_missions(user, depth=2)
    missions_str = '\n'.join([str(m) for m in user.missions_mission])
    fb_client.logger.info(
        f'user missions: \n{missions_str}'
    )
# end if __main__
