from typing import *
import logging
from .DatabaseEntity import DatabaseEntity
from .Question import UserQuestion
from .OldMission import HasMissions

logger = logging.getLogger('proact.database.user')

class User(HasMissions):
    '''Proact user, compatible w db table.
    '''

    @classmethod
    def _attr_keys(cls) -> List[str]:
        return [
            'username',
            'email',
            'vaultedId',
            'occupation',
            'location',
            'interests',
            'questionnaire',
            'others'
        ] + super()._attr_keys()


    @classmethod
    def _summary_keys(cls) -> int:
        return 2


    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.username: Optional[str] = kwargs.get('username')
        self.email: str = kwargs['email']
        self.occupation: Optional[str] = kwargs.get('occupation')
        self.location: Optional[str] = kwargs.get('location')
        self.interests: List[str] = kwargs.get('interests', [])
        self.questionnaire: List[UserQuestion] = kwargs.get('questionnaire', [])

