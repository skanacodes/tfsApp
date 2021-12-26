package com.example.tfsappv1;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

import java.io.DataOutputStream;

public class Mp3Service extends Service {
    private static final String TAG = "Service";


    @Override
    public void onCreate() {
        Log.e(TAG, "Service onCreate");

        Thread background = new Thread(new Runnable() {

            public void run() {
                try {
                    Thread.sleep(3000);
                    //WelcomeActivity.getPrinterDriverVersion();


                } catch (Exception e) {
                    Log.e("exception",e.toString());
                }
            }
        });

        background.start();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {

        Log.i(TAG, "Service onStartCommand");
        return Service.START_STICKY;
    }


    @Override
    public IBinder onBind(Intent arg0) {
        Log.i(TAG, "Service onBind");
        return null;
    }

    @Override
    public void onDestroy() {
        Log.i(TAG, "Service onDestroy");
    }


}
