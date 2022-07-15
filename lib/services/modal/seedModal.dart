// ignore_for_file: file_names

class SeedModel {
  final String name;
  final String assesmentId;
  final String price;
  final String id;
  final String balance;

  SeedModel(
      {required this.name,
      required this.id,
      required this.balance,
      required this.price,
      required this.assesmentId});

  factory SeedModel.fromJson(Map<String, dynamic> json) {
    return SeedModel(
      balance: json["balance"].toString(),
      name: json["specie"].toString() == "null"
          ? ""
          : json["specie"]["general_specie"].toString() == "null"
              ? ""
              : json["specie"]["general_specie"]["sc_name"].toString(),
      price: json["specie"].toString() == "null"
          ? ""
          : json["specie"]["general_specie"].toString() == "null"
              ? ""
              : json["specie"]["general_specie"]["price"].toString(),
      assesmentId: json["assesment_id"].toString(),
      id: json["specie_id"].toString(),
    );
  }

  static List<SeedModel> fromJsonList(List list) {
    return list.map((item) => SeedModel.fromJson(item)).toList();
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
  bool isEqual(SeedModel? model) {
    return name == model?.name;
  }

  @override
  String toString() => name;
}
