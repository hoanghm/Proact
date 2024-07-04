'''
This class handles all interactions with Firebase including Cloud Firestore, Cloud Storage 
'''

import firebase_admin
from firebase_admin import credentials, firestore
import google

import logging

from attrs import define, field, NOTHING
from typing import Dict

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
    
    def get_user_by_id(self, user_id:str) -> Dict:
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


# test driver
if __name__ == "__main__":
    fb_client = FirebaseClient()
    user = fb_client.get_user("a0Zt4yVpfZVsf3xL3hwdmWnFstF2") # sample_user