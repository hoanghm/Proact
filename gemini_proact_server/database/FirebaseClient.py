'''
This class handles all interactions with Firebase including Cloud Firestore, Cloud Storage 
'''

import os
import logging
import uuid

import firebase_admin
from firebase_admin import credentials, firestore

from google.cloud.firestore import Client, DocumentReference, FieldFilter
from google.protobuf.timestamp_pb2 import Timestamp
from google.api_core import exceptions

from .entities.User import *
from .entities.Mission import *
from utils import decode_base64_to_dict

from attrs import define, field, NOTHING
from typing import *


@define
class FirebaseClient:
    # input
    firebase_cert_encoding: str = field(default=None)

    # internal
    logger: logging.Logger = field(init=False)
    db: Client = field(init=False)

    def __attrs_post_init__(self):
        ''' Run right after __init__() '''
        # Initialize logger
        self.logger = logging.getLogger("proact.firebase_client")

        # Authenticate and initalize firebase_admin
        firebase_cert_encoding = os.environ.get('FIREBASE_ADMIN_CERT_ENCODING', self.firebase_cert_encoding)
        if firebase_cert_encoding is None:
            msg = "'firebase_cert_encoding' must be set, or env variable 'FIREBASE_ADMIN_CERT_ENCODING' must be available."
            self.logger.error(f"RuntimeError: {msg}")
            raise RuntimeError(msg)

        firebase_cert_dict = decode_base64_to_dict(firebase_cert_encoding)
        cred = credentials.Certificate(firebase_cert_dict)
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

        user_snap = self.db.collection('User').document(user_id).get()

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
    

    def user_has_existing_weekly_project(self, user_id):
        '''
        Given an user_id, returns `True` if an acive weekly project exists and `False` otherwise. Return None if user doesn't exist.
        '''
        try:
            user = self.get_user_by_id(user_id)
        except ValueError as e:
            return None
        active_weekly_project_exists = False
        for project_id in user.project_ids:
            project = self.get_mission_entity_by_id(project_id)
            if project.status == MissionStatus.IN_PROGRESS:
                active_weekly_project_exists = True
                break
        return active_weekly_project_exists


    def get_mission_entity_by_id(
            self, 
            mission_id: str, 
        ) -> BaseMission:
        mission_ref = self.db.collection('Mission')
        mission_entity: BaseMission = None # to return
        try:
            mission_raw = mission_ref.document(document_id=mission_id).get()
            if mission_raw.exists:
                # Parse mission entity
                mission_dict = mission_raw.to_dict()

                # Create each 'step' obj first
                steps:List[BaseMission] = [] 
                for step_id in mission_dict['steps']:
                    step = self.get_mission_entity_by_id(step_id)
                    steps.append(step)
                
                # Then create Mission entity
                mission_dict['steps'] = steps
                mission_dict['id'] = mission_id
                mission_entity = create_mission_entity_from_dict(mission_dict)
            else:
                msg = f"Cannot find mission entity with id '{mission_id}'"
                self.logger.error(msg)
                raise ValueError(msg)
        except exceptions.InvalidArgument as e:
            self.logger.error(f'failed to fetch mission {mission_id}. {e}')
       
        return mission_entity


    def fetch_user_projects(self, user: User) -> List[Union[WeeklyProject, OngoingProject]]:
        '''Populate `User.projects` by fetching from database.
        '''
        # Fetch each project from the user's list of project ids
        for project_id in user.project_ids:
            project = self.get_mission_entity_by_id(project_id)
            user.projects.append(project)
        self.logger.info(f"Fetched {len(user.projects)} projects for user {user.id}")
        return user.projects

    
    def add_mission_entity_to_db(
        self,
        mission_entity: BaseMission,
        debug: bool=False # If true, do not add to db
    ):
        if not isinstance(mission_entity, BaseMission):
            msg = "Encountered mission that is not of type `BaseMission`"
            self.logger.error(msg)
            raise RuntimeError(msg)
        
        # add all steps of this mission entity to db first
        for step in mission_entity.steps:
            self.add_mission_entity_to_db(
                mission_entity = step,
                debug = debug
            )

        # base case, no more steps to process
        if not debug:
            mission_collection_ref = self.db.collection("Mission")
            project_doc_ref = mission_collection_ref.document(mission_entity.id)
            try:
                project_doc_ref.set(mission_entity.to_dict())
            except TypeError as e:
                self.logger.error(f"Error when adding mission entity to db. {e}")
        self.logger.info(f"Added mission entity: {mission_entity}") 
    

    def add_project_to_user(
            self, 
            project:Union[WeeklyProject, OngoingProject],
            user_id:str,
            debug:bool = False # If true, do not add to db
        ):
        user_ref = self.db.collection("User")
        user_doc = user_ref.document(user_id)

        if not debug:
            res = user_doc.update({
                "projects": firestore.ArrayUnion([project.id])
            })
            self.logger.info(f'New project added to user {user_doc.id} in db at {res.update_time}')
        else:
            self.logger.info(f'New project for user {user_doc.id} was not written to db in debug mode')


# test driver
if __name__ == "__main__":
    from dotenv import load_dotenv
    from utils import init_logging, set_global_logging_level

    load_dotenv()
    init_logging()

    # Set the level of all loggers
    set_global_logging_level(logging.INFO)

    fb_client = FirebaseClient()
    # user = fb_client.get_user_by_id("IFXLaAIczXW3hvYansv1DXrH7iH2")
    # projects = fb_client.fetch_user_projects(user)
    user_id = "ED0wLoYYm4Ur1atUGeKvGUVDYd83"
    result = fb_client.user_has_existing_weekly_project(user_id)
    breakpoint()