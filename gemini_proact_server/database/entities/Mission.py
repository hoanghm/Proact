import logging
import json
from enum import Enum
from datetime import datetime
import math
from datetime import datetime

from utils import generate_firestore_id

import attrs
from attrs import define, field, NOTHING
from typing import *
from typing_extensions import override


logger = logging.getLogger('proact.database.mission')


class DefaultValues():
    WEEKLY_MISSION_REGENERATION_MAX = 3
    ONGOING_PROJECT_REGENERATION_MAX = math.inf


class MissionStatus(Enum):
    NOT_STARTED = 'not started'
    IN_PROGRESS = 'in progress'
    DONE = 'done'
    EXPIRED = 'expired'


class MissionPeriodType(Enum): # Only needed for projects
    WEEKLY = 'weekly'
    '''Mission estimated to complete in 1 week.
    '''
    ONGOING = 'ongoing'
    '''Mission does not have a clear duration; deadline is flexible.
    '''

class MissionLevel(Enum):
    PROJECT = 'project'
    MISSION = 'mission'
    STEP = 'step'


@define
class BaseMission():
    '''
    Represents an object in the `Mission` collection that can either be a Project, Mission, or Step
    '''
    title: str = field(default=NOTHING)
    id: str = field(factory=generate_firestore_id, repr=False) # same format as firestore auto-generated ids
    description: str = field(default="", repr=False)
    level: Union[Type[MissionLevel], None] = field(default=None) # will be defined by child classes 
    type: Union[Type[MissionPeriodType], None] = field(default=None) # only applicable to projects
    steps: List['BaseMission'] = field(factory=list, repr=False)
    status: Type[MissionStatus] = field(default=MissionStatus.NOT_STARTED, repr=False)
    deadline: Union[str, None] = field(default=None, repr=False)
    styleId: Union[str, None] = field(default=None, repr=False)
    ecoPoints: int = field(default=0, repr=False)
    CO2InKg: int = field(default=0, repr=False) 
    eventId: Union[str, None] = field(default=None, repr=False)
    regenerationLeft: int = field(default=0, repr=False)
    createdTimestamp: Union[str, None] = field(factory=datetime.now, repr=False)

    @classmethod
    def from_dict(cls, data: dict) -> 'BaseMission':
        return cls(
            **data
        )
        
    
    def add_step(self, step:'BaseMission'):
        '''
        Add a `BaseMission` child to the current `BaseMission` object
        '''
        if not isinstance(step, BaseMission):
            msg = "Step must be an instance of `BaseMission`"
            logger.error(msg)
            raise ValueError("Step must be an instance of `BaseMission`")
        # append new step
        self.steps.append(step)
        # update stats
        self.ecoPoints += step.ecoPoints
        self.CO2InKg += step.CO2InKg


    def add_steps(self, steps:List['BaseMission']):
        for step in steps:
            self.add_step(step)

    
    def to_dict(self):
        d = attrs.asdict(self)
        d.update({
            'steps': [s.id for s in self.steps],
            'status': self.status.value,
            'type': self.type.value if self.type is not None else None,
            'level': self.level.value
        })
        return d



@define
class WeeklyProject(BaseMission):
    '''
    A Weekly Project that consists of missions. For now not much different than BaseMission.
    '''
    type: Type[MissionPeriodType] = MissionPeriodType.WEEKLY
    level: Type[MissionLevel] = MissionLevel.PROJECT
    regenerationLeft: int = field(default=0) # weekly project can't be regenerated


@define 
class OngoingProject(BaseException):
    '''
    An Ongoing Project that consists of ongoing missions. For now not much different than BaseMission.
    '''
    type: Type[MissionPeriodType] = MissionPeriodType.ONGOING
    level: Type[MissionLevel] = MissionLevel.PROJECT
    regenerationleft:int = field(default=DefaultValues.ONGOING_PROJECT_REGENERATION_MAX)


@define
class WeeklyMission(BaseMission):
    '''
    A Mission that consists of steps. For now no different than BaseMission.
    '''
    level: Type[MissionLevel] = MissionLevel.MISSION
    regenerationleft:int = field(default=DefaultValues.WEEKLY_MISSION_REGENERATION_MAX)


@define
class OngoingMission(BaseMission):
    '''
    A Mission that consists of steps. For now no different than BaseMission.
    '''
    level: Type[MissionLevel] = MissionLevel.MISSION
    regenerationleft:int = field(default=0) # Ongoing missions can't be regenerated


@define
class Step(BaseMission):
    '''
    A Step that consists of substeps. For now no different than BaseMission.
    '''
    level: Type[MissionLevel] = MissionLevel.STEP
    regenerationleft:int = field(default=0) # steps can't be regenerated



# test driver
if __name__ == "__main__":
    project = WeeklyProject(
        title="Week 3"
    )

    m1 = WeeklyMission(
        title="Mission 1",
        description="Mission 1 description",
        ecoPoints=10,
        CO2InKg=20
    )
    m2 = WeeklyMission(
        title="Mission 2",
        description="Mission 2 description",
        ecoPoints=5,
        CO2InKg=15
    )

    project.add_steps([m1, m2])