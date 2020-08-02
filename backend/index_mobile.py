
import flask as flask
from urllib.parse import quote, unquote
import requests
import flask_session as Session
import time
import json
import codecs
import flask_socketio as socketIO
import yay_utils
import os
import MusicRoomSocketMobile
import YAY_Config

app = flask.Flask(__name__)

app_configs  = YAY_Config.get_config()
app.config.from_object(app_configs)
util = yay_utils.Util(flask)
socketio = socketIO.SocketIO(app)
Session.Session(app)
Session.RedisSessionInterface(
    YAY_Config.get_redis(), 'session', permanent=True)

MusicRoomSocket = MusicRoomSocketMobile.MusicRoomSocket('/',flask,util,socketio)
socketio.on_namespace(MusicRoomSocket)

@app.route('/logout')
def logout():
    flask.session.clear()
    return flask.redirect('/')


@app.route('/')
def index():
    flask.session['user_socket_id'] = "TEST"
    return "hello"


if "ON_HEROKU" not in os.environ:
    socketio.run(app,host="0.0.0.0");