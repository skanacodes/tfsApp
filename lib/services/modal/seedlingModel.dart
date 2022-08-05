// ignore_for_file: file_names

class SeedlingModel {
  final String name;
  final String balance;
  final String price;
  final String type;
  final String category;
  final String size;
  final String id;

  SeedlingModel(
      {required this.name,
      required this.id,
      required this.price,
      required this.balance,
      required this.category,
      required this.size,
      required this.type});

  factory SeedlingModel.fromJson(Map<String, dynamic> json) {
    return SeedlingModel(
        name: json["seedling_name"].toString(),
        price: json["price"].toString(),
        id: json["id"].toString(),
        balance: json["balance"].toString(),
        category: json["seedling_category"].toString(),
        size: json["seedling_size"].toString(),
        type: json["seedling_type"].toString());
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
