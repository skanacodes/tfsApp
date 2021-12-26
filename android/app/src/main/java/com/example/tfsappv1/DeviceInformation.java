package com.example.tfsappv1;

import android.content.Context;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.provider.Settings;
import android.telephony.TelephonyManager;
import android.util.Log;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 * Created by Aly on 04/07/2017.
 */

public class DeviceInformation {

    private String model;
    private String id;
    private String manufacturer;
    private String baseBandVersion;
    private String kernelVersion;
    private String buildNumber;
    private String androidVersion;
    private String customBuildVersion;
    private String imei;
    private String macAddress;

    public DeviceInformation(Context context) {
        this.model = Build.MODEL;
        this.id = Build.ID;
        this.manufacturer = Build.MANUFACTURER;
        this.baseBandVersion = Build.getRadioVersion();
        this.kernelVersion = System.getProperty("os.version");
        this.buildNumber = Build.DISPLAY;
        this.androidVersion = Build.VERSION.RELEASE;
       // this.macAddress = ((WifiManager) context.getSystemService(Context.WIFI_SERVICE)).getConnectionInfo().getMacAddress();

        //TelephonyManager mngr = (TelephonyManager) context.getSystemService(context.TELEPHONY_SERVICE);
       // this.imei = mngr.getDeviceId();


        try {
            Process process = Runtime.getRuntime().exec("getprop ro.fota.version");
            BufferedReader bufferedReader = new BufferedReader(
                    new InputStreamReader(process.getInputStream()));
            this.customBuildVersion=bufferedReader.readLine();

        } catch (IOException e) {
            this.customBuildVersion="";
            e.printStackTrace();
        }

        super.toString();
    }

    public String getModel() {
        return model;
    }

    public String getId() {
        return id;
    }

    public String getManufacturer() {
        return manufacturer;
    }


    public String getBaseBandVersion() {
        return baseBandVersion;
    }

    public String getKernelVersion() {
        return kernelVersion;
    }

    public String getBuidNumber() {
        return buildNumber;
    }

    public String getAndroidVersion() {
        return androidVersion;
    }


    public String getCustomBuildVersion() {
        return customBuildVersion;
    }

    public String getImei() {
        return imei;
    }

