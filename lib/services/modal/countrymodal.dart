class CountryModal {
  final String name;

  final String id;

  CountryModal({
    required this.name,
    required this.id,
  });

  factory CountryModal.fromJson(Map<String, dynamic> json) {
    return CountryModal(
      name: json["name"],
      id: json["dial_code"].toString(),
    );
  }

  static List<CountryModal> fromJsonList(List list) {
    return list.map((item) => CountryModal.fromJson(item)).toList();
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
  bool isEqual(CountryModal? model) {
    return this.name == model?.name;
  }

  @override
  String toString() => name;
}
