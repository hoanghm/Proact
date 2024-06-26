"""Gemini API client.
"""
import os
import logging
from attrs import define, field, NOTHING
from typing import List, Callable

import google.generativeai as genai


def init_logger():
    logging.root.setLevel(logging.DEBUG)

    # Create a logger instance
    logger = logging.getLogger('gemini-client')

    # Create a console handler and set its level to INFO
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)  # Only handle INFO level and above messages

    # Create a formatter and add it to the handler
    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s', datefmt="%Y-%m-%d %H:%M:%S"
    )
    console_handler.setFormatter(formatter)

    # Add the handler to the logger
    logger.addHandler(console_handler)
    return logger



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


if __name__ == "__main__":
    from dotenv import load_dotenv
    load_dotenv()
    logger = init_logger()

    client = GeminiClient(
        api_key=os.getenv("GEMINI_API_KEY"),
        logger = logger
    )
    print(client.tools)

    response_text = client.submit_prompt("What is the benefit of Creatine?")
    print(response_text)

