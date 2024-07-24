import os
import logging
import base64
from dotenv import load_dotenv

from flask import Flask, request, jsonify
from flask_cors import CORS

from utils import init_logging, set_global_logging_level
from GeminiClient import GeminiClient

from typing import List, Dict

# Load .env & init logging
load_dotenv()
init_logging()
logging.root.setLevel(level=logging.INFO)

# Initalize Flask app
FLASK_APP_NAME = 'gemini-flask'
app = Flask(FLASK_APP_NAME)
cors = CORS(app) # enable cross origin requests for all sources

# Disable flask default loggings
# logging.getLogger('werkzeug').setLevel(logging.ERROR)
# app.logger.setLevel(logging.ERROR)

# Initalizer Gemini client & logger
gemini_client = GeminiClient(
    gemini_api_key=os.getenv("GEMINI_API_KEY"),
    tavily_api_key=os.getenv("TAVILY_API_KEY")
)
logger = logging.getLogger("proact.flask")

# Set logging level for all loggers
set_global_logging_level(logging.INFO)


# Routes
@app.route('/submit_prompt/', methods=['POST'])
def submit_prompt():
    prompt = request.json.get("prompt")
    answer = gemini_client.submit_prompt(prompt)
    return answer


@app.route('/generate_weekly_project/<user_id>', methods=['GET'])
def get_weekly_missions(user_id):
    new_missions:List[Dict] 
    new_missions = gemini_client.generate_weekly_project(
        user=user_id
    )
    response = {
        'new_missions': new_missions
    }
    return jsonify(response)


@app.route('/get_ongoing_missions/<user_id>/<num_missions>', methods=['GET'])
def get_ongoing_missions(user_id, num_missions):
    new_missions:List[Dict] 
    new_missions = gemini_client.get_new_missions_for_user(
        mission_type='ongoing',
        user=user_id,
        num_missions=num_missions
    )
    response = {
        'new_missions': new_missions
    }
    return jsonify(response)

@app.route('/apikey/gemini', methods=['GET'])
def web_on_apikey_gemini():
    """Handle web request for gemini API key.

    Deprecated in favor of accepting prompts from frontend instead of frontend directly prompting gemini.
    """
    return base64.b64encode(os.getenv['GEMINI_API_KEY'].encode('utf-8'))


@app.route('/ping', methods=['GET'])
@app.route('/', methods=['GET'])
def web_on_ping():
    """Handle web request to test connection.
    """
    return 'ping received'



if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
