import 'dart:convert';
import 'package:anubavam/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class SampleModel extends Listenable {
  SampleModel();
  static SampleModel instance = SampleModel();
  static List<Employee> employeeList = <Employee>[];
  static List<Team> teamList = <Team>[];
  static Database employeeDatabase;
  static Database teamDatabase;
  static bool needToAddDataIntoTable = true;

  //ignore: prefer_collection_literals
  final Set<VoidCallback> _listeners = Set<VoidCallback>();
  @override

  /// [listener] will be invoked when the model changes.
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override

  /// [listener] will no longer be invoked when the model changes.
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Should be called only by [Model] when the model has changed.
  @protected
  void notifyListeners() {
    _listeners.toList().forEach((VoidCallback listener) => listener());
  }

  static Future<void> toUpdateTeamDataBase() async {
    teamDatabase = await DatabaseHelper.teamDatabase;
    await teamDatabase.delete('team_tb');
    await teamDatabase.insert('team_tb', {'name': 'Flutter'});
    await teamDatabase.insert('team_tb', {'name': 'Web'});
    await teamDatabase.insert('team_tb', {'name': 'Xamarin'});
  }

  static Future<void> toUpdateEmployeeDatabase() async {
    employeeDatabase = await DatabaseHelper.employeeDatabase;
    final List<dynamic> employeeData = await updateEmployeeDetails();
    await employeeDatabase.delete('employee_table');
    for (int i = 0; i < employeeData.length; i++) {
      await employeeDatabase.insert('employee_table', {
        'id': i,
        'name': employeeData[i]["name"],
        'age': employeeData[i]["age"],
        'city': employeeData[i]["city"],
        'isTeamLead': employeeData[i]["isTeamLead"],
        'teamLeadName': employeeData[i]["teamLeadName"],
        'teams': employeeData[i]["teams"].toString()
      });
    }
    List<Map<String, dynamic>> _data =
        await employeeDatabase.query('employee_table');
    employeeList..clear();
    List.generate(_data.length, (i) {
      SampleModel.employeeList.add(Employee(
          id: _data[i]['id'],
          name: _data[i]['name'],
          age: _data[i]['age'],
          city: _data[i]['city'],
          isTeamLead: _data[i]['isTeamLead'] == 0 ? false : true,
          teamLeadName: _data[i]['teamLeadName'],
          teams: convertToTeam(_data[i]['teams'])));
    });
  }

  static List<dynamic> convertToTeam(String teamDetails) {
    final List<String> splitDetails = teamDetails.split(RegExp(','));
    final List<Team> teams = <Team>[];
    for (int i = 0; i < splitDetails.length; i++) {
      String name = splitDetails[i];
      name = name
          .replaceAll(new RegExp('[^A-Za-z0-9]'), '')
          .replaceAll(new RegExp('name'), '');
      teams.add(Team(name: name));
    }
    return teams;
  }

  static Future<List<dynamic>> updateEmployeeDetails() async {
    final String loadData =
        await rootBundle.loadString('lib/employee_details.json');
    return jsonDecode(loadData);
  }

  static Future<void> updateTable() async {
    Database _updateDatabase = await DatabaseHelper.updateDatabase;
    await Future.delayed(Duration(seconds: 1));
    List<Map<String, dynamic>> updateData =
        await _updateDatabase.query('update_tb');

    if (updateData.length == 0) {
      await _updateDatabase.insert('update_tb', {'needToUpdate': 'Yes'});
      await toUpdateTeamDataBase();
      await toUpdateEmployeeDatabase();
    }
  }
}

class Employee {
  Employee(
      {this.id,
      this.name,
      this.age,
      this.city,
      this.isTeamLead,
      this.teamLeadName,
      this.teams});
  int id;
  String name;
  int age;
  String city;
  bool isTeamLead;
  String teamLeadName;
  List<Team> teams;
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
        name: json['name'],
        age: json['age'],
        city: json['city'],
        isTeamLead: json['isTeamLead'],
        teamLeadName: json['teamLeadName'],
        teams: json['teams']);
  }

  Map<String, dynamic> toMap([List<Team> teamList]) {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'age': age,
      'city': city,
      'isTeamLead': isTeamLead,
      'teamLeadName': teamLeadName,
      'teams': teamList != null
          ? jsonEncode(teamList.map((Team team) => team.toMap()).toList())
          : teamList
    };
  }
}

class Team {
  Team({this.name});
  String name;
  bool isSelected = false;
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(name: json['name']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'name': name};
  }
}
