import logging
import json
from enum import Enum
from datetime import datetime

from .DatabaseEntity import DatabaseEntity
from utils import strings

from typing import *
from typing_extensions import override


logger = logging.getLogger('proact.database.mission')

class MissionStatus(Enum):
    NOT_STARTED = 'not started'
    IN_PROGRESS = 'in progress'
    DONE = 'done'
# end class

class MissionPeriodType(Enum):
    WEEKLY = 'weekly'
    '''Mission estimated to complete in 1 week.
    '''
    ONGOING = 'ongoing'
    '''Mission does not have a clear duration; deadline is flexible.
    '''

class MissionHierachyOrder(Enum):
    PROJECT = 'project'
    MISSION = 'mission'
    STEP = 'step'

class HasMissions(DatabaseEntity):
    '''An entity that contains missions as references whose objects can be fetched.
    '''

    @override
    @classmethod
    def _attr_keys(cls, missions_alias: str = None) -> strings.List[str]:
        return super()._attr_keys() + [
            missions_alias if missions_alias is not None else 'missions'
        ]
    # end def

    def __init__(self, missions_alias: str = None, **kwargs):
        super().__init__(**kwargs)

        if missions_alias is not None:
            kwargs['missions'] = kwargs.get(missions_alias)
        
        missions: List[Union[str, Mission]] = kwargs.get('missions', [])
        self.missions_id: List[str] = []
        '''List of child mission ids.
        '''
        self.missions_mission: List[Mission] = []
        '''List of child missions.
        
        In context of querying a parent mission, this list will not be populated until `steps_id` is
        used to query child mission details.
        '''

        if len(missions) > 0:
            if type(missions[0]) == str:
                self.missions_id = [
                    m_id for m_id in missions
                ]
                # steps_mission can be optionally determined by query when needed
            # end step ids

            else:
                for m_mission in missions:
                    self.missions_mission.append(m_mission)
                    self.missions_id.append(m_mission.id)
            # end steps
        # end if
    # end def

    @override
    def to_dict(self, missions_alias: str = None, depth: int=0) -> Dict:
        d = super().to_dict()

        # non scalar synonymous attributes
        missions_key = missions_alias if missions_alias is not None else 'missions'
        d.update({
            missions_key: self.missions_id,
        })

        if depth > 0:
            d[missions_key] = [
                mission.to_dict(depth=depth-1)
                for mission in self.missions_mission
            ]
        return d

    def add_mission(self, mission: 'Mission') -> bool:
        '''Add a mission to this parent.
        
        :return: `True` if the mission was added to this parent, `False` if the mission was already
        in this parent.
        '''
        if mission.id in self.missions_id:
            logger.info(f'{mission} already in {self}')
            return False
        else:
            self.missions_id.append(mission.id)
            self.missions_mission.append(mission)
            return True
        


class Mission(HasMissions):
    '''Represents a single mission/task.

    Supports json serialize and parse.
    '''

    PERIOD_TYPE_DEFAULT = MissionPeriodType.ONGOING
    MISSIONS_ALIAS = 'steps'

    @classmethod
    def _attr_keys(cls) -> List[str]:
        return [
            'title',
            'type',
            'description',
            'status',
            'deadline',
            'styleId',
            'eventId'
        ] + super()._attr_keys(missions_alias=cls.MISSIONS_ALIAS)
    # end def

    @classmethod
    def _summary_keys(cls) -> int:
        return 2
    # end def

    def __init__(self, **kwargs):
        super().__init__(missions_alias=self.MISSIONS_ALIAS, **kwargs)

        _type = kwargs.get('type', self.PERIOD_TYPE_DEFAULT)
        self.type: MissionPeriodType = (
            _type 
            if type(_type) == MissionPeriodType else
            MissionPeriodType._value2member_map_[_type]
        )
        
        status = kwargs.get('status', MissionStatus.NOT_STARTED)
        self.status: MissionStatus = (
            status
            if type(status) == MissionStatus else
            MissionStatus._value2member_map_[status]
        )

        self.title: str = kwargs['title']
        self.description: Optional[str] = kwargs.get('description')

        deadline: Optional[str] = kwargs.get('deadline')
        self.deadline: Optional[datetime] = None
        if deadline is not None:
            self.deadline = datetime.fromisoformat(deadline)
        # end if

        self.styleId: Optional[str] = kwargs.get('styleId')
        '''Reference to a `ComponentStyle`.
        '''
        self.eventId: Optional[str] = kwargs.get('eventId')
        '''Reference to an `Event`.
        '''
    # end def

    @classmethod
    def from_dict(
        cls, 
        mission: Dict, 
        steps_are_raw=True, 
        title_word_limit: int = 20
    ) -> 'Mission':
        '''Parse mission data as a `Mission` instance.

        TODO derive step titles from raw descriptions using `GeminiClient`.

        :param steps_are_raw: Whether the child missions are provided as raw descriptions.
        '''

        logger.debug(f'create {cls.__name__} from {mission}')

        if steps_are_raw and cls.MISSIONS_ALIAS in mission:
            # convert step descriptions to Mission instances
            steps = []
            for step in mission[cls.MISSIONS_ALIAS]:
                steps.append(Mission(
                    type=mission.get('type', cls.PERIOD_TYPE_DEFAULT),
                    title=' '.join(strings.to_words(step)[:title_word_limit]),
                    description=step,
                    steps=[],
                    deadline=mission.get('deadline')
                ))
            # end for step

            mission['steps'] = steps
        # end if steps raw

        return super().from_dict(mission)
    # end def

    @override
    def to_dict(self, depth: int=0) -> Dict:
        d = super().to_dict(missions_alias=self.MISSIONS_ALIAS)

        # non scalar synonymous attributes
        d.update({
            'type': self.type.value,
            'status': self.status.value,
            'deadline': self.deadline,
            'styleId': self.styleId,
            'eventId': self.eventId
        })

        return d
    # end def
# end class
