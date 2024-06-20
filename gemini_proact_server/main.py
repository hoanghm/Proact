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
import gemini_client
import web_server

LOG_DIR = 'logs'

logger = logging.getLogger('proact-backend-root')

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
        log_file_timestamp = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H-%M-%S.%f')
        log_file_name = f'{log_file_timestamp}.log'
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
            os.getenv('google_cloud_api_key'),
            os.getenv('google_gemini_api_key')
        )
    # end loaded
# end def

def main(test_gemini: bool):
    init_logging()

    (
        env_is_local,
        google_api_key,
        gemini_api_key
    ) = get_credentials()
    logger.info(f'env_is_local={env_is_local}')

    if google_api_key is None:
        logger.error(f'google api key not found; will not be able to use these services')
    # end if no google api key

    if gemini_api_key is None:
        logger.error(f'gemini api key not found; will not be able to use this AI service')
    else:
        logger.info('test gemini API credentials with a simple gemini prompt')

        if test_gemini:
            # log into gemini api
            gemini_client.login(gemini_api_key)

            req = (
                'tell me 15 different one sentence jokes about a tiger\'s favorite music, '
                'each on a separate line'
            )
            logger.info(f'prompt gemini - {req}')
            print(gemini_client.prompt(req))
        # end if test
        else:
            logger.info('skip gemini API test')
        # end else skip test
    # end else init gemini

    web_server.run(
        gemini_api_key=gemini_api_key
    )
# end def

if __name__ == '__main__':
    # TODO parse cli opts and pass to main
    main(
        test_gemini=False
    )
# end if entrypoint
