import collections
import json
import random
import time
import uuid

import flask_socketio
import requests
from flask_socketio import Namespace, emit, join_room, leave_room
from flask_socketio import rooms as user_rooms
from flask_socketio import send
import redis
import YAY_Config
import YAY_Config as conf
import yay_utils
from pymongo import MongoClient
from bson.json_util import dumps


class MusicRoomSocket(Namespace):
    def __init__(self, namespace, flask, util, socket, mongo):
        super().__init__(namespace=namespace)
        print(namespace)

        self.flask = flask
        self.util = util
        self.socket = socket
        self.mongo = mongo

    def on_connect(self):
        self.flask.session['user_socket_id'] = self.flask.request.sid
        """
        Try to re-put the the user in room if he/she was a member.

        On connect check if the user was already in a group, if he/she was, update is socket_address.
        Send the new updated room object to the other participant by emmit "update_room_object"
        """
        # every time a user connects. we should save its socket ID
        print(self.flask.request.event)
        res = {
            "socket_id": self.flask.request.sid,
            "TEST": {
                "WELL": ["12334"]
            }
        }

        emit("connection_config", res)
        print("Connected new member " + self.flask.request.sid)

    def on_login(self, config):
        self.flask.session["user_email"] = config["user_email"]

        print("user mail :" + self.flask.session["user_email"])
        user_db = self.mongo["yay_db"]["users"]
        user = user_db.find_one({"user_email": config["user_email"]})
        # TODO : this can be simpler. it add update then add if no entry is found

        if user is not None:
            user = user_db.update_one({"user_email": config["user_email"]},
                                      {"$set": {"socket_id": self.flask.request.sid}})
        else:
            user_model = {
                "user_email": config["user_email"],
                "socket_id": self.flask.request.sid,
                "rooms": {},
                "current_room_id": ""
            }
            user = user_db.insert_one(user_model)

        rooms_result = None

        if user is not None:
            rooms = self.mongo["yay_db"]["rooms"]
            rooms_result = dumps(list(rooms.find({"$or": [{"owner.user_email": config["user_email"]},
                                                          {"members.email": config["user_email"]}]})))
            print("rooms")
            print(str(rooms_result))

        emit("update_room_list", rooms_result)

        print(str(user) + "\n")

    def on_message(self, msg):
        print("user id " + self.flask.session['user_socket_id'])
        print("socket id " + self.flask.request.sid)
        print(msg)

    def on_create_room(self, room_info):
        """
        Create a new music room.

        Generate a join_code
        create the room object , add the leader socket address
        then send the room object back to the user
        """
        print("CREATE ROOM")

        # generate a five chars join_code, this will be used to invite other members
        n = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

        room_id = 'room_' + str(uuid.uuid4())
        join_code = random.sample(n, 5)
        join_code = ''.join(str(x) for x in join_code)

        # object that contains info abt the room that will be created
        room = {
            'owner': {'user_email': room_info["user_email"], 'socket_id': room_info["socket_id"]},
            'members': [{
            }],
            'time': time.time(),
            'join_code': join_code,
            "is_active": False,
        }

        print("room leader socket_id " + self.flask.request.sid, 'socket_id')

        room_document = self.mongo["yay_db"]["rooms"]

        inserted_room = room_document.insert_one(room)

        res = {
            'isRoomCreated': inserted_room.acknowledged,
            'room': dumps(room),
            'is_leader': True
        }

        # start a socket room for the musicRoom :)
        print("CREATE ROOM ID " + str(inserted_room.inserted_id))
        if inserted_room.acknowledged:
            join_room(inserted_room.inserted_id)
        # send this event to let the user know that his room has been created!
        emit('new_room_created', res)

    def update_room_state(self, room_info):
        print("TRYING TO JOIN")
        response = {

        }
        rooms = self.mongo["yay_db"]["rooms"]
        updatedRoom = None

        if room_info["action"] == "first_time_join":
            updatedRoom = rooms.update_one({"join_code": room_info["join_code"]}, {
                "$push": {"members": {"email": self.flask.session["user_email"], "isActive": False}}})
            active_members = rooms.find_one({"$and": [{"_id": room_info["id"]}, {"members.is_active": True}]})
        elif room_info["action"] == "start_room":
            updatedRoom = rooms.update_one(
                {"$and": [{"_id": room_info["id"]}, {"owner": {"email": self.flask.session["user_email"]}}]},
                {"$set": {"isActive": True}})
        elif room_info["action"] == "close_room":
            pass
        elif room_info["action"] == "join_room":

            pass
        elif room_info["action"] == "leave_room":
            updatedRoom = rooms.update_one({"$and": [{"_id": room_info["id"]},
                                                     {"members.email": self.flask.session["user_email"]},
                                                     {"is_active": False}]}, {
                                               {"$set": {"members.$.is_active": True}}
                                           }, )

        if updatedRoom is not None:
            print("room has been updated")
            print(updatedRoom)

        return response

    def on_set_room_state(self, room_info):
        room = self.mongo["yay_db"]["rooms"].find_one({"_id : " + room_info["id"]}, {"$set": {
            "isActiveTrue": room_info["is_active"]
        }})

    def on_send_data_to_new_member_data(self, data):
        print('on_send_new_member_data')
        emit('sync_player_state', data,
             room=data['member_socket_address'])

    def on_update_room_object(self, room):
        pass

    def on_sync(self, sync_factor):
        if 'track' in sync_factor:
            print(
                "YESSSSSSSSSSSSSSSSSSSSSSSSSSSSYESSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS")
            print(sync_factor['track']['uri'])
            print(sync_factor['track']['position'])
            set_track = requests.put('https://api.spotify.com/v1/me/player/play', json={
                'uris': [sync_factor['track']['uri']]
            }, headers={'Authorization': 'Bearer ' + self.util.get_valid_spotify_token()})
            print("UPDATE TRACK RESULT")
            print(((time.time() * 1000) - float(sync_factor['track']['timeStamp'])))
            print(set_track)

    def on_request_player_state(self, data):
        emit('request_player_state', {'member_socket_address': self.flask.session['user_socket_id']},
             room=data['leader_socket_address'])

    def on_send_data_self_sync(self, data):
        emit('self_sync', data['currentState'], room=data['member_socket_address'], include_self=False)

    def on_player_state_changed(self, data):
        emit('player_state_changed',
             data['currentState'], room=data['room_id'], include_self=False)

    def on_get_audio_analysis(self, data):
        print(data)
        audio_analysis = requests.get("https://api.spotify.com/v1/audio-analysis/" + data['id'],
                                      headers={'Authorization': 'Bearer ' + self.util.get_valid_spotify_token()})
        emit('audio_analysis', audio_analysis.json())

    def on_post_comment(self, data):
        if YAY_Config.get_redis().hexists('comments', data['track_id']):
            comments = YAY_Config.get_redis().hget('comments', data['track_id']).decode('utf-8');

            comments_object = json.loads(comments)
            comment = {
                'comment': data['comment'],
                'user': self.util.get_user(),
                'date': time.time(),
                'song': data['track_id']
            }
            comments_object['comments'].add(comment)

            comments = json.dumps(comments_object);
            YAY_Config.get_redis().hset('comments', data['songID'], comments)
        else:
            comment = {
                'comment': data['comment'],
                'user': yay_utils.get_user(),
                'data': time.time(),
                'song': data['track_id']
            }
            comments_object = {
                'comments': [comment]
            }
            comments = json.dumps(comments_object)
            YAY_Config.get_redis().hset('comments', data['track_id'], comments)
        emit('comment_posted')

    def on_get_comments(self, data):
        comments = YAY_Config.get_redis().hget('comments', data['track_uri']).decode('utf-8')
        comments_object = json.loads(comments)
        emit('load_comments', comments)