    public String getMacAddress() {
        return macAddress;
    }
}


    /*
    ro.build.id=JDQ39
ro.build.display.id=ALPS.JB3.MP.V1
ro.build.version.incremental=eng.gxm.1497581421
ro.custom.build.version=V09_20170616
ro.custom.build.srver1=_MP3_GENERIC
ro.custom.build.srver2=_QB_MP
ro.build.version.sdk=17
ro.build.version.codename=REL
ro.build.version.release=4.2.2
ro.build.date=2017Õ╣┤ 06µ£ê 16µùÑ µÿƒµ£ƒõ║ö 10:51:51 CST
ro.build.date.utc=1497581511
ro.build.type=user
ro.build.user=gxm
ro.sagereal_devicecode=00104
ro.build.host=gxm-ThinkStation-P300
ro.build.tags=release-keys
ro.product.model=MobiPrint
ro.product.brand=MobiWire
ro.product.name=MobiPrint III
ro.product.device=MobiPrint III
ro.product.board=MobiPrint III
ro.product.cpu.abi=armeabi-v7a
ro.product.cpu.abi2=armeabi
ro.product.manufacturer=MobiWire
ro.product.locale.language=en
ro.product.locale.region=US
ro.wifi.channels=
ro.board.platform=
# ro.build.product is obsolete; use ro.product.device
ro.build.product=MobiPrint III
# Do not try to parse ro.build.description or .fingerprint
ro.build.description=mp3_common-user 4.2.2 JDQ39 eng.gxm.1497581421 release-keys
ro.build.fingerprint=MobiWire/MobiWire_MobiPrint/MobiWire_MobiPrint3:4.2.2/JDQ39/1497581421:user/release-keys
ro.build.flavor=
ro.build.characteristics=default
# end build properties

# begin mediatek build properties
ro.mediatek.version.release=ALPS.JB3.MP.V1
ro.mediatek.platform=MT6572
ro.mediatek.chip_ver=S01
ro.mediatek.version.branch=ALPS.JB3.MP
ro.mediatek.version.sdk=1
# end mediatek build properties
#
# system.prop for generic sdk
#

rild.libpath=/system/lib/mtk-ril.so
rild.libargs=-d /dev/ttyC0


# MTK, Infinity, 20090720 {
wifi.interface=wlan0
# MTK, Infinity, 20090720 }

# MTK, mtk03034, 20101210 {
ro.mediatek.wlan.wsc=1
# MTK, mtk03034 20101210}
# MTK, mtk03034, 20110318 {
ro.mediatek.wlan.p2p=1
# MTK, mtk03034 20110318}

# MTK, mtk03034, 20101213 {
mediatek.wlan.ctia=0
# MTK, mtk03034 20101213}


#
wifi.tethering.interface=ap0
#

ro.opengles.version=131072

wifi.direct.interface=p2p0
dalvik.vm.heapgrowthlimit=96m
dalvik.vm.heapsize=128m

# USB MTP WHQL
ro.sys.usb.mtp.whql.enable=0

# Power off opt in IPO
sys.ipo.pwrdncap=2

ro.sys.usb.storage.type=mtp,mass_storage

# USB BICR function
ro.sys.usb.bicr=yes

# USB Charge only function
# Redmine:26701 M by yangshengqing for no charge only option 2014_12_31 Begin
ro.sys.usb.charging.only=no
# Redmine:26701 M by yangshengqing for no charge only option 2014_12_31 End

# audio
ro.camera.sound.forced=0
ro.audio.silent=0

ro.zygote.preload.enable=0

# temporary enables NAV bar (soft keys)
#qemu.hw.mainkeys=0

ro.kernel.zio=38,108,105,16
#chenli add for different production shut down animation and ring begin
ro.operator.optr=CUST
#chenli add for different production shut down animation and ring end

# wuyue add for timezone begin
persist.sys.timezone=Europe/Brussels
# wuyue add for timezone end


#
# ADDITIONAL_BUILD_PROPERTIES
#
persist.gemini.sim_num=2
ro.gemini.smart_sim_switch=false
ro.gemini.smart_3g_switch=1
ril.specific.sm_cause=0
bgw.current3gband=0
ril.external.md=0
ro.sf.hwrotation=0
ril.current.share_modem=2
curlockscreen=1
ro.mediatek.gemini_support=true
persist.mtk.wcn.combo.chipid=-1
drm.service.enabled=true
fmradio.driver.enable=1
ro.nfc.port=I2C
ril.first.md=1
ril.flightmode.poweroffMD=1
ril.telephony.mode=1
dalvik.vm.mtk-stack-trace-file=/data/anr/mtk_traces.txt
mediatek.wlan.chip=mediatek.wlan.module.postfix=_
ril.radiooff.poweroffMD=0
ter.service.enable=0
ro.config.notification_sound=pixiedust.ogg
ro.config.alarm_alert=Scandium.ogg
ro.config.ringtone=Ring_Classic_02.ogg
net.bt.name=Android
dalvik.vm.stack-trace-file=/data/anr/traces.txt

# begin fota properties
ro.fota.platform=MTK6572
ro.fota.type=phone
ro.fota.app=5
ro.fota.oem=sagereal6572
ro.fota.device=MobiPrint
ro.fota.version=V09_20170616_MP3_GENERIC_QB_MP
# begin fota properties


V/SettingsProvider(  502): call(global:printer_version) for 0
D/SettingsProvider(  502): lookupValue table global cache contains Key printer_version , value = Bundle[{value=}]
V/Provider/Settings(  755): from db cache, name = printer_version , value =
V/Provider/Settings(  755):  from settings cache , name = printer_version , value =
V/Provider/Settings(  755):  from settings cache , name = printer_version , value =
V/Provider/Settings(  755): Global.putString(name=printer_version, value=micro chip version V1.5F (May  4 2017 - 10:01:50) for 0
D/Provider/Settings(  755): put string name = printer_version , value = micro chip version V1.5F (May  4 2017 - 10:01:50) userHandle = 0
V/SettingsProvider(  502): call_put(global:printer_version=micro chip version V1.5F (May  4 2017 - 10:01:50)) for 0
V/SettingsProvider(  502): global <- value=micro chip version V1.5F (May  4 2017 - 10:01:50) name=printer_version for user 0
V/SettingsProvider(  502): notifying for -1: content://settings/global/printer_version
V/SettingsProvider(  502): call(global:printer_version) for 0
D/SettingsProvider(  502): lookupValue table global cache contains Key printer_version , value = Bundle[{value=micro chip version V1.5F (May  4 2017 - 10:01:50)}]
V/Provider/Settings(  755): from db cache, name = printer_version , value = micro chip version V1.5F (May  4 2017 - 10:01:50)
     */

