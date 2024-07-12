import re
from typing import *

REGEXP_SPLIT_WORDS = r'\W+'

def to_words(string) -> List[str]:
    return re.split(REGEXP_SPLIT_WORDS, string)
# end def
