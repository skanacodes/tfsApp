package com.example.tfsappv1;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;
import com.example.demoprinter.TelephonyInfo;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import com.mobiwire.CSAndroidGoLib.AndroidGoCSApi;
import com.mobiwire.CSAndroidGoLib.CsPrinter;

import android.Manifest;
import android.content.ServiceConnection;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationManager;
import android.os.Build;
import android.os.Bundle;


import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.provider.Settings;
import android.util.Base64;
import android.util.Log;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;
// we Import the mobiwire api
import com.mobiwire.CSAndroidGoLib.Utils.PrinterServiceUtil;
import com.mobiwire.CSAndroidGoLib.Utils.ServiceUtil;
import com.sagereal.api.Printer;

import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import static android.content.ServiceConnection.*;


public class WelcomeActivity extends FlutterActivity {
    private static final String CHANNEL = "samples.flutter.dev/printing";
    private static final String CHANNEL1 = "samples.flutter.dev/deviceInfo";
    private Printer printer = null;

    TextView textError;


    @RequiresApi(api = Build.VERSION_CODES.P)
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this.getFlutterEngine());
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.READ_PHONE_STATE}, 101);
        }

    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        switch (requestCode) {

            case 101:
                if (grantResults[0] == PackageManager.PERMISSION_GRANTED){
                    if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
                        return;
                    }

                } else{
                    //not granted
                }


                break;
            default:
                super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        }
    }
    @RequiresApi(api = Build.VERSION_CODES.O)
    @Override
    protected void onResume() {
        super.onResume();
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {

            return;
        }


        System.out.println(Build.BRAND);
        if (Build.BRAND.equals("MobiIoT")){
            new AndroidGoCSApi(this);
        }
        if (Build.BRAND.equals("MobiIoT") || Build.BRAND.equals("MobiWire")){
            TelephonyInfo telephonyInfo = TelephonyInfo.getInstance(this);

            String imeiSIM1 = telephonyInfo.getImsiSIM1();
            String imeiSIM2 = telephonyInfo.getImsiSIM2();

            System.out.println(imeiSIM1);
            System.out.println(imeiSIM2);

            String m_androidId = Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID);
            System.out.println(m_androidId);
            SharedPreferences sharedPreferences = getSharedPreferences("MySharedPref",MODE_PRIVATE);

// Creating an Editor object to edit(write to the file)
            SharedPreferences.Editor myEdit = sharedPreferences.edit();

// Storing the key and its value as the data fetched from edittext
            myEdit.putString("brand", Build.BRAND);
            myEdit.putString("android_id",m_androidId );
            myEdit.putString("imeiSim1", imeiSIM1);
            myEdit.putString("imeiSim2", imeiSIM2);


            myEdit.commit();
            System.out.println(sharedPreferences.getAll());
        }



    }





    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        printer = Printer.getInstance();


        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            if (call.method.equals("getBatteryLevel")) {

                                String parameter = call.argument("imageData");
                                String parameter2 = call.argument("brand");
                                String name = call.argument("name");
                                String controlNo = call.argument("controlNo");
                                String receiptNo = call.argument("receiptNo");
                                String amount = call.argument("amount");
                                String issuer = call.argument("issuer");
                                String paidDate = call.argument("paymentDate");
                                String desc = call.argument("desc");
                                List<String> itemsAmount  = call.argument("itemsAmount");
                                List itemsDesc  = call.argument("itemsDesc");
                                String qrcode = call.argument("qrcode");
                                String plotname= call.argument("plotname");
                                String station = call.argument("station");






//                                System.out.println(name);
//                                System.out.println(amount);
//                                System.out.println(controlNo);
//                                System.out.println(receiptNo);
//                                System.out.println(issuer);
                             //   System.out.println(itemsAmount.toArray());
                            //    System.out.println(paidDate);
                              //System.out.println(qrcode);



                                byte[] image = Base64.decode(parameter, Base64.DEFAULT);
                                byte[] qr = Base64.decode(qrcode, Base64.DEFAULT);


                                if (parameter2.equals("MobiWire")) {

                                    String res = testClick(image,name,controlNo,receiptNo,amount,issuer,itemsAmount,itemsDesc,desc,paidDate,qr,plotname,station);
                                    result.success(res);
                                } else if (parameter2.equals("MobiIoT")) {

                                    String res = print(image);
                                    System.out.println(res);
                                    result.success(res);

                                } else {
                                    result.success("Your Device Doesn't Have Printer Capability");
                                }


                            } else {
                                result.notImplemented();
                            }
                        }

                );

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL1)
                .setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            if (call.method.equals("getDeviceInfo")) {

                                String parameter = call.argument("operation");

                                System.out.println(parameter);
                                SharedPreferences sharedPreferences = getSharedPreferences("MySharedPref",MODE_PRIVATE);
                                System.out.println(sharedPreferences.getString("brand",""));

                                System.out.println(sharedPreferences.getAll());

                                if (sharedPreferences.getString("brand","").equals("MobiWire") || sharedPreferences.getString("brand","").equals("MobiIoT")){

                                    result.success(sharedPreferences.getAll());
                                }else{
                                    result.success("Not Supported");
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

            printer.printText("-----------------------------");
            printer.printText_FullParm("fdsgvdss",55,0,20,0,true,false);
            printer.printBitmap(getContext(),decodedByte);
            printer.printText("-----------------------------");
            printer.printText_FullParm("fdsgvdss",55,0,20,0,true,false);
            printer.printEndLine();
            //   printer.addBitmapToPrint(decodedByte);

            printer.addTextToPrint("Draw Time","03:30 PM",25,true,false,1);

            //printer.addBarQrCodeToPrint("TEST", BarcodeFormat.QR_CODE, 384, 280);

            printer.addTextToPrint("------------",null,25,true,false,1);

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








    public String testClick(byte[] image,String name,String controlNo,String receiptNo,String amount,String issuer,List itemsAmount,List itemsDesc,String desc,String paidDate,byte[] qr,String plotname,String station) {
        Bitmap decodedByte = BitmapFactory.decodeByteArray(image, 0, image.length);
        Bitmap decodedQr = BitmapFactory.decodeByteArray(qr, 0, qr.length);


        //printContent(decodedByte);

       CurrentPrinterStatusEnum statusPrinter=CurrentPrinterStatusEnum.fromCode(printer.getCurrentPrinterStatus());
        switch (statusPrinter){
            case PRINTER_STATUS_OK:

                if(!printer.isPrinterOperation()) {

                    if (printer.voltageCheck()){
                        printContent(decodedByte, name,controlNo,receiptNo,amount,issuer,itemsAmount,itemsDesc,paidDate,desc,decodedQr,plotname,station);
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
    public void printContent(Bitmap decodeBitmap,String name,String controlNo,String receiptNo,String amount,String issuer,List itemsAmount,List itemsDesc,String paidDate,String desc,Bitmap qr,String plotname,String station){
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
        String currentDateandTime = sdf.format(new Date());

        new Thread(new Runnable() {
            @Override
            public void run()
            {

                try {

                //    printer.printText("---------------",2,false);
                    printer.printBitmap(decodeBitmap,1);
                    printer.printText("---------------",2,false);
                    printer.printText("Tanzania Forest Service Agency (TFS).",1,false);
                    printer.printText("---------------",2,false);
                    printer.printText("Client:"+ name,1,false);
                    printer.printText("Control No: "+ controlNo,1,false);
                    printer.printText("Receipt No: "+ receiptNo,1,false);
                    printer.printText("Description: "+ desc,1,false);
                    printer.printText("Plot Name: "+ plotname,1,false);

                    printer.printText("Station: "+ station,1,false);


                    printer.printText("Issuer : "+ issuer,1,false);
                    printer.printText("Paid On : "+ paidDate,1,false);
                    printer.printText("Printed On: "+ currentDateandTime,1,false);
                    printer.printText("---------------",2,false);
                    printer.printText("Description(s)",1,false);
                    printer.printText("---------------",2,false);

                    for (int i = 0; i < itemsAmount.toArray().length; i++) {

                        printer.printText(itemsDesc.get(i) +"  "+    itemsAmount.get(i)      ,1,false);
                    }
                    printer.printText("---------------",2,false);
                    printer.printText("Total  Amount :  "+ amount,1,false);
                    printer.printText("---------------",2,false);
                    printer.printText("Signature: __________________",1,false);

                    printer.printBitmap(qr,1);





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
