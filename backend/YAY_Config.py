import os
import redis


_r = redis.Redis(
    host='redis-15846.c80.us-east-1-2.ec2.cloud.redislabs.com',
    port=15846,
    password='8MXUxPPYs9feyXTLyB74YHl6PmGQ6RxH')


class Config(object):
    SECRET_KEY = b'dsfes30904'
    SESSION_TYPE = 'redis'
    SESSION_REDIS = _r
    SESSION_PERMANENT = False
    SEND_FILE_MAX_AGE_DEFAULT = 0

if "ON_HEROKU"  in os.environ:
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
    return _r
