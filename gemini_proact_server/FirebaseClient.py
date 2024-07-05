'''
This class handles all interactions with Firebase including Cloud Firestore, Cloud Storage 
'''

import firebase_admin
from firebase_admin import credentials, firestore
import google

import logging

from attrs import define, field, NOTHING
from typing import List, Dict

@define
class FirebaseClient():

    # input
    firebase_cert_path: str = field(default="firebase_admin_cert.json", eq=False)

    # internal
    logger: logging.Logger = field(init=False)
    db: google.cloud.firestore_v1.client.Client = field(init=False)


    def __attrs_post_init__(self):
        ''' Run right after __init__() '''
        # Initialize logger
        self.logger = logging.getLogger("proact.firebase_client")

        # Authenticate and initalize firebase_admin
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
        Get user information as dict given an `user_id`
        '''
        query = self.db.collection('User').where('vaultedId','==', user_id)
        users = list(query.stream())

        if len(users) == 0:
            raise ValueError(f"No user found with user_id {user_id}")
        elif len(users) > 1:
            raise ValueError(f"Found 2 or more users with user_id {user_id}")

        matched_user = users[0].to_dict()
        self.logger.info(f"Successfully retrieved user '{matched_user['username']}'")
        return matched_user
    

    def get_user_past_missions(self, user_id:str) -> List[dict]:
        mission_ref = self.db.collection('Mission')
        query = mission_ref.where('user_id', '==', user_id)
        past_missions = list(query.stream())

        # Check if there is any mission at all
        if len(past_missions) == 0:
            return []
        else:
            past_missions = [m.to_dict() for m in past_missions]
        return past_missions
    

    def add_mission_to_db(
            self, 
            mission:dict, 
            user_id:str,
            debug:bool=False # if true, do not add mission to db
        ) -> str:
        '''
        Add a new mission as dict to Cloud Firestore, then return the geneated mission id
        '''
        # convert each step from str to dict with status
        converted_steps = []
        for step_str in mission['steps']:
            converted_steps.append({
                'title': step_str,
                'status': 'in progress'
            })
        
        # replace str steps with dict steps
        mission['steps'] = converted_steps

        # also add other needed fields to mission
        mission.update({
            'status': 'in progress',
            'user_id': user_id,
            'deadline': None,
            'styleId': None,
            'eventId': None,
        })

        # add new mission to db
        if not debug:
            mission_ref = self.db.collection('Mission')
            timestamp, doc_ref = mission_ref.add(mission)
            mission['id'] = doc_ref.id
            self.logger.info(f"New mission with id '{mission['id']}' added to db.")
        else:   # if debug = True, do not add new mission to db
            mission['id'] = 'test_mission'
            self.logger.info(f"Test mission was not added to db since `debug=True`.")

        return mission['id']


# test driver
if __name__ == "__main__":
    fb_client = FirebaseClient()
    # user = fb_client.get_user("a0Zt4yVpfZVsf3xL3hwdmWnFstF2") # sample_user
