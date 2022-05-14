class ProductModel {
  final String id;

  final String productname;
  final String unit;

  ProductModel(
      {required this.id, required this.productname, required this.unit});

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json["id"].toString(),
      productname: json["product_name"],
      unit: json["unit"].toString(),
    );
  }

  static List<ProductModel> fromJsonList(List list) {
    return list.map((item) => ProductModel.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#$productname $unit';
  }

  ///this method will prevent the override of toString
  bool? userFilterByCreationDate(String filter) {
    return productname.toString().contains(filter);
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(ProductModel? model) {
    return productname == model?.productname;
  }

  @override
  String toString() => productname;
}
