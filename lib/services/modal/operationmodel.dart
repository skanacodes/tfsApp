// import 'dart:convert';

// ModelOperation ModelOperationFromMap(String? str) =>
//     ModelOperation.fromMap(json.decode(str! ));

// String ModelOperationToMap(ModelOperation data) => json.encode(data.toMap());

class ModelOperation {
  ModelOperation({
    required this.id,
    required this.icon,
    required this.name,
    required this.konsumsi,
    required this.use,
    required this.active,
  });
  int icon, id;
  String name;
  double konsumsi;
  DateTime use;
  bool active;

  factory ModelOperation.fromMap(Map<String, dynamic> json) => ModelOperation(
        id: json["id"],
        icon: json["icon"],
        name: json["name"],
        konsumsi: json["konsumsi"].toDouble(),
        use: json["use"],
        active: json["active"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "icon": icon,
        "name": name,
        "konsumsi": konsumsi,
        "use": use,
        "active": active,
      };
}
