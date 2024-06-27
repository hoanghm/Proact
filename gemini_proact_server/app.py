import os
import logging
import base64
from dotenv import load_dotenv

from flask import Flask
from flask_cors import CORS

from utils import init_logging
from GeminiClient import GeminiClient

# Load .env & init logging
load_dotenv()
init_logging()


# Initalize Flask app
app = Flask(__name__)
cors = CORS(app) # enable cross origin requests for all sources
app.config.from_object(__name__)
app.config["SECRET_KEY"] = os.getenv("FLASK_SECRET_KEY")

# Initalizer Gemini client & logger
gemini_client = GeminiClient(api_key=os.getenv)
logger = logging.getLogger("flask_server")


# Routes
@app.route('/submit_prompt/', methods=['POST'])
def submit_prompt(self):
    gemini_client = GeminiClient(
        api_key=os.getenv("GEMINI_API_KEY")
    )


'''
Legacy
'''
@app.route('/apikey/gemini', methods=['GET'])
def web_on_apikey_gemini():
    """Handle web request for gemini API key.
    """
    return base64.b64encode(env['gemini_api_key'].encode('utf-8'))


@app.route('/ping', methods=['GET'])
@app.route('/', methods=['GET'])
def web_on_ping():
    """Handle web request to test connection.
    """
    return 'success'



if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
