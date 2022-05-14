// Import the library.
// ignore_for_file: file_names, avoid_print

import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_client.dart';

class RealTimeCommunication {
  Future createConnection(String operation,
      {int? id, String? androidId}) async {
    try {
      var pref = await SharedPreferences.getInstance();
      var userId = pref.getInt("user_id");
      var devId = pref.getString("deviceId");
      //The location of the SignalR Server.
      const serverUrl = "https://mis.tfs.go.tz/pos_manager_api/poshub";
      // final serverUrl = "http://41.59.82.189:9898/poshub";
// Creates the connection by using the HubConnectionBuilder.
      final hubConnection = HubConnectionBuilder()
          .withAutomaticReconnect()
          .withUrl(serverUrl)
          .build();
      print(androidId);
      print(id);
      print(userId);
      print(devId);
      print(operation);
      await hubConnection.start();
      print(hubConnection.connectionId);
      Object? res;
      operation == '1'
          ? res = await hubConnection.invoke("Connect",
              args: <Object>[id ?? userId!, androidId ?? devId!])
          : print("connected");
      print(res.toString());
      print('connected');
      sendData(hubConnection, operation, androidId ?? devId);

      //await hubConnection.stop();
    } catch (e) {
      print(e);
    }
  }

  sendData(hubConnection, op, androidId) async {
    print(op);
    int x = int.parse(op);
    var res = await hubConnection
        .invoke("LogOperation", args: <Object>[x, androidId]);
    print(res);
  }
}
