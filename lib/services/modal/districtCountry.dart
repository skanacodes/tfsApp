// ignore_for_file: file_names

class DistrictModal {
  final String name;

  final String id;

  DistrictModal({
    required this.name,
    required this.id,
  });

  factory DistrictModal.fromJson(Map<String, dynamic> json) {
    return DistrictModal(
      name: json["name"],
      id: json["id"].toString(),
    );
  }

  static List<DistrictModal> fromJsonList(List list) {
    return list.map((item) => DistrictModal.fromJson(item)).toList();
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
  bool isEqual(DistrictModal? model) {
    return name == model?.name;
  }

  @override
  String toString() => name;
}
