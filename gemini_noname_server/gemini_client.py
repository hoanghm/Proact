"""Gemini AI client.

Note this is a python server implementation, but we will probably not use it much, in favor of
prompting gemini from the frontend using the 
[dart/flutter SDK](https://ai.google.dev/gemini-api/docs/quickstart?lang=dart).
"""

import google.generativeai as genai
import logging

class Model:
    FLASH = 'gemini-1.5-flash'
# end class

logger = logging.getLogger('gemini-client')
gemini_model = genai.GenerativeModel(model_name=Model.FLASH)

def login(api_key: str):
    """Log in as gemini client.
    """

    genai.configure(api_key=api_key)
    logger.info(f'logged into gemini api')
# end def

def prompt(req: str) -> str:
    """Send gemini a prompt and return the response.

    TODO use async
    """

    res = gemini_model.generate_content(
        contents=req,
        stream=True,
        generation_config=None
    )

    logger.debug(f'received reply from gemini')
    out_str = ''
    c_idx = 0
    for res_chunk in res:
        logger.debug(f'fetch gemini reply part-{c_idx}')
        try:
            out_str += res_chunk.text
            c_idx += 1
        except ValueError as e:
            logger.error(f'failed to fetch gemini response part-{c_idx}. {e}')
            out_str += ' <fetch-error-eof>'
            break
    # end for

    return out_str
# end def
