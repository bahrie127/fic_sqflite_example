import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'cat.dart';

class CatDB {
  Future<Database> _initCatDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cats_database.db');

    return await openDatabase(
      path,
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE cats(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  Future<void> insertCat(Cat cat) async {
    final db = await _initCatDB();
    await db.insert(
      'cats',
      cat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Cat>> cats() async {
    final db = await _initCatDB();
    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('cats');

    // Convert the List<Map<String, dynamic> into a List<Cat>.
    return List.generate(maps.length, (i) {
      return Cat(
        id: maps[i]['id'],
        name: maps[i]['name'],
        age: maps[i]['age'],
      );
    });
  }

  Future<void> updateCat(Cat cat) async {
    final db = await _initCatDB();

    await db.update(
      'cats',
      cat.toMap(),
      // Ensure that the Cat has a matching id.
      where: 'id = ?',
      // Pass the Ca's id as a whereArg to prevent SQL injection.
      whereArgs: [cat.id],
    );
  }

  Future<void> deleteCat(int id) async {
    final db = await _initCatDB();

    await db.delete(
      'cats',
      // Use a `where` clause to delete a specific cat.
      where: 'id = ?',
      // Pass the Cat's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }
}
