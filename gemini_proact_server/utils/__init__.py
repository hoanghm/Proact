'''Uncategorized utilities.
'''

from utils.init_logging import init_logging, ColoredFormatter, set_global_logging_level
from utils.firestore_utils import generate_firestore_id
from utils.strings import encode_dict_to_base64, decode_base64_to_dict

__all__ = [
    "init_logging",
    "ColoredFormatter",
    "set_global_logging_level",
    "generate_firestore_id",
    "encode_dict_to_base64",
    "decode_base64_to_dict"
]