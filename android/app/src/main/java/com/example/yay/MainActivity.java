package com.example.yay;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;

import com.giphy.sdk.core.models.Media;
import com.giphy.sdk.ui.GPHContentType;
import com.giphy.sdk.ui.views.GiphyDialogFragment;
import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.spotify.android.appremote.api.ConnectionParams;
import com.spotify.android.appremote.api.Connector;
import com.spotify.android.appremote.api.SpotifyAppRemote;
import com.spotify.sdk.android.auth.AuthorizationClient;
import com.spotify.sdk.android.auth.AuthorizationResponse;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.net.URISyntaxException;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import io.socket.client.*;
import io.socket.emitter.Emitter;
import timber.log.Timber;

public class MainActivity extends FlutterFragmentActivity implements GiphyDialogFragment.GifSelectionListener{
    String CLIENT_ID = "c32f7f7b46e14062ba2aea1b462415c9";
    String REDIRECT_URI = "http://com.example.yay/";
    SpotifyAppRemote mSpotifyAppRemote;
    private static final String CHANNEL = "yay.homepage/spotify";
    private static final String GIPHY_CHANNEL = "yay.homepage/giphy";
    private static final String PLAY_BACK_STATE_CHANNEL = "playBackStateTunnel";
    private final String SOCKET_ADDRESS = "http://192.168.1.4:5000";
    private io.socket.client.Socket socketio;
    MethodChannel tunnel;
    MethodChannel giphyChannel;
    MethodChannel playBackStateTunnel;
    Spotify spotify;
    MethodChannel.Result loginResult;
    MyGiphy myGiphy;
    String currentChatID;
    @SuppressLint("LogNotTimber")
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        tunnel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        giphyChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), GIPHY_CHANNEL);
        playBackStateTunnel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), PLAY_BACK_STATE_CHANNEL);
        myGiphy = new MyGiphy(this);

        spotify = new Spotify(this,this,tunnel,playBackStateTunnel,myGiphy);
        try {
            SocketIONetwork socketIONetwork = new SocketIONetwork();
        } catch (URISyntaxException e) {
            e.printStackTrace();
        }
        tunnel.setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "connectToSpotifyApp":
                            Timber.d("connectToSpotifyAppRemote");
                           spotify.connectToSpotifyAppRemote(result);
                           break;
                        case "getCode":
                            Timber.d("login with spotify");
                            spotify.getCode();
                            loginResult = result;
                            //result.success("true");
                            break;
                        case "isAppRemoteConnected":
                            boolean isConnected = spotify.mSpotifyAppRemote != null && spotify.mSpotifyAppRemote.isConnected();
                            result.success(isConnected);
                            break;

                    }

                }
        );

        giphyChannel.setMethodCallHandler((call, result) -> {
            if ("showGiphyPad".equals(call.method)) {
                String chatId = (String)(call.arguments);
                currentChatID = chatId;
                Log.d("chat id",currentChatID);
                Timber.d("fetching gif");

                Timber.d("Current chat id %s", currentChatID);
                myGiphy.show(chatId);
            }
        });



    }

    protected void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);

        // Check if result comes from the correct activity
        if (requestCode == Spotify.AUTH_TOKEN_REQUEST_CODE || requestCode == Spotify.AUTH_CODE_REQUEST_CODE) {
            AuthorizationResponse response = AuthorizationClient.getResponse(resultCode, intent);
            switch (response.getType()) {
                // Response was successful and contains auth token
                case CODE:
                    Log.d("get code", "get COde 2");

                    String code = response.getCode();
                    Log.d("spotify login", code);
                        loginResult.success(code);

                    break;
                    // Response was successful and contains auth token
                case TOKEN:
                    Log.d("login", "got result");
                    spotify.accessToken = response.getAccessToken();
                    spotify.accessTokenExpirationDate = response.getExpiresIn();

                    System.out.println("token expires in : " + response.getExpiresIn());

                    if (loginResult != null) {
                        JSONObject tokenResponse = new JSONObject();
                            //spotify.connectToSpotifyAppRemote(con)
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

    @Override
    public void didSearchTerm(@NotNull String s) {

    }

    @Override
    public void onDismissed(@NotNull GPHContentType gphContentType) {
        currentChatID =null;
    }

    @Override
    public void onGifSelected(@NotNull Media media, @Nullable String s, @NotNull GPHContentType gphContentType) {
        Gson gson = new Gson();
       JsonElement mediaJSON =  gson.toJsonTree(media);


        JsonObject giphy = new JsonObject();

        giphy.add("media", mediaJSON);
        giphy.add("contentType", gson.toJsonTree(gphContentType));
        giphy.addProperty("chat_id",currentChatID);
       giphyChannel.invokeMethod("insertMedia",giphy.toString());

    }
}
