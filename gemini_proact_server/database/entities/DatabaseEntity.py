
import attrs
from attrs import define, field, NOTHING

from typing import Dict, List, Optional
import logging

from utils import generate_firestore_id

logger = logging.getLogger('proact.database.entity')

@define(kw_only=True)
class DatabaseEntity:
    '''
    Abstract superclass for representing db entities/records.
    '''
    id: str = field(factory=generate_firestore_id, repr=False) # same format as firestore auto-generated ids
    
    @classmethod
    def _summary_keys(cls) -> int:
        '''Number of attribute keys from the first in `_attr_keys()` to be included in short representation of this instance.
        Default is 1; only the first attribute is included.
        '''
        return 1


    @classmethod
    def _attr_keys(cls) -> List[str]:
        '''Attribute keys, as populated in db table. Summary keys (important attributes) are first.
        Includes attributes expected to be present in any db entity.
        '''
        return [
            'id'
        ]


    @classmethod
    def table_name(cls) -> str:
        '''DB table/collection name. Default is same as class name.
        '''
        return cls.__name__

