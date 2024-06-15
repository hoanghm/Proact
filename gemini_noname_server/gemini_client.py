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

    TODO use async and streaming
    """

    res = gemini_model.generate_content(
        contents=req,
        stream=False,
        generation_config=None
    )

    logger.debug(f'received reply from gemini')
    return res.text
# end def
