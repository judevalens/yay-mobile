import os
import redis
from pymongo import MongoClient

yay_redis = redis.Redis(
    host='redis-15846.c80.us-east-1-2.ec2.cloud.redislabs.com',
    port=15846,
    password='8MXUxPPYs9feyXTLyB74YHl6PmGQ6RxH')
mongo_client = MongoClient(
    "mongodb+srv://judevalens:2nOMHL7MLIwLQwvR@cluster0.yuzkw.mongodb.net/yay?retryWrites=true&w=majority")


class Config(object):
    SECRET_KEY = b'dsfwvccxces30904'
    SESSION_TYPE = 'mongodb'
    SESSION_MONGODB = mongo_client
    SESSION_MONGODB_DB = "yay_db"
    SESSION_MONGODB_COLLECT = "sessions"


if "ON_HEROKU" in os.environ:
    class Heroku(Config):
        ROOT_URL = os.environ['ROOT_URL']
        ENV = 'development'
        TESTING = True


class Local(Config):
    ROOT_URL = 'http://127.0.0.1:5000'
    ENV = 'development'
    TESTING = True


def get_config():
    if "ON_HEROKU" not in os.environ:
        return Local
    else:
        return Heroku()


def get_redis():
    return yay_redis
