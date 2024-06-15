"""Gemini noname app server entrypoint.
"""

from typing import *
from dotenv import load_dotenv
import os
import sys
import logging
from datetime import datetime, timezone
import traceback
import misc

LOG_DIR = 'logs'

logger = logging.getLogger('gemini-noname-server')

def init_logging():
  # TODO control log level w cli opt
  logging.root.setLevel(logging.DEBUG)

  formatter = logging.Formatter(
    fmt='{levelname} {name}: {message} [@{funcName} #{lineno}]',
    style='{'
  )

  handler_cli = logging.StreamHandler(sys.stdout)
  handler_cli.setFormatter(formatter)
  logging.root.addHandler(handler_cli)
  logger.debug(f'attached cli log handler')

  try:
    os.makedirs(LOG_DIR, exist_ok=True)
    log_file_name = f'{datetime.now(timezone.utc).strftime('%Y-%m-%dT%H-%M-%S.%f')}.log'
    log_file_path = os.path.join(LOG_DIR, log_file_name)
    handler_file = logging.FileHandler(
      filename=log_file_path
    )
    handler_file.setFormatter(formatter)
    logging.root.addHandler(handler_file)
    logger.debug(f'attached file log handler writing to {log_file_path}')
  except BaseException as e:
    logger.error(f'unable to attach file log handler. {e}')
    logger.debug(traceback.format_exc())
# end def

def get_credentials() -> Tuple[bool, str]:
  """Load static secrets, credentials, etc.
  """ 

  try:
    logger.debug('get static credentials from dot-env')
    dotenv_is_loaded = load_dotenv(
      dotenv_path='./.env'
    )
  except BaseException as e:
    logger.warning('unable to read dot-env file; assume credentials already set in env vars. {e}')
    logger.debug(traceback.format_exc())
    # act as if dot-env loaded
    dotenv_is_loaded = True

  if not dotenv_is_loaded:
    raise LookupError('failed to load credentials from dot-env file')
  else:
    return (
      misc.primitive_to_bool(os.getenv('env_is_local', 'true')),
      os.getenv('google_cloud_api_key')
    )
  # end loaded
# end def

def main():
  init_logging()

  (
    env_is_local,
    google_api_key
  ) = get_credentials()
  logger.info(f'env_is_local={env_is_local}')

  if google_api_key is None:
    logger.error(f'google api key not found; will not be able to use these services')
  # end if no google api key

  logger.info('end main')
# end def

# TODO parse cli opts and pass to main
main()
