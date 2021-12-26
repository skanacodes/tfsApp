package com.example.tfsappv1;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import com.mobiwire.CSAndroidGoLib.AndroidGoCSApi;
import com.mobiwire.CSAndroidGoLib.CsPrinter;

import android.content.ServiceConnection;
import android.os.Bundle;


import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;
// we Import the mobiwire api
import com.mobiwire.CSAndroidGoLib.Utils.PrinterServiceUtil;
import com.mobiwire.CSAndroidGoLib.Utils.ServiceUtil;
import com.sagereal.api.Printer;

import static android.content.ServiceConnection.*;


public class WelcomeActivity extends FlutterActivity {
    private static final String CHANNEL = "samples.flutter.dev/printing";
    private Printer printer = null;
    DeviceInformation info;
    TextView textError;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this.getFlutterEngine());
    }



    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        printer = Printer.getInstance();

        info=new DeviceInformation(this);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            if (call.method.equals("getBatteryLevel")) {

                                String parameter = call.argument("imageData");
                                String parameter2 = call.argument("brand");
                                System.out.println(parameter);
                                byte[] image = Base64.decode(parameter, Base64.DEFAULT);


                             if (parameter2.equals("MobiWire")){

                                 String res=   testClick(image);
                                 result.success(res);
                             }else if (parameter2.equals("MobiIoT")){
                                 new AndroidGoCSApi(this);
                                 String res=  print(image);
                                 System.out.println(res);
                                 result.success(res);

                             }else{
                                 result.success("Your Device Doesn't Have Printer Capability");
                             }




                            } else {
                                result.notImplemented();
                            }
                        }

                );
    }



    public String print(byte[] image) {

        try {

        if (CsPrinter.getPrinterStatus()==0){
              return "Printer Out Of Paper";
        }else if(CsPrinter.getPrinterStatus()==1){
            Bitmap decodedByte = BitmapFactory.decodeByteArray(image, 0, image.length);
            Log.e("click","click");
            System.out.println("am Here");
            // printContent(decodedByte);
            CsPrinter printer=new CsPrinter();


            printer.addBitmapToPrint(decodedByte);

            printer.print(this);
            return "Successfully Printed";
        }
        else if(CsPrinter.getPrinterStatus()==-1){
            Bitmap decodedByte = BitmapFactory.decodeByteArray(image, 0, image.length);
            Log.e("click","click");
            System.out.println("am Here");
            // printContent(decodedByte);
            CsPrinter printer=new CsPrinter();


            printer.addBitmapToPrint(decodedByte);

            printer.print(this);
            return "Successfully Printed";
        }

        else{
            return "Printer Failed To Print";
        }

        }catch (Exception e){
            System.out.println(e.getMessage());
            return "Failed To Print";
        }

    }








    public String testClick(byte[] image) {
        Bitmap decodedByte = BitmapFactory.decodeByteArray(image, 0, image.length);

       //printContent(decodedByte);

       CurrentPrinterStatusEnum statusPrinter=CurrentPrinterStatusEnum.fromCode(printer.getCurrentPrinterStatus());
        switch (statusPrinter){
            case PRINTER_STATUS_OK:

                if(!printer.isPrinterOperation()) {

                    if (printer.voltageCheck()){
                        printContent(decodedByte);
                        return "Successfully Printed";
                    }

                    else{
                        return "Voltage Error";
                    }
                }else{
                      return  "Another Operation Is Running";
                }

            case PRINTER_STATUS_NO_PAPER:
                return "Printer Out Of Paper";

            case PRINTER_STATUS_NO_REACTION:

                return "PRINTER_STATUS_NO_REACTION";

            case PRINTER_STATUS_GET_FAILE:
                 return "Printer Status";

            case PRINTER_STATUS_LOW_POWER:
                return "PRINTER_STATUS_LOW_POWER";

        }
        return  null;
    }


    int clt=0;
    boolean showSuccess=true;
    public void printContent(Bitmap decodeBitmap){
        new Thread(new Runnable() {
            @Override
            public void run()
            {
                try {
                    printer.printBitmap(decodeBitmap);





//                    Bitmap bmp = BitmapFactory.decodeResource(getResources(), R.raw.and3);
//                    printer.print32Bitmap(bmp);
                    printer.printEndLine();





                    while(printer.isPrinterOperation()){
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                //showOnProgress();
                                /*if(printer.getPaperStatus()!=1){
                                    showError("RINTER_STATUS_NO_PAPER");
                                    showSuccess=false;
                                }*/

                            }
                        });
                    }

                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            //if(showSuccess==true)
                            //showSuccess();
                        }
                    });
                }
                catch (Exception e)
                {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            //showError(getString(R.string.text_unknown_error));
                        }
                    });

                    e.printStackTrace();
                }
            }
        }).start();
    }


    public void showError(String error){


        textError.setVisibility(View.VISIBLE);
        //textError.setBackgroundColor(getResources().getColor(R.color.red));
        // textError.setText(getString(R.string.text_printKO)+"\n"+error);
    }

    public void showSuccess(){

//        textError.setVisibility(View.VISIBLE);
        // textError.setBackgroundColor(getResources().getColor(R.color.green));
        //textError.setText(getString(R.string.text_printOK));
    }

    public void showOnProgress(){

        //textError.setVisibility(View.VISIBLE);
        // textError.setBackgroundColor(getResources().getColor(R.color.green_light));
        // textError.setText(getString(R.string.text_printProgress));
    }

}
