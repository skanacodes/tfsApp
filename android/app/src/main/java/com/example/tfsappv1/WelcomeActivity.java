package com.example.tfsappv1;

import android.Manifest;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.Settings;
import android.util.Base64;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.core.app.ActivityCompat;

import com.common.rgbled.ShellUtils;
import com.example.demoprinter.TelephonyInfo;
import com.mobiwire.CSAndroidGoLib.AndroidGoCSApi;
import com.mobiwire.CSAndroidGoLib.CsPrinter;
import com.sagereal.api.Printer;
import com.telpo.tps550.api.TelpoException;
import com.telpo.tps550.api.printer.UsbThermalPrinter;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

// we Import the mobiwire api


public class WelcomeActivity extends FlutterActivity {
    private static final String CHANNEL = "samples.flutter.dev/printing";
    private static final String CHANNEL1 = "samples.flutter.dev/deviceInfo";
    private static final String CHANNEL2 = "samples.flutter.dev/printBill";
    private Printer printer = null;
    public static final String BROADCAST_ACTION = "com.example.demoprinter";
    UsbThermalPrinter usbThermalPrinter;
    public String telporesponse;
    Button print,printtxt,printblack,getBatteryStatus;

    int powerValue;
    BatteryReceiver batteryReceiver = null;
    private String picturePath1 = Environment.getExternalStorageDirectory().getAbsolutePath() + "/logo.png";




    public String getTelpoRes() {
        return telporesponse;
    }

    public void setTelpoRes(String telpoRes) {
        this.telporesponse= telpoRes;

    }



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


