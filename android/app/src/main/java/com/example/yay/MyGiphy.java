package com.example.yay;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;

import androidx.annotation.Nullable;

import com.giphy.sdk.ui.Giphy;
import com.giphy.sdk.ui.views.GiphyDialogFragment;

public class MyGiphy extends Activity {
    Context context;
    String giphyKey  = "Ndrb8HT6eAPmbdVMheZoZShs1Xh3Lkcs";
    public MyGiphy(Context context) {
        this.context = context;
        this.sup
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Giphy.INSTANCE.configure(context,giphyKey,false,Giphy.INSTANCE.getFrescoHandler());

                GiphyDialogFragment.Companion.newInstance().show(context.su);

    }
}
