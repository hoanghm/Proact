import re
from typing import *
import json
import base64

REGEXP_SPLIT_WORDS = r'\W+'

def to_words(string) -> List[str]:
    return re.split(REGEXP_SPLIT_WORDS, string)
# end def


def encode_dict_to_base64(d: Dict) -> str:
    d_str = json.dumps(d)
    d_bytes = d_str.encode(encoding='utf-8')
    d_base64_bytes = base64.b64encode(d_bytes)
    d_base64_str = d_base64_bytes.decode(encoding='utf-8')
    return d_base64_str


def decode_base64_to_dict(s: str) -> dict:
    d_bytes = base64.b64decode(s)
    d_str = d_bytes.decode(encoding='utf-8')
    d = json.loads(d_str)
    return d