import 'package:tfsappv1/screens/POSmanagement/posRegistration.dart';
import 'package:tfsappv1/screens/RealTimeConnection/realTimeConnection.dart';
import 'package:tfsappv1/screens/digitalSignature/digitalsignature.dart';
import 'package:tfsappv1/screens/loginway.dart/loginway.dart';
import 'package:tfsappv1/screens/updates/updates.dart';
import 'package:tfsappv1/services/constants.dart';
import 'package:tfsappv1/services/size_config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

//static const  heroTag='';
  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                    borderRadius: const BorderRadius.only(
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
              title: const Text('Register POS',
                  style: TextStyle(color: Colors.black)),
              leading: const Icon(
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
            const Divider(
              color: Colors.black,
            ),
            ListTile(
                title: const Text('Settings',
                    style: TextStyle(color: Colors.black)),
                leading: const Icon(
                  Icons.settings,
                  color: Colors.black,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                }),
            const Divider(
              color: Colors.black,
            ),
            ListTile(
                title: const Text('Digital Signature',
                    style: TextStyle(color: Colors.black)),
                leading: const Icon(
                  Icons.fingerprint_outlined,
                  color: Colors.black,
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, SignatureScreen.routeName);
                }),
            const Divider(
              color: Colors.black,
            ),
            ListTile(
              title:
                  const Text('Updates', style: TextStyle(color: Colors.black)),
              leading: const Icon(
                Icons.update,
                color: Colors.black,
              ),
              onTap: () async {
                // await canLaunch(_url)
                //     ? await launch(_url)
                //     : throw 'Could not launch $_url';
                Navigator.pop(context);

                Navigator.pushNamed(
                  context,
                  UpdateApp.routeName,
                ).then((_) => RealTimeCommunication().createConnection("3"));
              },
            ),
            const Divider(
              color: Colors.black,
            ),
            ListTile(
              title:
                  const Text('Logout', style: TextStyle(color: Colors.black)),
              leading: const Icon(
                Icons.arrow_forward,
                color: Colors.black,
              ),
              onTap: () async {
                // SharedPreferences.getInstance().then((prefs) {
                //   prefs.clear();
                // });
                Navigator.of(context).pushNamedAndRemoveUntil(
                    LoginWay.routeName, (Route<dynamic> route) => false);
                var pref = await SharedPreferences.getInstance();
                var userId = pref.getInt("user_id");
                var devId = pref.getString("deviceId");

                await RealTimeCommunication()
                    .createConnection('2', androidId: devId, id: userId);
              },
            ),
            const Divider(
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
