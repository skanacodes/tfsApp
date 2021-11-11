import 'package:tfsappv1/screens/POSmanagement/posRegistration.dart';
import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatelessWidget {
//static const  heroTag='';
  static const _url = 'http://mis.tfs.go.tz/fremis/download_APK';
  @override
  Widget build(BuildContext context) {
    return Container(
      width: getProportionateScreenHeight(300),
      child: Drawer(
        elevation: 20,
        child: ListView(
          children: <Widget>[
            Container(
              color: kPrimaryColor,
              child: DrawerHeader(
                child: Container(
                  height: getProportionateScreenHeight(200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(300),
                    ),
                    color: Colors.white,
                    border: Border.all(width: 1, style: BorderStyle.solid),
                  ),
                  child: Center(
                      child: Image.asset(
                    'assets/images/logo.png',
                    width: getProportionateScreenWidth(250),
                    height: getProportionateScreenHeight(150),
                  )),
                ),
              ),
            ),
            ListTile(
              title:
                  Text('Register POS', style: TextStyle(color: Colors.black)),
              leading: Icon(
                Icons.account_circle,
                color: Colors.black,
              ),
              onTap: () async {
                Navigator.pop(context);

                Navigator.pushNamed(
                  context,
                  PosReg.routeName,
                ).then((_) => RealTimeCommunication().createConnection("3"));
              },
            ),
            Divider(
              color: Colors.black,
            ),
            ListTile(
                title: Text('Settings', style: TextStyle(color: Colors.black)),
                leading: Icon(
                  Icons.settings,
                  color: Colors.black,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                }),
            Divider(
              color: Colors.black,
            ),
            ListTile(
              title: Text('Updates', style: TextStyle(color: Colors.black)),
              leading: Icon(
                Icons.update,
                color: Colors.black,
              ),
              onTap: () async {
                await canLaunch(_url)
                    ? await launch(_url)
                    : throw 'Could not launch $_url';
                Navigator.of(context).pop();
              },
            ),
            Divider(
              color: Colors.black,
            ),
            ListTile(
              title: Text('Logout', style: TextStyle(color: Colors.black)),
              leading: Icon(
                Icons.arrow_forward,
                color: Colors.black,
              ),
              onTap: () async {
                // SharedPreferences.getInstance().then((prefs) {
                //   prefs.clear();
                // });
                var pref = await SharedPreferences.getInstance();
                var userId = pref.getInt("user_id");
                var devId = pref.getString("deviceId");
                await RealTimeCommunication()
                    .createConnection('2', androidId: devId, id: userId);
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login', (Route<dynamic> route) => false);
              },
            ),
            Divider(
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
