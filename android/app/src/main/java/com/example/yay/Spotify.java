package com.example.yay;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.spotify.android.appremote.api.ConnectionParams;
import com.spotify.android.appremote.api.Connector;
import com.spotify.android.appremote.api.ImagesApi;
import com.spotify.android.appremote.api.SpotifyAppRemote;

import com.spotify.protocol.client.CallResult;
import com.spotify.protocol.client.Subscription;
import com.spotify.protocol.types.ImageUri;
import com.spotify.protocol.types.PlayerState;
import com.spotify.sdk.android.auth.AuthorizationClient;
import com.spotify.sdk.android.auth.AuthorizationRequest;
import com.spotify.sdk.android.auth.AuthorizationResponse;

import com.spotify.protocol.types.Image.Dimension;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Objects;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import okhttp3.FormBody;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import timber.log.Timber;


public class Spotify {
    static final MediaType JSON = MediaType.get("application/x-www-form-urlencoded");
    public static final int AUTH_TOKEN_REQUEST_CODE = 0x10;
    public static final int AUTH_CODE_REQUEST_CODE = 0x11;
    private static final String CLIENT_ID = "";
    private static final String CLIENT_SECRET = "";

    private static final String REDIRECT_URI = "http://com.example.yay/";
    private final String SOCKET_ADDRESS = "http://192.168.1.3:5000";
    public String accessToken;
    public int accessTokenExpirationDate;
    public SpotifyAppRemote mSpotifyAppRemote;
    public ImagesApi imagesApi;
    private Context context;
    private Activity activity;
    private Gson gson = new Gson();
    MethodChannel tunnel;
    MethodChannel playBackStateTunnel;


    Subscription<PlayerState> playerStateSubscription;
    private static final String SUBSCRIBE_TO_PLAYBACK_STATE  = "SubscribeToPlayBackState";
    private static final String  UNSUBSCRIBE_TO_PLAYBACK_STATE = "UnSubscribeToPlayBackState";
    private static final String  MC_UPDATE_METHOD_NAME = "updatePlayerState";
    private static  final String MC_START = "start";
    private static  final String MC_RESUME = "resume";
    private static  final String MC_PAUSE = "pause";
    private static  final String MC_SEEK = "seek";
    private static  final String MC_NEXT = "next";
    private static  final String MC_PREV = "prev";
    private static final String MC_GET_ARTWORK = "artwork";
    private static final String MC_GET_PLAY_BACK_STATE = "getPlayBackState";

    private long playerStateTimeStamp = 0;
    private long newPlayerStateThreshold = 250;
    MyGiphy myGiphy;
    public Spotify(Context mContext, Activity activity, MethodChannel tunnel,MethodChannel playBackStateTunnel, MyGiphy myGiphy) {
        this.context = mContext;
        this.activity = activity;
        this.tunnel = tunnel;
        this.playBackStateTunnel = playBackStateTunnel;
        this.myGiphy = myGiphy;
        setUpPlayBackChannel();
    }

    public void connectToSpotifyAppRemote(MethodChannel.Result connectToSpotifyAppRemoteResult) {
            if (playerStateSubscription != null){
                playerStateSubscription.cancel();
            }
            if (mSpotifyAppRemote != null){
                SpotifyAppRemote.disconnect(mSpotifyAppRemote);
            }

        if (mSpotifyAppRemote != null && mSpotifyAppRemote.isConnected() ) {
            connectToSpotifyAppRemoteResult.success(true);
            return;
        }
            ConnectionParams connectionParams =
                    new ConnectionParams.Builder(CLIENT_ID)
                            .setRedirectUri(REDIRECT_URI)
                            .showAuthView(true)
                            .build();
            SpotifyAppRemote.connect(context, connectionParams,
                    new Connector.ConnectionListener() {
                        @Override
                        public void onConnected(SpotifyAppRemote spotifyAppRemote) {

                            mSpotifyAppRemote = spotifyAppRemote;
                            imagesApi = mSpotifyAppRemote.getImagesApi();
                            new Handler(Looper.getMainLooper()).post(new Runnable() {
                                @Override
                                public void run() {

                                    if (connectToSpotifyAppRemoteResult != null) {
                                        connectToSpotifyAppRemoteResult.success(true);
                                    }
                                }
                            });

                        }

                        @Override
                        public void onFailure(Throwable throwable) {
                            if (connectToSpotifyAppRemoteResult != null) {
                              connectToSpotifyAppRemoteResult.error("loginFailed", null, null);

                            }
                        }
                    });



    }


