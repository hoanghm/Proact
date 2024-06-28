import os
import json
import logging.config

from termcolor import colored
from typing_extensions import override


def init_logging(logger_config_path="logger_config.json"): # default to same directory
    logger_config_path = os.path.abspath(logger_config_path)
    with open(logger_config_path) as f:
        logging_config = json.load(f)
    logging.config.dictConfig(logging_config)
    # logging.info("Gemini logging initialized")


class ColoredFormatter(logging.Formatter):
    @override
    def format(self, record):
        COLORS:dict = {
            'DEBUG': 'green',
            'INFO': 'cyan',
            'WARNING': 'yellow',
            'ERROR': 'red',
            'CRITICAL': 'light_magenta'
        }
        levelname_color = COLORS.get(record.levelname.upper()) or 'white'
        timestamp = self.formatTime(record, self.datefmt)
        loggername = record.name if not record.name.startswith("proact.") else record.name[len("proact."):]

        levelname = colored(f"[{record.levelname}]", levelname_color)
        loggername = colored(f"({loggername})", color='dark_grey')
        timestamp = colored(timestamp, 'light_yellow')
        metadata = f"{levelname}{loggername}{timestamp}"
        record.msg = f"{metadata}: {record.msg}"

        return super().format(record)
    