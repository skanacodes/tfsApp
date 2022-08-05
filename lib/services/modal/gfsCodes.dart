// ignore_for_file: file_names

class GfsModel {
  final String gfsCode;
  final List distributions;
  final String description;
  final String id;
  final String amount;
  final String levelTwoId;

  GfsModel(
      {required this.gfsCode,
      required this.description,
      required this.id,
      required this.amount,
      required this.levelTwoId,
      required this.distributions});

  factory GfsModel.fromJson(Map<String, dynamic> json) {
    return GfsModel(
        gfsCode: json["code"].toString(),
        description: json["description"],
        id: json["id"].toString(),
        amount: json["bill_amount"].toString(),
        levelTwoId: json["level_two_id"].toString(),
        distributions: json["distributions"] ?? []);
  }

  static List<GfsModel> fromJsonList(List list) {
    return list.map((item) => GfsModel.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#$gfsCode $description';
  }

  ///this method will prevent the override of toString
  bool? userFilterByCreationDate(String filter) {
    return gfsCode.toString().contains(filter);
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(GfsModel? model) {
    return gfsCode == model?.gfsCode;
  }

  @override
  String toString() => description;
}
