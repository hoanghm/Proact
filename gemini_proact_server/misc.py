"""Uncategorized utilities.
"""

import logging

def primitive_to_bool(s: str) -> bool:
  if type(s) == str:
    return s.strip().lower() == 'true'
  elif type(s) == int:
    return s > 0
  else:
    raise TypeError(f'cannot cast {s} of type {type(s)} to boolean')
# end def
