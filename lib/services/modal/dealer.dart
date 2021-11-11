class DealerModel {
  final String fname;
  final String mname;
  final String lname;
  final String companyName;
  final String phoneNumber;

  DealerModel(
      {required this.fname,
      required this.lname,
      required this.mname,
      required this.phoneNumber,
      required this.companyName});

  factory DealerModel.fromJson(Map<String, dynamic> json) {
    return DealerModel(
      fname: json["first_name"].toString(),
      mname: json["middle_name"].toString(),
      lname: json["last_name"].toString(),
      companyName: json["company_name"].toString(),
      phoneNumber: json["phone_no"].toString(),
    );
  }

  static List<DealerModel> fromJsonList(List list) {
    return list.map((item) => DealerModel.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#${this.fname} ${this.lname}';
  }

  ///this method will prevent the override of toString
  bool? userFilterByCreationDate(String filter) {
    return this.fname.toString().contains(filter);
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(DealerModel? model) {
    if (this.fname == 'null') {
      return this.companyName == model?.companyName;
    } else {
      return this.fname == model?.fname;
    }
  }

  @override
  String toString() => fname;
}
