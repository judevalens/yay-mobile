package com.example.yay;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;

import androidx.annotation.Nullable;

import com.giphy.sdk.core.models.enums.RenditionType;
import com.giphy.sdk.ui.GPHContentType;
import com.giphy.sdk.ui.GPHSettings;
import com.giphy.sdk.ui.Giphy;
import com.giphy.sdk.ui.GiphyFrescoHandler;
import com.giphy.sdk.ui.themes.GPHTheme;
import com.giphy.sdk.ui.themes.GridType;
import com.giphy.sdk.ui.views.GPHMediaView;
import com.giphy.sdk.ui.views.GiphyDialogFragment;

import io.flutter.embedding.android.FlutterFragmentActivity;

public class MyGiphy  {
    Context context;
    FlutterFragmentActivity activity;
    String giphyKey  = "Ndrb8HT6eAPmbdVMheZoZShs1Xh3Lkcs";
    GiphyDialogFragment dialog;

    public MyGiphy(FlutterFragmentActivity context) {
        this.context = context;
        activity = context;

    }


    public  void show(){
        GiphyFrescoHandler handler = Giphy.INSTANCE.getFrescoHandler();
        Giphy.INSTANCE.configure(context,giphyKey,false,handler);

        GPHSettings giphySettings =  new GPHSettings();

        giphySettings.setTheme(GPHTheme.Dark);
        giphySettings.setGridType(GridType.waterfall);

        final GPHContentType[] contentTypes = new GPHContentType[5];
        contentTypes[0] = GPHContentType.sticker;
        contentTypes[1] = GPHContentType.gif;
        contentTypes[2] = GPHContentType.text;
        contentTypes[3] = GPHContentType.emoji;
        contentTypes[4] = GPHContentType.recents;
        giphySettings.setMediaTypeConfig(contentTypes);
        dialog = GiphyDialogFragment.Companion.newInstance(giphySettings);
        dialog.show(activity.getSupportFragmentManager(),"gif");

    }
}
