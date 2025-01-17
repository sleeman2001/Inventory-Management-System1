import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'inventory.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE inventory (
            itemno TEXT PRIMARY KEY,
            name TEXT,
            categoryid TEXT,
            barcode TEXT,
            minprice TEXT,
            stock_code TEXT,
            qty TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertData(List<Map<String, dynamic>> data) async {
    try {
      final db = await database;
      for (var item in data) {
        await db.insert('inventory', item, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } catch (e) {
      Get.snackbar(
        "Database Error",
        "Failed to insert data into SQLite: $e",
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }


  Future<List<Map<String, dynamic>>> getInventory() async {
    try {
      final db = await database;
      return await db.query('inventory');
    } catch (e) {
      Get.snackbar(
        "Database Error",
        "Failed to retrieve data from SQLite: $e",
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return [];
    }
  }

}
