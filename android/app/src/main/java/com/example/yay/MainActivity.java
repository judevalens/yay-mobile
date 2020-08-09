package com.example.yay;

import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;

import com.spotify.android.appremote.api.ConnectionParams;
import com.spotify.android.appremote.api.Connector;
import com.spotify.android.appremote.api.SpotifyAppRemote;
import com.spotify.sdk.android.auth.AuthorizationClient;
import com.spotify.sdk.android.auth.AuthorizationResponse;

import org.json.JSONException;
import org.json.JSONObject;

import java.net.URISyntaxException;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import io.socket.client.*;
import io.socket.emitter.Emitter;

public class MainActivity extends FlutterActivity {
    String CLIENT_ID = "c32f7f7b46e14062ba2aea1b462415c9";
    String REDIRECT_URI = "http://com.example.yay/";
    SpotifyAppRemote mSpotifyAppRemote;
    private static final String CHANNEL = "yay.homepage/spotify";
    private static final String CHANNEL2 = "yay.homepage/backToFront";
    private final String SOCKET_ADDRESS = "http://192.168.1.4:5000";
    private io.socket.client.Socket socketio;
    MethodChannel tunnel;
    Spotify spotify;
    MethodChannel.Result loginResult;
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        spotify = new Spotify(this,this,tunnel);
        tunnel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        tunnel.setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "connect":
                            MainActivity.this.connect(true, result);
                            Log.d("spotify sdk connection", "trying to connect");
                        case "login":
                            Log.d("login", "login with spotify");
                            loginResult = result;
                            spotify.getToken();

                    }
                }
        );

    }

    protected void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);

        // Check if result comes from the correct activity
        if (requestCode == Spotify.AUTH_TOKEN_REQUEST_CODE) {
            AuthorizationResponse response = AuthorizationClient.getResponse(resultCode, intent);


            switch (response.getType()) {
                // Response was successful and contains auth token
                case TOKEN:
                    Log.d("login", "got result");
                    spotify.accessToken = response.getAccessToken();
                    spotify.accessTokenExpirationDate = response.getExpiresIn();

                    if (loginResult != null) {
                        JSONObject tokenResponse = new JSONObject();


                            Connector.ConnectionListener con  = new Connector.ConnectionListener() {
                                @Override
                                public void onConnected(SpotifyAppRemote spotifyAppRemote) {
                                    spotify.mSpotifyAppRemote = spotifyAppRemote;
                                    try {
                                        tokenResponse.put("accessToken",spotify.accessToken);
                                        tokenResponse.put("accessTokenExpirationDate",spotify.accessTokenExpirationDate);
                                        loginResult.success(tokenResponse.toString());
                                        loginResult = null;

                                    } catch (JSONException e) {
                                        e.printStackTrace();
                                    }
                                }

                                @Override
                                public void onFailure(Throwable throwable) {
                                        loginResult.error("loginFailed",null,null);
                                }
                            };

                            spotify.connectToSpotifyAppRemote(con);




                    }
                    // Handle successful response
                    break;

                // Auth flow returned an error
                case ERROR:
                    Log.d("login token", response.getError());

                    // Handle error response
                    break;

                // Most likely auth flow was cancelled
                default:
                    // Handle other cases
            }
        }
    }

    private void connect(boolean showAuthView, MethodChannel.Result channelResult) {

        SpotifyAppRemote.disconnect(mSpotifyAppRemote);

        SpotifyAppRemote.connect(getApplication(), new ConnectionParams.Builder(CLIENT_ID)
                .setRedirectUri(REDIRECT_URI)
                .showAuthView(showAuthView)
                .build(), new Connector.ConnectionListener() {
            @Override
            public void onConnected(SpotifyAppRemote spotifyAppRemote) {
                mSpotifyAppRemote = spotifyAppRemote;
                channelResult.success("connection was successful");
            }

            @Override
            public void onFailure(Throwable error) {
                Log.e("spotify sdk connection", "spotify connection failed");
                Log.e("spotify sdk connection", error.toString());
                channelResult.success("connection was unsuccessful");

            }
        });
    }

    public void connection() {
        try {
            socketio = IO.socket(SOCKET_ADDRESS);

        } catch (URISyntaxException ignored) {

        }

        socketio.on("connection_config", args -> {

        });
    }


}
