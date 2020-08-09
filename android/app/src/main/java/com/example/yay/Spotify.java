package com.example.yay;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.google.gson.Gson;
import com.spotify.android.appremote.api.ConnectionParams;
import com.spotify.android.appremote.api.Connector;
import com.spotify.android.appremote.api.SpotifyAppRemote;
import com.spotify.android.appremote.api.SpotifyAppRemote;

import com.spotify.protocol.client.CallResult;
import com.spotify.protocol.client.Subscription;
import com.spotify.protocol.types.PlayerState;
import com.spotify.protocol.types.Track;
import com.spotify.sdk.android.auth.AuthorizationClient;
import com.spotify.sdk.android.auth.AuthorizationRequest;
import com.spotify.sdk.android.auth.AuthorizationResponse;


import org.json.JSONException;
import org.json.JSONObject;

import java.util.concurrent.CompletableFuture;

import dataClass.User.User;
import io.flutter.plugin.common.MethodChannel;
import io.socket.client.Socket;

public class Spotify {
    public static final int AUTH_TOKEN_REQUEST_CODE = 0x10;
    public static final int AUTH_CODE_REQUEST_CODE = 0x11;
    private static final String CLIENT_ID = "c32f7f7b46e14062ba2aea1b462415c9";
    private static final String REDIRECT_URI = "http://com.example.yay/";
    private final String SOCKET_ADDRESS = "http://192.168.1.3:5000";
    public User user;
    public String accessToken;
    public int accessTokenExpirationDate;
    public SpotifyAppRemote mSpotifyAppRemote;
    private Context context;
    private Activity activity;
    private Socket socket;
    private Gson gson = new Gson();
    MethodChannel tunnel;


    public Spotify(Context mContext, Activity activity, MethodChannel tunnel) {
        this.context = mContext;
        this.activity = activity;
        this.tunnel  = tunnel;
    }

    public void connectToSpotifyAppRemote(Connector.ConnectionListener con) {
        ConnectionParams connectionParams =
                new ConnectionParams.Builder(CLIENT_ID)
                        .setRedirectUri(REDIRECT_URI)
                        .showAuthView(true)
                        .build();
        SpotifyAppRemote.connect(context, connectionParams,
                con);
    }

    private void initPlayer() {

        activity.getFilesDir();
        //// mSpotifyAppRemote.getPlayerApi().play("spotify:playlist:37i9dQZF1DX2sUQwD7tbmL");

        // Subscribe to PlayerState
        mSpotifyAppRemote.getPlayerApi()
                .subscribeToPlayerState()
                .setEventCallback(new Subscription.EventCallback<PlayerState>() {
                    @Override
                    public void onEvent(PlayerState playerState) {
                        final Track track = playerState.track;
                        if (track != null) {
                            Log.d("MainActivity", track.name + " by " + track.artist.name);
                        }
                    }
                });
    }




    public void getToken(){
        AuthorizationRequest.Builder builder  = new AuthorizationRequest.Builder(CLIENT_ID, AuthorizationResponse.Type.TOKEN,REDIRECT_URI);

        builder.setScopes(new String[]{"user-read-email","user-read-private","app-remote-control"});
        AuthorizationRequest request = builder.build();


        AuthorizationClient.openLoginActivity(activity, AUTH_TOKEN_REQUEST_CODE, request);

    }

    public void update(){
        mSpotifyAppRemote.getPlayerApi().subscribeToPlayerState().setEventCallback(new Subscription.EventCallback<PlayerState>() {
            @Override
            public void onEvent(PlayerState playerState) {
                String playerStateJson = gson.toJson(playerState);
                tunnel.invokeMethod("updatePlayerState",playerStateJson);
            }
        });
    }



    public void getPlayerState() {
        mSpotifyAppRemote.getPlayerApi().getPlayerState().setResultCallback(new CallResult.ResultCallback<PlayerState>() {
            @Override
            public void onResult(PlayerState playerState) {

            }
        });
    }

    public void getCurrentPosition(){
       new Runnable ()  {

           @Override
           public void run() {
               while (true){

                   mSpotifyAppRemote.getPlayerApi().getPlayerState().setResultCallback(playerState -> {

                   });
                   try {
                       Thread.sleep(100);
                   } catch (InterruptedException e) {
                       e.printStackTrace();
                   }
               }
           }

       };
    }

    private void executor(Runnable r) {
        Thread t = new Thread(r);
        t.start();
    }

    public void onClearCredentialsClicked() {
        AuthorizationClient.clearCookies(context);
    }
    private void stop() {
        SpotifyAppRemote.disconnect(mSpotifyAppRemote);
    }
}
