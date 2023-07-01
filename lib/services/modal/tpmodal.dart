import 'dart:convert';

List<TransitPass> transitPassFromJson(String str) => List<TransitPass>.from(
    json.decode(str).map((x) => TransitPass.fromJson(x)));

String transitPassToJson(List<TransitPass> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TransitPass {
  final int id;
  final String tpnumber;
  final String products;
  final String dealer;
  final String checkpoints;

  TransitPass(
      {required this.id,
      required this.tpnumber,
      required this.checkpoints,
      required this.dealer,
      required this.products});

  factory TransitPass.fromJson(Map<String, dynamic> json) => TransitPass(
      id: json["id"],
      tpnumber: json["tp_number"].toString(),
      checkpoints: json["checkpoints"].toString(),
      dealer: json["dealer"].toString(),
      products: json["products"].toString());

  Map<String, dynamic> toJson() => {
        "id": id,
        "tp_number": tpnumber,
        "checkpoints": checkpoints,
        "dealer": dealer,
        "products": products
      };
}
