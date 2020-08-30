import flask as flask
from urllib.parse import quote, unquote
import requests
import flask_session as session
import time
import json
import codecs
import flask_socketio as socketio
from pymongo import MongoClient

import yay_utils
import os
import MusicRoomSocketMobile
import YAY_Config
import eventlet

app = flask.Flask(__name__)

app_configs = YAY_Config.get_config()
SESSION_TYPE = 'mongodb'

app.config.from_object(app_configs)
util = yay_utils.Util(flask)
socketio = socketio.SocketIO(app, logger=True)

session.Session(app)

MusicRoomSocket = MusicRoomSocketMobile.MusicRoomSocket(
    '/', flask, util, socketio, YAY_Config.mongo_client)
socketio.on_namespace(MusicRoomSocket)


@app.route('/logout')
def logout():
    flask.session.clear()
    return "flask.redirect('/')"


@app.route('/')
def index():
    print("hello")
    flask.session['user_socket_id'] = "TEST"
    return "hello"


socketio.run(app, host="0.0.0.0")
