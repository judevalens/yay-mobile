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


class MusicRoomSocket(Namespace):
    def __init__(self, namespace, flask, util, socket):
        super().__init__(namespace=namespace)
        print(namespace)

        self.flask = flask
        self.util = util
        self.socket = socket
        self.redis = conf.get_redis()
        self.mongo = MongoClient(
            "mongodb+srv://judevalens:2nOMHL7MLIwLQwvR@cluster0.yuzkw.mongodb.net/yay?retryWrites=true&w=majority")

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
        user_db = self.mongo["yay_db"]["users"]
        user = user_db.find_one({"email": config["user_email"]})

        if user is not None:
            user_db.update_one({"email": config["user_email"]}, {"$set": {"socket_id": self.flask.request.sid}})
        else:
            user_model = {
                "user_email": config["user_email"],
                "socket_id": self.flask.request.sid,
                "rooms": {},
                "current_room_id": ""
            }
            user_db.insert_one(user_model)

        print(str(user) + "\n")

    def on_message(self, msg):
        print("user id " + self.flask.session['user_socket_id'])
        print("socket id " + self.flask.request.sid)
        print(msg)

    def on_create_room(self, leader_info):
        """
        Create a new music room.

        Genereate a join_code
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
            'room_id': room_id,
            'leader': {'id': leader_info['id'], 'socket_address': leader_info['socket_address']},
            'member': {},
            'time': time.time(),
            'join_code': join_code,
            "active": True
        }

        print("room leader socket address " + leader_info['socket_address'], 'socket_address')

        # add the room_id to the join_code table, so new member can join
        YAY_Config.get_redis().hset('join_code', str(join_code), room_id)
        # store the rooms in the database
        room_object = json.dumps(room)
        YAY_Config.get_redis().hset('Rooms', room_id, room_object)
        response = {
            'status': 'CREATE_ROOM_OK',
            'room': room,
            'is_leader': True
        }

        # start a socket room for the musicRoom :)
        print("CREATE ROOM ID " + str(room_id))
        join_room(str(room_id))

        # send this event to let the user know that his room has been created!
        emit('room_event', response)

    def on_join_room(self, room_info):
        print("TRYING TO JOIN")
        join_code = room_info["join_code"]
        global response
        response = {

        }
        print(join_code)
        code_exist = YAY_Config.get_redis().hexists('join_code', join_code)
        if code_exist:
            room_id = YAY_Config.get_redis().hget('join_code', join_code).decode(encoding='utf-8')
            room = YAY_Config.get_redis().hget('Rooms', room_id).decode(encoding='utf-8')
            room_object = json.loads(room)

            # add the user id and socket address to member of the room_object
            room_object['member'][room_info['id']] = {'id': room_info['id'],
                                                      'socket_address': room_info['socket_address']}
            response['status'] = 'JOIN_ROOM_OK'
            response['room'] = room_object
            response['is_leader'] = False

            # join the socket room
            join_room(str(room_object['room_id']))
            print("joining " + room_object['room_id'])

            room = json.dumps(room_object)
            YAY_Config.get_redis().hset('Rooms', room_id, room)

            # send an event to the other members, so they can update the room_object, acknowledging the new member
            print("ROOM ID " + str(room_id))
            emit('room_event', response, room=room_id, include_self=True)

            # send this event to room leader, so he can send the state of the current song being played to the new member

            print("room leader socket address " + room_object['leader']['socket_address'])

            emit('send_state', {
                'member_socket_address': room_info["socket_address"],
                'room': room_object,
                'status': "SYNC_PLAYER_STATE"
            }, room=room_object['leader']['socket_address'])
        else:
            # if room does exit, we let the user know that!
            response['status'] = 'failed'
            response['error_msg'] = 'room does not exist'

        print(response['status'] + " STATUS")

        return response

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
