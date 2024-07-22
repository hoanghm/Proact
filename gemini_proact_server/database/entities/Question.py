import logging
from enum import Enum

from .DatabaseEntity import DatabaseEntity

from typing import Dict, List, Optional
from typing_extensions import override


logger = logging.getLogger('proact.database.question')

class QuestionType(Enum):
    SHORT_ANSWER = 'shortAnswer'
    NUMBER = 'number'
    YES_NO = 'yesNo'
# end class

class Question(DatabaseEntity):
    '''Question for a user to gather profile information.
    '''

    TYPE_DEFAULT = QuestionType.SHORT_ANSWER

    @override
    @classmethod
    def _attr_keys(cls) -> List[str]:
        return [
            'title',
            'onboard',
            'type',
            'description'
        ] + super()._attr_keys()
    # end def

    @override
    @classmethod
    def _summary_keys(cls) -> int:
        return 2
    # end def

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.title: str = kwargs['title']
        self.onboard: bool = kwargs.get('onboard', False)
        _type = kwargs.get('type', self.TYPE_DEFAULT)
        self.type: QuestionType = (
            _type 
            if type(_type) == QuestionType else
            QuestionType._value2member_map_[_type]
        )
        self.description: Optional[str] = kwargs.get('description')
    # end def

    @override
    def to_dict(self) -> Dict:
        d = super().to_dict()

        d.update({
            'type': self.type.value
        })

        return d
    # end def
# end class

class UserQuestion(DatabaseEntity):
    '''Question answered by a user.

    `id` is the index in the user's questions list.
    '''

    @override
    @classmethod
    def _attr_keys(cls) -> List[str]:
        return super()._attr_keys() + [
            'questionId',
            'answer'
        ]
    # end def

    @override
    @classmethod
    def _summary_keys(cls) -> int:
        return 3
    # end def

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

        self.questionId: str = kwargs['questionId']
        '''Reference to `Question` instance.
        '''
        self.question: Optional[Question] = kwargs.get('question')
        '''A `Question` instance. 
        
        This will be populated after fetching `questionId`.
        '''
        self.answer: Optional[str] = kwargs.get('answer')
    # end def
# end class