        System.out.println(Build.BRAND + "brand");
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
        if (Build.BRAND.equals("qti")){

            usbThermalPrinter = new UsbThermalPrinter(  WelcomeActivity.this);
            IntentFilter intentFilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
            batteryReceiver = new BatteryReceiver();
            registerReceiver(batteryReceiver, intentFilter);

            new Thread(new Runnable() {


                public void run() {
                    // TODO Auto-generated method stub
                    try {
                        usbThermalPrinter.start(0);
                    } catch (TelpoException e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    }
                    runOnUiThread(new Runnable() {


                        public void run() {
                            // TODO Auto-generated method stub
//                        print.setEnabled(true);
//                        printtxt.setEnabled(true);
//                        printblack.setEnabled(true);
//                        getBatteryStatus.setEnabled(true);
                        }
                    });

                }
            }).start();

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


                                String activity = call.argument("activity");






                                if (activity.equals("printing")){
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
                                    String type = call.argument("type");


                                    byte[] image = Base64.decode(parameter, Base64.DEFAULT);
                                    byte[] qr = Base64.decode(qrcode, Base64.DEFAULT);

                        System.out.println(parameter2);
                                    if (parameter2.equals("MobiWire")) {

                                        String res = testClick(type,image,name,controlNo,receiptNo,amount,issuer,itemsAmount,itemsDesc,desc,paidDate,qr,plotname,station);
                                        result.success(res);
                                    } else if (parameter2.equals("MobiIoT")) {

                                        String res = printIot(type,image,name,controlNo,receiptNo,amount,issuer,itemsAmount,itemsDesc,desc,paidDate,qr,plotname,station);
                                        System.out.println(res);
                                        result.success(res);

                                    }else if (parameter2.equals("qti")) {
                                        //WelcomeActivity wel = new WelcomeActivity();
                                        String res = printTelpoReceipt(type
                                                ,image,name,controlNo,receiptNo,amount,issuer,itemsAmount,itemsDesc,desc,paidDate,qr,plotname,station);
                                       // System.out.println(telporesponse+"return");
                                        result.success(telporesponse);

                                    }  else {
                                        result.success("Your Device Doesn't Have Printer Capability");
                                    }
                                }
                                else if (activity.equals("printBill")){
                                    String parameter2 = call.argument("brand");
                                    List  controlNumbers = call.argument("controlNumberList");
                                    List names=call.argument("dealername");
                                    List fines=call.argument("fineList");
                                    List amountList=call.argument("amountList");
                                    String total = call.argument("totalFines");



                                    if (parameter2.equals("MobiWire")) {

                                        String res = printBillData(controlNumbers,amountList,fines,names,total);
                                        result.success(res);
                                    } else if (parameter2.equals("MobiIoT")) {

//              String res = printQrIot(qrList,names);
//              System.out.println("");
//             result.success(res);

                                    } else {
                                        result.success("Your Device Doesn't Have Printer Capability");
                                    }
                                }
                                else {
//                                    "activity": "QrCode",
//                                            "activities": activities,
//                                            "brand": brand,
//                                            "client_name": data[0]["client"].toString(),
//                                            "reserve": data[0]["reserve"].toString(),
//                                            "entry_point": data[0]["entry_point"].toString(),
//                                            "fee": data[0]["fee"].toString(),
//                                            "receipt_no": data[0]["receipt_no"].toString(),
//                                            "valid_days": data[0]["valid_days"].toString(),
                                    String parameter2 = call.argument("brand");
                                    List activities = call.argument("activities");
                                    String names=call.argument("client_name");
                                    String reserve=call.argument("reserve");
                                    String entry_point=call.argument("entry_point");
                                    String fee=call.argument("fee");
                                    String receiptNo=call.argument("receipt_no");
                                    String validDays=call.argument("valid_days");






                                    System.out.println(parameter2);
                                    if (parameter2.equals("MobiWire")) {

                                        String res = printQr(activities,names,reserve,entry_point,fee,receiptNo,validDays);
                                        result.success(res);
                                    } else if (parameter2.equals("MobiIoT")) {

                                        String res = printQrIot(activities,names,reserve,entry_point,fee,receiptNo,validDays);
                                        System.out.println("");
                                        result.success(res);

                                    }else {
                                        result.success("Your Device Doesn't Have Printer Capability");
                                    }
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
                            System.out.println("1234567890");
                            if (call.method.equals("getDeviceInfo")) {
                                System.out.println("1234567890");
                                String m_androidId = Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID);
                                System.out.println(m_androidId);
                               // System.out.println("********************************************************");
                                SharedPreferences sharedPreferences = getSharedPreferences("MySharedPref",MODE_PRIVATE);

// Creating an Editor object to edit(write to the file)
                                SharedPreferences.Editor myEdit = sharedPreferences.edit();

// Storing the key and its value as the data fetched from edittext
                                myEdit.putString("brand", Build.BRAND);
                                myEdit.putString("android_id",m_androidId );
//                myEdit.putString("imeiSim1", imeiSIM1);
//                myEdit.putString("imeiSim2", imeiSIM2);


                                myEdit.commit();
                                System.out.println(sharedPreferences.getAll());
                                String parameter = call.argument("operation");
                                System.out.println("1234567890");
                                System.out.println(parameter);
                                System.out.println("parameter");
                                 sharedPreferences = getSharedPreferences("MySharedPref",MODE_PRIVATE);
                                System.out.println(sharedPreferences.getString("brand",""));

                                System.out.println(sharedPreferences.getAll());
                                result.success(sharedPreferences.getAll());

//                                if (sharedPreferences.getString("brand","").equals("MobiWire") || sharedPreferences.getString("brand","").equals("MobiIoT") || sharedPreferences.getString("brand","").equals("qti")){
//
//                                    result.success(sharedPreferences.getAll());
//                                }else{
//                                    result.success("Not Supported");
//                                }




                            } else {
                                result.notImplemented();
                            }
                        }



                );


    }







    public String printIot(String type,byte[] image,String name,String controlNo,String receiptNo,String amount,String issuer,List itemsAmount,List itemsDesc,String desc,String paidDate,byte[] qr,String plotname,String station) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
        String currentDateandTime = sdf.format(new Date());
        String[] splitName = name.split(" ");
        String[] dateMonths = currentDateandTime.split(" ");
        String[] firstPartOfYear=dateMonths[0].split("-");
        String[] secondPartOfYear = dateMonths[1].split(":");
        int sumOfTheYear = Integer.parseInt(firstPartOfYear[0])+Integer.parseInt(firstPartOfYear[1])+Integer.parseInt(firstPartOfYear[2])+Integer.parseInt(secondPartOfYear[0])+Integer.parseInt(secondPartOfYear[1])+Integer.parseInt(secondPartOfYear[2]);
        StringBuilder code1 = new StringBuilder((controlNo.substring(controlNo.length()-3)));

        StringBuilder code2= new StringBuilder((receiptNo.substring(receiptNo.length()-3)));
        // System.out.println(splitName);
        char fchar ;
        char Schar ;

        if (splitName.length>1){
            fchar = splitName[0].charAt(0);
//            Schar = splitName[1].charAt(0);

        }
        else {
            fchar = splitName[0].charAt(0);
            Schar = splitName[0].charAt(splitName[0].length()-1);
        }

        int fnum = (Character.toLowerCase(fchar) - 'a' + 1);
       // int snum = Character.toLowerCase(Schar) - 'a' + 1;
        try {

            if (CsPrinter.getPrinterStatus()==0){
                return "Printer Out Of Paper";
            }else if(CsPrinter.getPrinterStatus()==1){
                Bitmap decodedByte = BitmapFactory.decodeByteArray(image, 0, image.length);
                Bitmap decodedQr = BitmapFactory.decodeByteArray(qr, 0, qr.length);
                Log.e("click","click");
                System.out.println("am Here");
                // printContent(decodedByte);
                CsPrinter printer=new CsPrinter();
                if(type.equals("receipt")){
                    printer.printBitmap(getContext(), decodedByte);
                    printer.printText("-----------------------------");
                    printer.printText("Tanzania Forest Services Agency (TFS).");
                    printer.printText("-----------------------------");
                    printer.printText("Client:"+name);
                    printer.printText("Control No: "+controlNo);
                    printer.printText("Receipt No: "+receiptNo);
                    printer.printText("Description: "+desc);
                    printer.printText("Station: "+station);
                    printer.printText("Issuer: "+issuer);
                    printer.printText("Paid On: "+paidDate);
                    printer.printText("Printed On:"+currentDateandTime);
                    printer.printText("-----------------------------");
                    printer.printText("Description(s).");
                    printer.printText("-----------------------------");
                    for (int i = 0; i < itemsAmount.toArray().length; i++) {

                        printer.printText(itemsDesc.get(i) +" "+    itemsAmount.get(i));
                    }
                    printer.printText("-----------------------------");
                    printer.printText("Total  Amount :  "+ amount);
                    printer.printText("-----------------------------");
                    printer.printText("Signature: ___________________");
                    //printer.addBarQrCodeToPrint(controlNo, BarcodeFormat.QR_CODE,300,300);
                    //printer.wait();
                    printer.addBitmapToPrint( decodedQr);

                    printer.printText("\n"+Integer.toString(fnum)+"-"+sumOfTheYear+"-"+code2.reverse()+code1.reverse());

                    printer.print(this);

                }
                if(type.equals("bill")){
                    printer.printBitmap(getContext(), decodedByte);
                    printer.printText("-----------------------------");
                    printer.printText("Tanzania Forest Services Agency (TFS).");
                    printer.printText("-----------------------------");
                    printer.printText("Client:"+name);
                    printer.printText("Control No: "+controlNo);
                    //printer.printText("Receipt No: "+receiptNo);
                    printer.printText("Description: "+desc);
                    printer.printText("Station: "+station);
                    printer.printText("Issuer: "+issuer);
                   // printer.printText("Paid On: "+paidDate);
                    printer.printText("Printed On:"+currentDateandTime);
                    printer.printText("-----------------------------");
                    printer.printText("Description(s).");
                    printer.printText("-----------------------------");
                    for (int i = 0; i < itemsAmount.toArray().length; i++) {

                        printer.printText(itemsDesc.get(i) +" "+    itemsAmount.get(i));
                    }
                    printer.printText("-----------------------------");
                    printer.printText("Total  Amount :  "+ amount);
                    printer.printText("-----------------------------");
                   // printer.printText("Signature: ----------------");
                    //printer.addBarQrCodeToPrint(controlNo, BarcodeFormat.QR_CODE,300,300);
                    //printer.wait();
                    printer.addBitmapToPrint( decodedQr);

                   // printer.printText("\n"+Integer.toString(fnum)+Integer.toString(snum)+"-"+sumOfTheYear+"-"+code2.reverse()+code1.reverse());

                    printer.print(this);

                }



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

    public String printQrIot(List activities,String names, String reserve,String entry_point,String fee,String receiptNo,String validDays) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
        String currentDateandTime = sdf.format(new Date());
        CsPrinter printer=new CsPrinter();
        try {

            if (CsPrinter.getPrinterStatus()==0){
                return "Printer Out Of Paper";
            }else if(CsPrinter.getPrinterStatus()==1){

                Log.e("click","click");
                System.out.println("am Here");
                // printContent(decodedByte);


               printer.printText("-----------------------------");
                printer.printText("(Made Under Regulation 35(3))");
                printer.printText(" Entry Form Permit For Persons, Animals Or Vehicles Into Forest Reserve ");
                    printer.printText("-----------------------------");
                    printer.printText("Name: " + names);
                printer.printText("Reserve: " + reserve);
                printer.printText("Entry Point: " + entry_point);
                printer.printText("Fee: " + fee);
                printer.printText("Receipt No: " + receiptNo);
                printer.printText("Valid Days: " + validDays);
                printer.printText("Printed On: " + currentDateandTime);

                printer.printText("Signature: ______________");
                printer.printText("-----------------------------");
                printer.printEndLine();
                printer.printEndLine();








              //  printer.print(this);
                return "Successfully Printed";

            }
            else if(CsPrinter.getPrinterStatus()==-1){



                printer.printText("-----------------------------");
                printer.printText("Name: " + names);
                printer.printText("Reserve: " + reserve);
                printer.printText("Entry Point: " + entry_point);
                printer.printText("Fee: " + fee);
                printer.printText("Receipt No: " + receiptNo);
                printer.printText("Valid Days: " + validDays);
                printer.printText("Printed On: " + currentDateandTime);


                printer.printText("-----------------------------");





                printer.print(this);
                return "Successfully Printed";

            }

            else{
                return "Printer Failed To Print";
            }

        }catch (Exception e){
            System.out.println(e.getMessage());
            return e.getMessage();
        }

    }






    public String testClick(String type,byte[] image,String name,String controlNo,String receiptNo,String amount,String issuer,List itemsAmount,List itemsDesc,String desc,String paidDate,byte[] qr,String plotname,String station) {
        Bitmap decodedByte = BitmapFactory.decodeByteArray(image, 0, image.length);
        Bitmap decodedQr = BitmapFactory.decodeByteArray(qr, 0, qr.length);


        //printContent(decodedByte);

        CurrentPrinterStatusEnum statusPrinter=CurrentPrinterStatusEnum.fromCode(printer.getCurrentPrinterStatus());
        switch (statusPrinter){
            case PRINTER_STATUS_OK:

                if(!printer.isPrinterOperation()) {

                    if (printer.voltageCheck()){
                        printContent(type,decodedByte, name,controlNo,receiptNo,amount,issuer,itemsAmount,itemsDesc,paidDate,desc,decodedQr,plotname,station);
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

    public String printQr(List qrList,String names, String reserve,String entry_point,String fee,String receiptNo,String validDays) {
        //        Bitmap decodedByte = BitmapFactory.decodeByteArray(image, 0, image.length);
//        Bitmap decodedByte = BitmapFactory.decodeByteArray(image, 0, image.length);
//        Bitmap decodedQr = BitmapFactory.decodeByteArray(qr, 0, qr.length);


        //printContent(decodedByte);

        CurrentPrinterStatusEnum statusPrinter=CurrentPrinterStatusEnum.fromCode(printer.getCurrentPrinterStatus());
        switch (statusPrinter){
            case PRINTER_STATUS_OK:

                if(!printer.isPrinterOperation()) {

                    if (printer.voltageCheck()){
                        printQrContent(qrList,names, reserve, entry_point, fee, receiptNo, validDays);
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


    public String printBillData(List controlNumber,List amounts,List fines,List dealers,String total) {


        CurrentPrinterStatusEnum statusPrinter=CurrentPrinterStatusEnum.fromCode(printer.getCurrentPrinterStatus());
        switch (statusPrinter){
            case PRINTER_STATUS_OK:

                if(!printer.isPrinterOperation()) {

                    if (printer.voltageCheck()){
                        printBillContent( controlNumber, amounts, fines, dealers, total);
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
    public void printContent(String type,Bitmap decodeBitmap,String name,String controlNo,String receiptNo,String amount,String issuer,List itemsAmount,List itemsDesc,String paidDate,String desc,Bitmap qr,String plotname,String station){
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
        String currentDateandTime = sdf.format(new Date());
        String[] splitName = name.split(" ");
        String[] dateMonths = currentDateandTime.split(" ");
        String[] firstPartOfYear=dateMonths[0].split("-");
        String[] secondPartOfYear = dateMonths[1].split(":");
        int sumOfTheYear = Integer.parseInt(firstPartOfYear[0])+Integer.parseInt(firstPartOfYear[1])+Integer.parseInt(firstPartOfYear[2])+Integer.parseInt(secondPartOfYear[0])+Integer.parseInt(secondPartOfYear[1])+Integer.parseInt(secondPartOfYear[2]);
        StringBuilder code1 = new StringBuilder((controlNo.substring(controlNo.length()-3)));

        StringBuilder code2= new StringBuilder((receiptNo.substring(receiptNo.length()-3)));
       // System.out.println(splitName);
        char fchar ;
        char Schar ;

        if (splitName.length>1){
            fchar = splitName[0].charAt(0);
          //  Schar = splitName[1].charAt(1);

        }
        else {
            fchar = splitName[0].charAt(0);
           // Schar = splitName[0].charAt(splitName[0].length()-1);
        }

        int fnum = (Character.toLowerCase(fchar) - 'a' + 1);
       // int snum = Character.toLowerCase(Schar) - 'a' + 1;
        new Thread(new Runnable() {
            @Override
            public void run()
            {

                try {

if (type.equals("receipt")){
    //    printer.printText("---------------",2,false);
    printer.printBitmap(decodeBitmap,1);
    printer.printText("---------------",2,false);
    printer.printText("Tanzania Forest Service Agency             (TFS).",1,false);
    printer.printText("---------------",2,false);
    printer.printText("Client:"+ name,1,false);
    printer.printText("Control No: "+ controlNo,1,false);
    printer.printText("Receipt No: "+ receiptNo,1,false);
    printer.printText("Description: "+ desc,1,false);
    // printer.printText("Plot Name: "+ plotname,1,false);

    printer.printText("Station: "+ station,1,false);


    printer.printText("Issuer : "+ issuer,1,false);
    printer.printText("Paid On : "+ paidDate,1,false);
    printer.printText("Printed On: "+ currentDateandTime,1,false);
    printer.printText("---------------",2,false);
    printer.printText("Description(s)",1,false);
    printer.printText("---------------",2,false);

    for (int i = 0; i < itemsAmount.toArray().length; i++) {

        printer.printText(itemsDesc.get(i) +" "+    itemsAmount.get(i)      ,1,false);
    }
    printer.printText("---------------",2,false);
    printer.printText("Total  Amount :  "+ amount,1,false);
    printer.printText("---------------",2,false);
    printer.printText("Signature: __________________",1,false);

    printer.printBitmap(qr,1);
    printer.printText("__________________\n"+Integer.toString(fnum)+"-"+sumOfTheYear+"-"+code2.reverse()+code1.reverse());




//                    Bitmap bmp = BitmapFactory.decodeResource(getResources(), R.raw.and3);
//                    printer.print32Bitmap(bmp);
    printer.printEndLine();

}
                    if (type.equals("bill")){
                        //    printer.printText("---------------",2,false);
                        printer.printBitmap(decodeBitmap,1);
                        printer.printText("---------------",2,false);
                        printer.printText("Tanzania Forest Service Agency             (TFS).",1,false);
                        printer.printText("---------------",2,false);
                        printer.printText("Client:"+ name,1,false);
                        printer.printText("Control No: "+ controlNo,1,false);
                        //printer.printText("Receipt No: "+ receiptNo,1,false);
                        printer.printText("Description: "+ desc,1,false);
                        // printer.printText("Plot Name: "+ plotname,1,false);

                        printer.printText("Station: "+ station,1,false);


                        printer.printText("Issuer : "+ issuer,1,false);
                       // printer.printText("Paid On : "+ paidDate,1,false);
                        printer.printText("Printed On: "+ currentDateandTime,1,false);
                        printer.printText("---------------",2,false);
                        printer.printText("Description(s)",1,false);
                        printer.printText("---------------",2,false);

                        for (int i = 0; i < itemsAmount.toArray().length; i++) {

                            printer.printText(itemsDesc.get(i) +" "+    itemsAmount.get(i)      ,1,false);
                        }
                        printer.printText("---------------",2,false);
                        printer.printText("Total  Amount :  "+ amount,1,false);
                        printer.printText("---------------",2,false);

                        printer.printBitmap(qr,1);





//                    Bitmap bmp = BitmapFactory.decodeResource(getResources(), R.raw.and3);
//                    printer.print32Bitmap(bmp);
                        printer.printEndLine();

                    }




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

    public void printQrContent(List qrList,String names,String reserve,String entry_point,String fee,String receiptNo,String validDays ){
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
        String currentDateandTime = sdf.format(new Date());

        new Thread(new Runnable() {
            @Override
            public void run()
            {

                try {



                        printer.printText("Entry Form Permit For Persons,Animals Or Vehicles Into Forest Reserve",2,false);

                        printer.printText("---------------",2,false);
                        printer.printText("Name: "+ names,1,false);
                    printer.printText("Reserve: "+ reserve,1,false);
                    printer.printText("Entry Point: "+ entry_point,1,false);
                    printer.printText("Fee: "+ fee,1,false);
                    printer.printText("Receipt No: "+ receiptNo,1,false);
                    printer.printText("Valid Days: "+ validDays,1,false);
                    printer.printText("Printed On: "+ currentDateandTime,1,false);
                        printer.printText("---------------",2,false);


                        printer.printEndLine();
                        Thread.sleep(4000);








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


    public void printBillContent(List controlNumber,List amounts,List fines,List dealers,String total){
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
        String currentDateandTime = sdf.format(new Date());
        System.out.println(controlNumber);
        new Thread(new Runnable() {
            @Override
            public void run()
            {

                try {



                    //    printer.printText("---------------",2,false);
                    printer.printText("---------------",2,false);
                    printer.printText("Tanzania Forest Service Agency          (TFS).",1,false);
                    printer.printText("---------------",2,false);
                    printer.printText("Bill Details: ",1,false);
                    printer.printText("Name: "+ dealers.get(0),1,false);

                    for (int i = 0; i < controlNumber.toArray().length; i++) {




                        printer.printText("---------------",2,false);
                        printer.printText(""+ fines.get(i),1,false);
                        printer.printText("Control No: "+ controlNumber.get(i),1,false);
                        printer.printText("Amount: "+ amounts.get(i),1,false);
                        printer.printText("---------------",2,false);




                    }
                    printer.printText("Total Bill: "+ total ,1,false);







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


       // textError.setVisibility(View.VISIBLE);
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



    //Telpo PRinter Implementations


    public String printTelpoReceipt(String type,byte[] image,String name,String controlNo,String receiptNo,String amount,String issuer,List itemsAmount,List itemsDesc,String desc,String paidDate,byte[] qr,String plotname,String station){
        Bitmap decodedByte = BitmapFactory.decodeByteArray(image, 0, image.length);
        Bitmap decodedQr = BitmapFactory.decodeByteArray(qr, 0, qr.length);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());

        String currentDateandTime = sdf.format(new Date());
        final String[] res = new String[1];
        new Thread(new Runnable() {


            public void run() {
                // TODO Auto-generated method stub
                try {

                  //  String[] splitName = name.split(" ");
                  //  String[] dateMonths = currentDateandTime.split(" ");
//                    String[] firstPartOfYear=dateMonths[0].split("-");
//                    String[] secondPartOfYear = dateMonths[1].split(":");
                //    int sumOfTheYear = Integer.parseInt(firstPartOfYear[0])+Integer.parseInt(firstPartOfYear[1])+Integer.parseInt(firstPartOfYear[2])+Integer.parseInt(secondPartOfYear[0])+Integer.parseInt(secondPartOfYear[1])+Integer.parseInt(secondPartOfYear[2]);
//              StringBuilder code1 = new StringBuilder((controlNo.substring(controlNo.length()-3)));
//
//                    StringBuilder code2= new StringBuilder((receiptNo.substring(receiptNo.length()-3)));
//                    System.out.println(splitName);
//                    char fchar ;
//                    char Schar ;
//
//                    if (splitName.length>1){
//                         fchar = splitName[0].charAt(0);
//                         Schar = splitName[1].charAt(1);
//
//                    }
//                    else {
//                        fchar = splitName[0].charAt(0);
//                        Schar = 'a';
//                    }
//
//                    int fnum = (Character.toLowerCase(fchar) - 'a' + 1);
//                    int snum = Character.toLowerCase(Schar) - 'a' + 1;
                    String pversion,gray,sversion,level,imei = null;
//                    Bitmap bitmap1 = BitmapFactory.decodeResource(getResources(), R.drawable.bitmap1);
//                    Bitmap bitmap2 = BitmapFactory.decodeResource(getResources(), R.drawable.bitmap2);
                    //    Bitmap logo = BitmapFactory.decodeResource(getResources(), R.drawable.logo);

                    if (type.equals("receipt")){
                        usbThermalPrinter.reset();
                        usbThermalPrinter.setGray(5);
//                    gray = "5";
//                    pversion = usbThermalPrinter.getVersion();
//                    sversion = Build.DISPLAY;
//                    level = ""+powerValue;
                        //TelephonyManager telephonyManager = (TelephonyManager) UsbPrintTest.this.getSystemService(Context.TELEPHONY_SERVICE);
                        //imei = telephonyManager.getDeviceId();
                        usbThermalPrinter.setAlgin(UsbThermalPrinter.ALGIN_MIDDLE);
                        usbThermalPrinter.printLogo(decodedByte, false);

                        usbThermalPrinter.setTextSize(20);
                        usbThermalPrinter.setAlgin(UsbThermalPrinter.ALGIN_LEFT);
                        usbThermalPrinter.addString(
                                "--------------------------------\n"
                                        +"Tanzania Forest Services Agency (TFS).\n"
                                        +  "--------------------------------\n"
                                        +"Client: "+name+"\n"
                                        + "Control No: "+controlNo+"\n"
                                        + "Receipt No: "+receiptNo+"\n"
                                        + "Description: "+desc+"\n"
                                        + "Station: "+station+"\n"
                                        + "Issuer: "+issuer+"\n"
                                        + "Paid On: "+ paidDate+ "\n"
                                        + "Printed On: "+ currentDateandTime+ "\n"


                        );
                        usbThermalPrinter.printString();
                        usbThermalPrinter.addString("--------------------------------\n"
                                + "Description(s)\n"
                                +  "--------------------------------");
                        usbThermalPrinter.printString();

                        for (int i = 0; i < itemsAmount.toArray().length; i++) {
                            usbThermalPrinter.setAlgin(UsbThermalPrinter.ALGIN_LEFT);
                            usbThermalPrinter.addString(itemsDesc.get(i)+ "  " + itemsAmount.get(i));

                        }



                        usbThermalPrinter.printString();
                        usbThermalPrinter.addString("--------------------------------\n"
                                + "Total: "+amount+"\n"
                                +  "--------------------------------");
                        usbThermalPrinter.printString();

                        usbThermalPrinter.addString("Signature:__________________");
                        usbThermalPrinter.printString();
                        usbThermalPrinter.setAlgin(UsbThermalPrinter.ALGIN_MIDDLE);

                        usbThermalPrinter.printLogo(decodedQr, false);
                      //  usbThermalPrinter.setAlgin(UsbThermalPrinter.ALGIN_MIDDLE);
                       // usbThermalPrinter.addString("--------------------------------\n"+Integer.toString(fnum)+Integer.toString(snum)+"-"+sumOfTheYear+"-"+code2.reverse()+code1.reverse());
                        usbThermalPrinter.printString();
                        usbThermalPrinter.walkPaper(15);
                        telporesponse="Successfully Printed";
                    }
                    if (type.equals("bill")){
                        usbThermalPrinter.reset();
                        usbThermalPrinter.setGray(5);
//                    gray = "5";
//                    pversion = usbThermalPrinter.getVersion();
//                    sversion = Build.DISPLAY;
//                    level = ""+powerValue;
                        //TelephonyManager telephonyManager = (TelephonyManager) UsbPrintTest.this.getSystemService(Context.TELEPHONY_SERVICE);
                        //imei = telephonyManager.getDeviceId();
                        usbThermalPrinter.setAlgin(UsbThermalPrinter.ALGIN_MIDDLE);
                        usbThermalPrinter.printLogo(decodedByte, false);

                        usbThermalPrinter.setTextSize(20);
                        usbThermalPrinter.setAlgin(UsbThermalPrinter.ALGIN_LEFT);
                        usbThermalPrinter.addString(
                                "--------------------------------\n"
                                        +"Tanzania Forest Services Agency               (TFS).\n"
                                        +  "--------------------------------\n"
                                        +"Client: "+name+"\n"
                                        + "Control No: "+controlNo+"\n"

                                        + "Description: "+desc+"\n"
                                        + "Station: "+station+"\n"
                                        + "Issuer: "+issuer+"\n"

                                        + "Printed On: "+ currentDateandTime+ "\n"


                        );
                        usbThermalPrinter.printString();
                      

                        usbThermalPrinter.addString("--------------------------------\n"
                                + "Total: "+amount+"\n"
                                +  "--------------------------------");
                        usbThermalPrinter.printString();

                        usbThermalPrinter.setAlgin(UsbThermalPrinter.ALGIN_MIDDLE);

                        usbThermalPrinter.printLogo(decodedQr, false);
                        usbThermalPrinter.setAlgin(UsbThermalPrinter.ALGIN_MIDDLE);

                        usbThermalPrinter.walkPaper(15);
                        telporesponse="Successfully Printed";
                    }
                } catch (TelpoException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                    telporesponse=e.getDescription();



                  //+ System.out.println( telporesponse+"dtdtr");
                }
            }

        }).start();

       return   telporesponse;
    }



    public void printtxt(){
        try {
            usbThermalPrinter.setAlgin(UsbThermalPrinter.ALGIN_LEFT);
            usbThermalPrinter.addString("\n             烧烤" + "\n---------------------------" + "\n日期：2015-01-01 16:18:20"
                    + "\n卡号：12378945664" + "\n单号：1001000000000529142" + "\n---------------------------"
                    + "\n    项目        数量   单价  小计" + "\n秘制烤羊腿    1      56      56"
                    + "\n烤火鸡            2      50      100" + "\n烤全羊            1      200    200"
                    + "\n秘制烤鸡腿    1      56      56" + "\n烤牛腿            2      50      100"
                    + "\n烤猪蹄            1      200    200" + "\n秘制烤牛腿    1      56      56"
                    + "\n烤火鸡            2      50      100" + "\n烤全羊            1      200    200"
                    + "\n秘制烤猪腿    1      56      56" + "\n烤火鸡            2      50      100"
                    + "\n烤全牛            1      200    200" + "\n特色烤鸭腿    1      56      56"
                    + "\n烤土鸡            2      50      100" + "\n烤全羊            1      200    200"
                    + "\n秘制烤火腿    1      56      56" + "\n烤火鸡            2      50      100"
                    + "\n烤全羊            1      200    200" + "\n秘制烤鸡腿    1      56      56"
                    + "\n烤火鸡            2      50      100" + "\n烤全羊            1      200    200"
                    + "\n秘制烤火腿    1      56      56" + "\n烤火鸡            2      50      100"
                    + "\n烤全羊            1      200    200" + "\n秘制烤牛筋    1      56      56"
                    + "\n烤土鸡            2      50      100" + "\n烤白鸽            1      200    200"
                    + "\n秘制鸭下巴    1      56      56" + "\n烤火鸡            2      50      100"
                    + "\n烤全牛            1      200    200" + "\n 合计：1000:00元" + "\n----------------------------"
                    + "\n本卡金额：10000.00" + "\n累计消费：1000.00" + "\n本卡结余：9000.00" + "\n----------------------------"
                    + "\n 地址：广东省佛山市南海区桂城街道桂澜南路45号鹏瑞利广场A317.B-18号铺" + "\n欢迎您的再次光临\n");
            usbThermalPrinter.printString();
            usbThermalPrinter.walkPaper(15);
        } catch (TelpoException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

//    public void printblack(View view){
//
//        try {
//            Bitmap bitmap3 = BitmapFactory.decodeResource(getResources(), R.drawable.black);
//            usbThermalPrinter.setAlgin(UsbThermalPrinter.ALGIN_MIDDLE);
//            usbThermalPrinter.printLogo(bitmap3, false);
//            usbThermalPrinter.walkPaper(15);
//        } catch (TelpoException e) {
//            // TODO Auto-generated catch block
//            e.printStackTrace();
//        }
//
//    }

    public void getBatteryStatus(View view){
        Log.d("tagg", "true["+ ShellUtils.execCommand("cat /sys/class/power_supply/ac/online", true).successMsg+"]");
        Log.d("tagg", "false["+ShellUtils.execCommand("cat /sys/class/power_supply/ac/online", false).successMsg+"]");
    }

    private class BatteryReceiver extends BroadcastReceiver {


        public void onReceive(Context context, Intent intent) {
            // TODO Auto-generated method stub
            //判断它是否是为电量变化的Broadcast Action
            if(Intent.ACTION_BATTERY_CHANGED.equals(intent.getAction())){
                //获取当前电量
                int level = intent.getIntExtra("level", 0);
                //电量的总刻度
                int scale = intent.getIntExtra("scale", 100);
                //把它转成百分比
                powerValue = ((level*100)/scale);
            }
        }
    }


    protected void onDestroy() {
        // TODO Auto-generated method stub
        super.onDestroy();
        //unregisterReceiver(batteryReceiver);
//        batteryReceiver = null;
//        usbThermalPrinter.stop();
    }


}