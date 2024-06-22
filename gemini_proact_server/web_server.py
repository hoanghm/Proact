"""Proact internal API server.
"""

import os
import logging
from typing import *
from flask import Flask
from flask_cors import CORS
import base64

logger = logging.getLogger('proact-server')

env: Dict[str, str] = {
    'gemini_api_key': None
}

app = Flask(__name__)
# enable cross origin requests for all routes (needed since frontend is not hosted at same domain as this api server)
cors = CORS(app)

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

def run(gemini_api_key: str=None, is_app_factory: bool=False) -> Optional[Flask]:
    env['gemini_api_key'] = gemini_api_key

    if is_app_factory:
        logger.info('return web server to caller')
        return app
    else:
        logger.info('run web server')
        app.run(
            debug=True,
            host='0.0.0.0',
            port=int(os.environ.get('PORT', 8080))
        )
    # end else run now
# end def
