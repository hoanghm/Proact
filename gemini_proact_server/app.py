import os
import logging
import base64
from dotenv import load_dotenv

from flask import Flask, request
from flask_cors import CORS

from utils import init_logging
from GeminiClient import GeminiClient

# Load .env & init logging
load_dotenv()
logging.basicConfig(level=logging.INFO)
init_logging()


# Initalize Flask app
FLASK_APP_NAME = 'gemini-flask'
app = Flask(FLASK_APP_NAME)
cors = CORS(app) # enable cross origin requests for all sources

# Disable flask default loggings
# logging.getLogger('werkzeug').setLevel(logging.ERROR)
# app.logger.setLevel(logging.ERROR)


# Initalizer Gemini client & logger
gemini_client = GeminiClient(api_key=os.getenv("GEMINI_API_KEY"))
logger = logging.getLogger("proact.flask")


# Routes
@app.route('/submit_prompt/', methods=['POST'])
def submit_prompt():
    prompt = request.json.get("prompt")
    answer = gemini_client.submit_prompt(prompt)
    return answer

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
