class DealerModel {
  final String id;
  final String fname;
  final String mname;
  final String lname;
  final String companyName;
  final String phoneNumber;
  final String email;

  DealerModel(
      {required this.fname,
      required this.id,
      required this.lname,
      required this.mname,
      required this.phoneNumber,
      required this.companyName,
      required this.email});

  factory DealerModel.fromJson(Map<String, dynamic> json) {
    return DealerModel(
        id: json["id"].toString(),
        fname: json["first_name"].toString(),
        mname: json["middle_name"].toString(),
        lname: json["last_name"].toString(),
        companyName: json["company_name"].toString(),
        phoneNumber: json["phone_no"].toString(),
        email: json["email"].toString());
  }

  static List<DealerModel> fromJsonList(List list) {
    return list.map((item) => DealerModel.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#$fname $lname';
  }

  ///this method will prevent the override of toString
  bool? userFilterByCreationDate(String filter) {
    return fname.toString().contains(filter);
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(DealerModel? model) {
    if (companyName != 'null') {
      return companyName == model?.companyName;
    } else {
      return fname == model?.fname;
    }
  }

  @override
  String toString() {
    if (companyName != 'null') {
      return companyName;
    } else {
      return fname;
    }
  }
}
