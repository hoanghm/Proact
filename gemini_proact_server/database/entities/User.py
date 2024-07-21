import logging

import attrs
from attrs import define, field, NOTHING
from typing import *
from typing_extensions import override

from .DatabaseEntity import DatabaseEntity

logger = logging.getLogger('proact.database.user')

@define
class User(DatabaseEntity):
    '''
    Represents an User, id will be auto generated if not provided
    '''
    username: str = field(default=None)
    email: str = field(default=None, repr=True)
    occupation: str = field(default=None)
    location: str = field(default=None)
    interests: List[str] = field(factory=list)

    @classmethod
    def from_dict(cls, input_dict:Dict): 
        return cls(
            username = input_dict.get('username'),
            email = input_dict.get('email'),
            occupation = input_dict.get('occupation'),
            location = input_dict.get('location'),
            interests = input_dict.get('interests')
        )

