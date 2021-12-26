class GfsModel {
  final String gfsCode;

  final String description;
  final String id;

  GfsModel(
      {required this.gfsCode, required this.description, required this.id});

  factory GfsModel.fromJson(Map<String, dynamic> json) {
    return GfsModel(
      gfsCode: json["code"].toString(),
      description: json["description"],
      id: json["id"].toString(),
    );
  }

  static List<GfsModel> fromJsonList(List list) {
    return list.map((item) => GfsModel.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#${this.gfsCode} ${this.description}';
  }

  ///this method will prevent the override of toString
  bool? userFilterByCreationDate(String filter) {
    return this.gfsCode.toString().contains(filter);
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(GfsModel? model) {
    return this.gfsCode == model?.gfsCode;
  }

  @override
  String toString() => description;
}