    private void setUpPlayBackChannel(){
        playBackStateTunnel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                switch (call.method){
                    case SUBSCRIBE_TO_PLAYBACK_STATE:
                        subscribeToPlayBackState();
                        result.success(null);
                        break;
                    case UNSUBSCRIBE_TO_PLAYBACK_STATE:
                        UnSubscribeToPlayBackState();
                        result.success(null);
                        break;
                    case MC_START:
                        if (mSpotifyAppRemote != null && mSpotifyAppRemote.isConnected()){
                            String trackID = (String) call.arguments;
                            Log.d("spotify", "spot " + trackID);
                            mSpotifyAppRemote.getPlayerApi().play(trackID);
                        }
                        break;
                    case MC_RESUME:
                        if (mSpotifyAppRemote != null && mSpotifyAppRemote.isConnected()){
                            mSpotifyAppRemote.getPlayerApi().resume();
                        }
                        break;
                    case MC_PAUSE:
                        if (mSpotifyAppRemote != null && mSpotifyAppRemote.isConnected()){
                            mSpotifyAppRemote.getPlayerApi().pause();
                        }
                        break;
                    case MC_SEEK:
                        long pos = (long)((double)call.arguments);
                        if (mSpotifyAppRemote != null && mSpotifyAppRemote.isConnected()){
                            mSpotifyAppRemote.getPlayerApi().seekTo(pos);
                        }
                        break;
                    case MC_NEXT:
                        if (mSpotifyAppRemote != null && mSpotifyAppRemote.isConnected()){
                            mSpotifyAppRemote.getPlayerApi().skipNext();
                        }
                        break;
                    case MC_PREV:
                        if (mSpotifyAppRemote != null && mSpotifyAppRemote.isConnected()){
                            mSpotifyAppRemote.getPlayerApi().skipPrevious();
                        }
                        break;
                    case MC_GET_ARTWORK:
                        Log.d("MC", "onMethodCall: getting bitmap");
                        getImage((String) call.arguments,Dimension.LARGE,result);
                        break;
                    case MC_GET_PLAY_BACK_STATE:
                        getPlayBackState(result);
                        break;


                }
            }
        });
    }

    public void getCode() {
        AuthorizationRequest.Builder builder = new AuthorizationRequest.Builder(CLIENT_ID, AuthorizationResponse.Type.CODE, REDIRECT_URI);
        builder.setScopes(new String[]{"user-read-email", "user-read-private", "app-remote-control", "playlist-read-private" ,"playlist-read-collaborative", "user-follow-read", "user-top-read"});
        AuthorizationRequest request = builder.build();
        AuthorizationClient.openLoginActivity(activity, AUTH_CODE_REQUEST_CODE, request);
        Log.d("get code", "get COde");
    }

    public void requestToken(String code, MethodChannel.Result loginResult) throws IOException {

        executor(new Runnable() {
            @Override
            public void run() {
                OkHttpClient client = new OkHttpClient();
                String url = "https://accounts.spotify.com/api/token";
                Request.Builder req = new Request.Builder();
                String Authorization = CLIENT_ID + ":" + CLIENT_SECRET;
                String b64ClientID = android.util.Base64.encodeToString(Authorization.getBytes(), android.util.Base64.NO_WRAP);
                req.addHeader("Authorization", " Basic " + b64ClientID);

                FormBody.Builder reqBody = new FormBody.Builder();

                reqBody.add("grant_type", "authorization_code");
                reqBody.add("code", code);
                reqBody.add("redirect_uri", REDIRECT_URI);


                Log.d("response", reqBody.build().contentType() + " response");

                req.post(reqBody.build()).url(url);


                try {
                    Response response = client.newCall(req.build()).execute();
                    new Handler(Looper.getMainLooper()).post(new Runnable() {
                        @Override
                        public void run() {
                            if (loginResult != null) {
                                if (response.isSuccessful()) {
                                    try {
                                        loginResult.success(Objects.requireNonNull(response.body()).string());
                                    } catch (IOException e) {
                                        e.printStackTrace();
                                    }
                                } else {
                                    loginResult.success("req failed");
                                }

                            }
                        }
                    });

                } catch (IOException e) {
                    e.printStackTrace();
                }


            }
        });


    }

    public void refreshToken(String code, MethodChannel.Result response){

    }


    public void getToken() {
        System.out.println("getting token");
        AuthorizationRequest.Builder builder = new AuthorizationRequest.Builder(CLIENT_ID, AuthorizationResponse.Type.TOKEN, REDIRECT_URI);
        builder.setScopes(new String[]{"user-read-email", "user-read-private", "app-remote-control"});
        AuthorizationRequest request = builder.build();
        AuthorizationClient.openLoginActivity(activity, AUTH_TOKEN_REQUEST_CODE, request);

    }

    public void subscribeToPlayBackState() {
        playerStateSubscription  = mSpotifyAppRemote.getPlayerApi().subscribeToPlayerState().setEventCallback(new Subscription.EventCallback<PlayerState>() {
            @Override
            public void onEvent(PlayerState playerState) {
                boolean isBrandNewState = (System.currentTimeMillis()-playerStateTimeStamp) >= newPlayerStateThreshold;
                playerStateTimeStamp = System.currentTimeMillis();
                Log.d("spotify playback", "spotify playback : player state changed!!!!!!");
                Log.d("spotify playback", "spotify playback : player is null " + (playerState == null));
                Log.d("spotify playback", "spotify playback: isPaused : " + playerState.isPaused);
                Log.d("spotify playback", "spotify playback: playback timestamp " + System.currentTimeMillis());
                Log.d("spotify playback", "spotify playback: isBrandNewState :" + isBrandNewState);
                Log.d("spotify playback", "spotify playback: testing :" + playerState.track.name);
                JsonElement playerStateJsonElement = gson.toJsonTree(playerState);
                JsonObject playerStateJson = playerStateJsonElement.getAsJsonObject();
                playerStateJson.addProperty("image_uri", playerState.track.imageUri.raw);
                playerStateJson.addProperty("time_stamp", System.currentTimeMillis());

               // if(isBrandNewState){
                    Log.d("spotify playback", "spotify playback: isBrandNewState 2:" + playerStateJsonElement);

                    playBackStateTunnel.invokeMethod(MC_UPDATE_METHOD_NAME, playerStateJson.toString());
               // }

            }
        });
    }

    public void UnSubscribeToPlayBackState(){
        playerStateSubscription.cancel();
    }

    public CallResult<Bitmap> getBitmap(String  uri, Dimension imgDIM){
        return imagesApi.getImage(new ImageUri(uri),imgDIM);
    }

    public void getImage(String  uri,Dimension imgDIM, MethodChannel.Result result){
        getBitmap(uri,imgDIM).setResultCallback(new CallResult.ResultCallback<Bitmap>() {
            @Override
            public void onResult(Bitmap bitmap) {
                ByteArrayOutputStream stream =  new ByteArrayOutputStream();
                bitmap.compress(Bitmap.CompressFormat.JPEG,100,stream);
                result.success(stream.toByteArray());

            }
        });
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


    private  void getPlayBackState(MethodChannel.Result response){
        mSpotifyAppRemote.getPlayerApi().getPlayerState().setResultCallback(new CallResult.ResultCallback<PlayerState>() {
            @Override
            public void onResult(PlayerState playerState) {
                Timber.d("player state changed!!!!!!");
                JsonElement playerStateJsonElement = gson.toJsonTree(playerState);
                JsonObject playerStateJson = playerStateJsonElement.getAsJsonObject();
                playerStateJson.addProperty("image_uri", playerState.track.imageUri.raw);
                playerStateJson.addProperty("time_stamp", System.currentTimeMillis());
               response.success(playerStateJson.toString());
            }
        });
    }
}
