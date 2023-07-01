// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tfsappv1/services/modal/tpmodal.dart';

class DBProvider {
  static Database? _database;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database?> get database async {
    // If database exists, return database
    if (_database != null) return _database;

    // If database don't exists, create one
    _database = await initDB();

    return _database;
  }

  // Create the database and the InventoryJobsList table
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'TfsApp.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE User('
          'id INTEGER PRIMARY KEY,'
          'email TEXT,'
          'first_name TEXT,'
          'last_name TEXT,'
          'station_name TEXT,'
          'checkpoint_name TEXT,'
          'password TEXT'
          ')');

      await db.execute('CREATE TABLE TransitPass('
          'id INTEGER PRIMARY KEY,'
          'tp_number TEXT,'
          'checkpoints TEXT,'
          'last_name TEXT,'
          'dealer TEXT,'
          'checkpoint_name TEXT,'
          'products TEXT'
          ')');
    });
  }

  // Insert InventoryJobsList on database
  createUnverifiedTpList(TransitPass tp) async {
    try {
      //await deleteAllInventoryJobsLists();
      final db = await database;
      final res = await db!.insert('TransitPass', tp.toJson());
      //getAllInventoryJobsLists();
      return res;
    } catch (e) {
      return e;
    }
  }
}
