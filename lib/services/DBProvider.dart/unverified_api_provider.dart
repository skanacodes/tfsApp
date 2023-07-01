import 'package:tfsappv1/services/DBProvider.dart/db_provider.dart';
import 'package:tfsappv1/services/modal/tpmodal.dart';

class UnverifiedTpProvider {
  Future<String> getUnverifiedTP(
    data,
  ) async {
    data.map((tp) async {
      var res =
          await DBProvider.db.createUnverifiedTpList(TransitPass.fromJson(tp));
      //print("djbj");
    }).toList();

    return "success";
  }
}
