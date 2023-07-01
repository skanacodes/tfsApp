import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/services.dart';
import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "InventoryManager.db");
    bool dbExists = await io.File(path).exists();

    if (!dbExists) {
      // Copy from asset
      ByteData data =
          await rootBundle.load(join("assets/database", "InventoryManager.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await io.File(path).writeAsBytes(bytes, flush: true);
    }

    var theDb = await openDatabase(path, version: 1);
    return theDb;
  }

  Future<List> getEmployees() async {
    var dbClient = await db;
    List<Map> list = await dbClient!.rawQuery('SELECT * FROM User');
    List employees = [];
    for (int i = 0; i < list.length; i++) {
      employees.add({list[i]["email"], list[i]["email"]});
    }
    print(employees);
    return employees;
  }
}
