import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:notekeeper/models/note.dart';

class DatabaseHelper {
  
  static DatabaseHelper _databaseHelper; //singlton DatabaseHelper
  static Database _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle ='title';
  String colDescription = 'description';
  String colPriority = 'priority';
  String colDate = 'date';

  DatabaseHelper._createInstance(); //named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {

    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance(); //This is executed only once, singlton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {

    if (_database ==null){
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {

    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';  // we have to create the database in this path;

    //  open/create the database at a given path;
    var notesDatabase = await openDatabase(path, version: 1 , onCreate: _createDb);
    return notesDatabase;

  }

  void _createDb(Database db, int newVersion) async {

    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT ,$colTitle TEXT ,'
    ' $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

// fetch operation: get all note objects from the database
    Future<List<Map<String, dynamic>>> getNoteMapList() async {
      Database db = await this.database;
      // var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');  // option 1 writing raw sql
      var result = await db.query(noteTable, orderBy: '$colPriority ASC');       //this is option 2 using helper function
      return result;

    }
// insert operation: insert a note objects to the database
      Future<int> insertNote(Note note) async {
        Database db = await this.database;
        var result=  await db.insert(noteTable, note.toMap()); // added await on review
        return result;

      }
    // update operation: update a note objects and save it to the database
      Future<int> updateNote(Note note) async {
        var db = await this.database; // changed Database to var on review
        var result= await db.update(noteTable, note.toMap() , where: '$colId = ?' , whereArgs: [note.id]);
        return result;

      }
    // delete operation: delete a note objects from the database

      Future<int> deleteNote(int id) async {
        var db = await this.database; // changed Database to var on review
        var result= await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id ');  // I changed $id to id ???????????????????? 
        return result;
        
      }
    // get number of note objects in database
        Future<int> getCount() async {
        Database db = await this.database;
        List<Map<String,dynamic>> x = await db.rawQuery('SELECT COUNT (*) From $noteTable');
        int result = Sqflite.firstIntValue(x);
        return result;
      }
    // get the 'map list' [ List<Map> ] and convert it to 'Note List' [List<Map>]
    Future<List<Note>> getNoteList() async {

      var noteMapList = await getNoteMapList();   //get map list from db // my error I typed getNoteList() instead of getNoteMapList()
      int count = noteMapList.length;  // count the no of map entries in db table

      List<Note> noteList = List<Note>();
    // for loop to create a 'Note List' from a map list
      for(int i = 0; i < count; i++){
        noteList.add(Note.fromMapObject(noteMapList[i]));        // last stopped position
      }
      return noteList;
    }

}
