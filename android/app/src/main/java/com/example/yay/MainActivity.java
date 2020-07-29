package com.example.yay;

import android.util.Log;

import androidx.annotation.NonNull;

import com.spotify.android.appremote.api.ConnectionParams;
import com.spotify.android.appremote.api.Connector;
import com.spotify.android.appremote.api.SpotifyAppRemote;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    String CLIENT_ID = "c32f7f7b46e14062ba2aea1b462415c9";
    String REDIRECT_URI = "http://com.example.yay/";
    SpotifyAppRemote mSpotifyAppRemote;
    private static final String CHANNEL = "yay.homepage/initSpotify";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                          if (call.method.equals("connect")){
                              connect(true,result);
                              Log.d("spotify sdk connection", "trying to connect");
                          }
                        }
                );
    }


    private void connect(boolean showAuthView,MethodChannel.Result channelResult) {

        SpotifyAppRemote.disconnect(mSpotifyAppRemote);

        SpotifyAppRemote.connect(
                getApplication(),
                new ConnectionParams.Builder(CLIENT_ID)
                        .setRedirectUri(REDIRECT_URI)
                        .showAuthView(showAuthView)
                        .build(),
                new Connector.ConnectionListener() {
                    @Override
                    public void onConnected(SpotifyAppRemote spotifyAppRemote) {
                        mSpotifyAppRemote = spotifyAppRemote;
                        channelResult.success("connection was successful");
                    }

                    @Override
                    public void onFailure(Throwable error) {
                        Log.e("spotify sdk connection","spotify connection failed");
                        Log.e("spotify sdk connection",error.toString());
                        channelResult.success("connection was unsuccessful");

                    }
                });
    }


}
