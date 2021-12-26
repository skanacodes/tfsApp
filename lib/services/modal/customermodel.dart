class CustomerModel {
  final String name;
  final String address;
  final String phoneNumber;
  final String id;
  final String CategoryId;

  CustomerModel(
      {required this.CategoryId,
      required this.name,
      required this.id,
      required this.address,
      required this.phoneNumber});

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
        name: json["name"].toString(),
        phoneNumber: json["phone"].toString(),
        id: json["id"].toString(),
        CategoryId: json["category_id"].toString(),
        address: json["address"].toString());
  }

  static List<CustomerModel> fromJsonList(List list) {
    return list.map((item) => CustomerModel.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#${this.name} ${this.id}';
  }

  ///this method will prevent the override of toString
  bool? userFilterByCreationDate(String filter) {
    return this.name.toString().contains(filter);
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(CustomerModel? model) {
    return this.name == model?.name;
  }

  @override
  String toString() => name;
}
