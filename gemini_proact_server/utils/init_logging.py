import os
import json
import logging.config

from termcolor import colored
from typing import Literal
from typing_extensions import override


def init_logging(logger_config_path="logger_config.json"): # default to same directory
    '''
    Set the logging configurations for all loggers with names starting with "proact."
    '''
    logger_config_path = os.path.abspath(logger_config_path)
    with open(logger_config_path) as f:
        logging_config = json.load(f)
    logging.config.dictConfig(logging_config)


def set_global_logging_level(level:Literal[10,20,30,40,50]):
    '''
    Set the logging level of all existing loggers

    Args:
        level: 10=DEBUG, 20=INFO, 30=WARNING, 40=ERROR, 50=CRITICAL
    '''
    loggers = [logging.getLogger(name) for name in logging.root.manager.loggerDict]
    for logger in loggers:
        logger.setLevel(logging.DEBUG)


class ColoredFormatter(logging.Formatter):
    '''
    Give some colors to the logging messages
    '''
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
    