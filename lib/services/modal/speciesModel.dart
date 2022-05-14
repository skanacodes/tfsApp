// ignore_for_file: file_names

class SpeciesModel {
  final String id;

  final String scientificName;

  SpeciesModel({required this.id, required this.scientificName});

  factory SpeciesModel.fromJson(Map<String, dynamic> json) {
    return SpeciesModel(
      scientificName: json["scientific_name"].toString(),
      id: json["id"].toString(),
    );
  }

  static List<SpeciesModel> fromJsonList(List list) {
    return list.map((item) => SpeciesModel.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#$scientificName $id';
  }

  ///this method will prevent the override of toString
  bool? userFilterByCreationDate(String filter) {
    return scientificName.toString().contains(filter);
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(SpeciesModel? model) {
    return scientificName == model?.scientificName;
  }

  @override
  String toString() => scientificName;
}
