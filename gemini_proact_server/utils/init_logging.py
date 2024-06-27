import os
import json
import logging.config

from termcolor import colored


def init_logging(logger_config_path="logger_config.json"): # default to same directory
    logger_config_path = os.path.abspath(logger_config_path)
    with open(logger_config_path) as f:
        logging_config = json.load(f)
    logging.config.dictConfig(logging_config)
    # logging.info("Gemini logging initialized")


class ColoredFormatter(logging.Formatter):
    
    def format(self, record):
        COLORS:dict = {
            'DEBUG': 'green',
            'INFO': 'white',
            'WARNING': 'yellow',
            'ERROR': 'red',
            'CRITICAL': 'light_magenta'
        }
        color = COLORS.get(record.levelname.upper()) or 'white'
        timestamp = self.formatTime(record, self.datefmt)

        metadata = f"[{record.levelname}|{record.name}|L{record.lineno}] {timestamp}"
        record.msg = colored(f"{metadata}: {record.msg}", color)

        return super().format(record)
    