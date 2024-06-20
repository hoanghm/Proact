import os
import logging
from typing import *
from flask import Flask
import base64

logger = logging.getLogger('proact-server')

env: Dict[str, str] = {
    'gemini_api_key': None
}

app = Flask(__name__)

@app.route('/apikey/gemini', methods=['GET'])
def web_on_apikey_gemini():
    """Handle web request for gemini API key.
    """

    return base64.b64encode(env['gemini_api_key'].encode('utf-8'))
# end def

@app.route('/ping', methods=['GET'])
@app.route('/', methods=['GET'])
def web_on_ping():
    """Handle web request to test connection.
    """

    return 'success'
# end def

def run(port: int = 54321, gemini_api_key: str = None):
    env['gemini_api_key'] = gemini_api_key

    logger.info('run web server')
    app.run(
        debug=True,
        host='0.0.0.0',
        port=int(os.environ.get('web_server_port', port))
    )
# end def
