"""Gemini API client.
"""
import os
import time
import logging.config
from tenacity import retry, wait_fixed, stop_after_attempt


from attrs import define, field, NOTHING
from typing import List, Callable, Union

import google.generativeai as genai


GEMINI_MODEL:dict = {
    "flash": "gemini-1.5-flash" 
}


@define
class GeminiClient:
    
    # inputs
    api_key: str = field(default=NOTHING, eq=True)
    model: str = field(default="flash", eq=str.lower)
    tools: List[Callable] = field(factory=list)
    logger: logging.Logger = field(default=logging.getLogger("proact.gemini_client"))

    # internal
    client: Union[genai.GenerativeModel, None] = field(default=None)

    def __attrs_post_init__(self):
        # define gemini model
        genai.configure(api_key=self.api_key)
        self.client = genai.GenerativeModel(GEMINI_MODEL[self.model])
        self.logger.info("Gemini client initialized")

    @retry(wait=wait_fixed(2), stop=stop_after_attempt(3))
    def submit_prompt(self, prompt:str) -> str:
        self.logger.debug(f"Received prompt: {prompt}")
        start_time = time.perf_counter()
        
        # format message and send to gemini api
        messages = [
            {"role": "user", "parts": [prompt]}
        ]
        response = self.client.generate_content(messages)
        response_text = response.text
        
        # get elapsed time and log answer
        elapsed_time = time.perf_counter() - start_time
        self.logger.debug(f"Answer ({elapsed_time:.2f}s): {response_text[:50]}...")
        return response_text


# test driver
if __name__ == "__main__":
    from dotenv import load_dotenv
    from utils import init_logging
    load_dotenv()
    init_logging()

    client = GeminiClient(
        api_key=os.getenv("GEMINI_API_KEY")
    )

    prompt = "What is the benefit of Creatine?"
    
    # response_text = client.submit_prompt(prompt)
    response_text = "it's good"
    
    client.logger.debug("This is a debug.")
    client.logger.warning("This is a warning.")
    client.logger.error("This is an error.")
    client.logger.critical("This is critical.")

