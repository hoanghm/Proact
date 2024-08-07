import os
import logging
import base64
from dotenv import load_dotenv
from functools import wraps

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


def authentication_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        api_key = request.headers.get('Authorization')

        if api_key is None:
            return jsonify({"message": "API Key required."}), 401

        if api_key != os.getenv("FLASK_SECRET_KEY"):
            return jsonify({"message": "Invalid API Key provided."}), 401

        return f(*args, **kwargs)
    
    return decorated_function


# Routes
@app.route('/submit_prompt/', methods=['POST'])
def submit_prompt():
    prompt = request.json.get("prompt")
    answer = gemini_client.submit_prompt(prompt)
    return answer


@app.route('/generate_weekly_project/<user_id>', methods=['GET'])
@authentication_required
def get_weekly_missions(user_id):
    # first check if an active weekly project already exists
    if gemini_client.fb_client.user_has_existing_weekly_project(user_id):
        response = {
            'status': 'failed',
            'message': f"User '{user_id}' already has an active weekly project"
        }
    else: # generate a new weekly project
        weekly_project = gemini_client.generate_weekly_project(
            user_id=user_id
        )
        response = {
            'status': 'success',
            'project_id': weekly_project.id
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
