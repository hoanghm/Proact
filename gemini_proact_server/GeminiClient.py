"""Gemini API client.
"""
import os
import logging.config

from attrs import define, field, NOTHING
from typing import List, Callable

import google.generativeai as genai


logger = logging.getLogger("gemini_client")

GEMINI_MODEL:dict = {
    "flash": "gemini-1.5-flash" 
}


@define
class GeminiClient:
    
    # inputs
    api_key: str = field(default=NOTHING, eq=True)
    model: str = field(default="flash", eq=str.lower)
    logger: logging.Logger = field(default=logging.getLogger("gemini-client"))
    tools: List[Callable] = field(factory=list)

    # internal
    client: genai.GenerativeModel = field(default=None)

    def __attrs_post_init__(self):
        # define gemini model
        genai.configure(api_key=self.api_key)
        self.client = genai.GenerativeModel(GEMINI_MODEL[self.model])
        logger.info("Gemini client initialized")

    def submit_prompt(self, prompt:str) -> str:
        messages = [
            {"role": "user", "parts": [prompt]}
        ]
        response = self.client.generate_content(messages)
        return response.text


# test driver
if __name__ == "__main__":
    from dotenv import load_dotenv
    from utils import init_logging
    load_dotenv()
    init_logging()
    
    logger = logging.getLogger("gemini_client")

    client = GeminiClient(
        api_key=os.getenv("GEMINI_API_KEY"),
        logger = logger
    )
    logger.info(f"tools: {client.tools}")

    prompt = "What is the benefit of Creatine?"
    logger.info(f"prompt: {prompt}")
    
    # response_text = client.submit_prompt(prompt)
    response_text = "it's good"
    logger.info(f"response: {response_text}")
    
    logger.debug("This is a debug.")
    logger.warning("This is a warning.")
    logger.error("This is an error.")
    logger.critical("This is critical.")

