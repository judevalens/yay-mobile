import time
import requests
import json
import base64
import YAY_Config

class Util():
    my_client_id = 'f44d8cd7efdd4f14b49ce9cc958330fc'
    client_secret = '52ddc9e6b9704750863738a2770c6836'

    def __init__(self, flask):
        self.flask = flask

    def get_valid_spotify_token(self):
        elpasedTime = time.time()-self.flask.session['spotify_token_expiration_date']

        token_duration = self.flask.session['spotify_token_expires_in']

        if elpasedTime >= token_duration:
            credentials  = self.my_client_id+':'+self.client_secret;
            credentials_bytes  = credentials.encode()
            credentials_base64_bytes = base64.urlsafe_b64encode(credentials_bytes)
            credentials_base64 = credentials_base64_bytes.decode()

            authorization = 'Basic ' + credentials_base64
            fresh_token = requests.post('https://accounts.spotify.com/api/token', data={
                'grant_type': 'refresh_token',
                'refresh_token': self.flask.session['spotify_refresh_token']
            }, headers={
                'Authorization': authorization
            })

            fresh_token_response = fresh_token.json()

            self.flask.session['spotify_access_token'] = fresh_token_response['access_token']
            self.flask.session['spotify_token_expiration_date'] = time.time()
            self.flask.session['spotify_token_expires_in'] = int(fresh_token_response['expires_in'])
            return self.flask.session['spotify_access_token']
        else:
            return self.flask.session['spotify_access_token']
    
    def get_user(self):
        """
        return the saved data about the current user
        """
        user = YAY_Config.get_redis().hget('Users', self.flask.session['user_id']).decode('utf-8')

        print("USERRRRRRRRRRRRRRRRRRRRRRR")
        print(user)
        return user

    def set_user(self,user):
        print("BEFORE SET USERRRRRRR")
        print(user)
        user_object = json.dumps(user)
        print("SET USERRRRRRR")
        print(user)
        user = YAY_Config.get_redis().hset('Users', self.flask.session['user_id'],user_object)

    def is_connected(self):
        if 'connected' not in self.flask.session:
            return False
        else:
            return self.flask.session['connected']