class AccessionNumberModel {
  final String id;
  final String assesmentNumber;
  final String accessionNumber;

  AccessionNumberModel(
      {required this.assesmentNumber,
      required this.id,
      required this.accessionNumber});

  factory AccessionNumberModel.fromJson(Map<String, dynamic> json) {
    return AccessionNumberModel(
        id: json["id"].toString(),
        assesmentNumber: json["assesment_number"].toString(),
        accessionNumber: json["accession_number"]);
  }

  static List<AccessionNumberModel> fromJsonList(List list) {
    return list.map((item) => AccessionNumberModel.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#${this.accessionNumber} ${this.id}';
  }

  ///this method will prevent the override of toString
  bool? userFilterByCreationDate(String filter) {
    return this.accessionNumber.toString().contains(filter);
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(AccessionNumberModel? model) {
    return this.accessionNumber == model?.accessionNumber;
  }

  @override
  String toString() => accessionNumber;
}
