import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "team_with_employees.db";
  static final _databaseVersion = 1;

  static Database _userDatabase;

  static Database _employeeDatabase;

  static Database _teamDatabase;

  static Database _needToUpdateTable;

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Future<Database> get userDatabase async {
    if (_userDatabase != null) return _userDatabase;
    _userDatabase = await initUserDatabase();
    return _userDatabase;
  }

  static Future<Database> get updateDatabase async {
    if (_needToUpdateTable != null) return _needToUpdateTable;
    _needToUpdateTable = await initUserDatabase();
    return _needToUpdateTable;
  }

  static Future<Database> get employeeDatabase async {
    if (_employeeDatabase != null) return _employeeDatabase;
    _employeeDatabase = await initEmployeeDatabase();
    return _employeeDatabase;
  }

  static Future<Database> get teamDatabase async {
    if (_teamDatabase != null) return _teamDatabase;
    _teamDatabase = await initTeamDatabase();
    return _teamDatabase;
  }

  static Future<Database> initUserDatabase() async {
    if (_userDatabase != null) {
      return _userDatabase;
    }
    String path = join(await getDatabasesPath(), _databaseName);
    _userDatabase = await openDatabase(path, version: _databaseVersion);
    createUserDatabase();
    return _userDatabase;
  }

  static Future<void> createUserDatabase() async {
    try {
      await _userDatabase
          .execute('''CREATE TABLE user (username TEXT, password TEXT)''');
    } catch (e) {}
  }

  static Future<Database> initUpdateDatabase() async {
    if (_needToUpdateTable != null) {
      return _needToUpdateTable;
    }
    String path = join(await getDatabasesPath(), _databaseName);
    _needToUpdateTable = await openDatabase(path, version: _databaseVersion);
    createUpdateDatabase();
    return _needToUpdateTable;
  }

  static Future<void> createUpdateDatabase() async {
    try {
      await _needToUpdateTable
          .execute('''CREATE TABLE update_tb (needToUpdate TEXT)''');
    } catch (e) {}
  }

  static Future<Database> initEmployeeDatabase() async {
    if (_employeeDatabase != null) {
      return _employeeDatabase;
    }
    if (_userDatabase == null ||
        (_userDatabase != null && !_userDatabase.isOpen)) {
      String path = join(await getDatabasesPath(), _databaseName);
      _employeeDatabase = await openDatabase(path, version: _databaseVersion);
    } else {
      _employeeDatabase = _userDatabase;
    }
    createEmployeeDatabase();
    return _employeeDatabase;
  }

  static Future<void> createEmployeeDatabase() async {
    try {
      await _employeeDatabase.execute(
          '''CREATE TABLE employee_table (id INTEGER, name TEXT, age INTEGER, city TEXT, isTeamLead BOOLEAN, teamLeadName TEXT, teams TEXT)''');
    } catch (e) {}
  }

  static Future<Database> initTeamDatabase() async {
    if (_teamDatabase != null) {
      return _teamDatabase;
    }
    if (_userDatabase == null ||
        (_userDatabase != null && !_userDatabase.isOpen)) {
      String path = join(await getDatabasesPath(), _databaseName);
      _teamDatabase = await openDatabase(path, version: _databaseVersion);
    } else {
      _teamDatabase = _userDatabase;
    }
    createTeamDatabase();
    return _teamDatabase;
  }

  static Future<void> createTeamDatabase() async {
    try {
      await _teamDatabase.execute(
          '''CREATE TABLE team_tb (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)''');
    } catch (e) {}
  }
}
