// ignore_for_file: file_names

class SeedlingModel {
  final String name;
  final String balance;
  final String price;
  final String id;

  SeedlingModel(
      {required this.name,
      required this.id,
      required this.price,
      required this.balance});

  factory SeedlingModel.fromJson(Map<String, dynamic> json) {
    return SeedlingModel(
        name: json["seedling"]["seedling_name"].toString(),
        price: json["seedling"]["price"].toString(),
        id: json["seedling_id"].toString(),
        balance: json["balance"].toString());
  }

  static List<SeedlingModel> fromJsonList(List list) {
    return list.map((item) => SeedlingModel.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#$name $id';
  }

  ///this method will prevent the override of toString
  bool? userFilterByCreationDate(String filter) {
    return name.toString().contains(filter);
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(SeedlingModel? model) {
    return name == model?.name;
  }

  @override
  String toString() => name;
}
