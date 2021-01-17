import 'package:anubavam/db_helper.dart';
import 'package:anubavam/helper.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'helper.dart';

class TeamsPage extends StatefulWidget {
  TeamsPage({Key key}) : super(key: key);

  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  TextEditingController _teamNameController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static Database _teamDatabase;

  bool isNeedToGetData;

  List<Map<String, dynamic>> data;

  @override
  void initState() {
    DatabaseHelper.initUpdateDatabase();
    DatabaseHelper.initTeamDatabase();
    DatabaseHelper.initEmployeeDatabase();
    isNeedToGetData = true;
    super.initState();
  }

  Future<void> getDataFromDatabase() async {
    await SampleModel.updateTable();
    SampleModel.teamDatabase =
        _teamDatabase = await DatabaseHelper.teamDatabase;
    _teamDatabase = await DatabaseHelper.teamDatabase;
    List<Map<String, dynamic>> data = await _teamDatabase.query('team_tb');
    final List<Team> prevTeams = List.from(SampleModel.teamList);
    SampleModel.teamList.clear();
    List.generate(data.length, (i) {
      SampleModel.teamList.add(Team(name: data[i]['name']));
    });
    if ((prevTeams.length == SampleModel.teamList.length) &&
        prevTeams.isNotEmpty &&
        SampleModel.teamList.isNotEmpty) {
      for (int i = 0; i < SampleModel.teamList.length; i++) {
        if (SampleModel.teamList[i].name != prevTeams[i].name) {
          if (SampleModel.employeeList.isNotEmpty) {
            for (int j = 0; j < SampleModel.employeeList.length; j++) {
              for (int k = 0;
                  k < SampleModel.employeeList[j].teams.length;
                  k++) {
                if (prevTeams[i].name ==
                        SampleModel.employeeList[j].teams[k].name &&
                    SampleModel.employeeList[j].teams[k].name !=
                        SampleModel.teamList[i].name) {
                  SampleModel.employeeList[j].teams[k].name =
                      SampleModel.teamList[i].name;
                  await SampleModel.employeeDatabase.update(
                      'employee_table',
                      SampleModel.employeeList[j]
                          .toMap(SampleModel.employeeList[j].teams),
                      where: 'id = ?',
                      whereArgs: [SampleModel.employeeList[j].id]);
                }
              }
            }
          }
        }
      }
    }
    setState(() {
      isNeedToGetData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Teams'),
      ),
      resizeToAvoidBottomPadding: false,

      /// floatingActionButton for adding new team
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.group_add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) {
                _teamNameController.clear();
                return AlertDialog(
                  title: Text("Add Team"),
                  content: TextField(
                    onTap: () {
                      _scaffoldKey.currentState.removeCurrentSnackBar();
                    },
                    controller: _teamNameController,
                    decoration: InputDecoration(hintText: 'Enter Name Here'),
                  ),
                  actions: <Widget>[
                    RaisedButton(
                      color: Colors.green,
                      child: Text('CANCEL'),
                      onPressed: () {
                        _scaffoldKey.currentState..removeCurrentSnackBar();
                        Navigator.of(context).pop();
                      },
                    ),
                    RaisedButton(
                      color: Colors.green,
                      child: Text('OK'),
                      onPressed: () {
                        String validationText = '';

                        if (_teamNameController.text.length < 2 ||
                            _teamNameController.text.length > 15) {
                          validationText = validationText +
                              'Team name should be 2 to 15 characters.';
                        } else if (_getTeamNames()
                            .contains(_teamNameController.text)) {
                          validationText =
                              validationText + 'Team name should be unique';
                        }
                        if (validationText == '') {
                          Navigator.of(context).pop();
                          isNeedToGetData = true;
                          _teamDatabase.insert(
                              'team_tb', {'name': _teamNameController.text});
                          setState(() {});
                        } else {
                          _scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text(validationText),
                          ));
                        }
                      },
                    )
                  ],
                );
              });
        },
      ),
      body: getWidget(),
    );
  }

  List<String> _getTeamNames() {
    List<Team> teams = SampleModel.teamList;
    List<String> teamNames = <String>[];
    for (int i = 0; i < teams.length; i++) {
      teamNames.add(teams[i].name);
    }
    return teamNames;
  }

  int _getEmployeeCountOfTeam(String teamName) {
    List<Employee> employee = SampleModel.employeeList;
    int count = 0;
    for (int i = 0; i < employee.length; i++) {
      for (int j = 0; j < employee[i].teams.length; j++) {
        if (employee[i].teams[j].name == teamName) {
          count++;
        }
      }
    }
    return count;
  }

  Widget getWidget() {
    if (isNeedToGetData) {
      getDataFromDatabase();
      return Center(child: CircularProgressIndicator());
    } else {
      return SafeArea(
          child: ListView.builder(
        cacheExtent: (SampleModel.teamList.length).toDouble(),
        addAutomaticKeepAlives: true,
        itemCount: SampleModel.teamList.length,
        itemBuilder: (BuildContext context, int position) {
          return InkWell(
              splashFactory: InkRipple.splashFactory,
              hoverColor: Colors.grey.withOpacity(0.2),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: Text("Actions"),
                        content: Text('Select delete or edit team - ' +
                            SampleModel.teamList[position].name),
                        actions: <Widget>[
                          RaisedButton(
                            color: Colors.green,
                            child: Text('DELETE'),
                            onPressed: () {
                              final int employeeCount = _getEmployeeCountOfTeam(
                                  SampleModel.teamList[position].name);
                              if (employeeCount == 0) {
                                isNeedToGetData = true;
                                _teamDatabase.delete('team_tb',
                                    where: 'name = ?',
                                    whereArgs: [
                                      SampleModel.teamList[position].name
                                    ]);
                                Navigator.of(context).pop();
                                setState(() {});
                              } else {
                                Navigator.of(context).pop();
                                _scaffoldKey.currentState.showSnackBar(SnackBar(
                                  content: Text(
                                      SampleModel.teamList[position].name +
                                          ' team has ' +
                                          employeeCount.toString() +
                                          ' employees. So Can\'t delete ' +
                                          SampleModel.teamList[position].name),
                                ));
                              }
                            },
                          ),
                          RaisedButton(
                            color: Colors.green,
                            child: Text('EDIT'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              showDialog(
                                  context: context,
                                  builder: (_) {
                                    _teamNameController.text =
                                        SampleModel.teamList[position].name;
                                    return AlertDialog(
                                      title: Text("Edit Team Name"),
                                      content: TextField(
                                        controller: _teamNameController,
                                        decoration: InputDecoration(
                                            hintText: 'Enter Name Here'),
                                      ),
                                      actions: <Widget>[
                                        RaisedButton(
                                          color: Colors.green,
                                          child: Text('CANCEL'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        RaisedButton(
                                          color: Colors.green,
                                          child: Text('OK'),
                                          onPressed: () {
                                            if (_teamNameController
                                                        .text.length >=
                                                    2 &&
                                                _teamNameController
                                                        .text.length <=
                                                    15) {
                                              _teamDatabase.update(
                                                  'team_tb',
                                                  {
                                                    'name':
                                                        _teamNameController.text
                                                  },
                                                  where: 'name = ?',
                                                  whereArgs: [
                                                    SampleModel
                                                        .teamList[position].name
                                                  ]);
                                              isNeedToGetData = true;
                                              Navigator.of(context).pop();
                                              // SampleModel
                                              //         .teamList[position].name =
                                              //     _teamNameController.text
                                              //         .toString();
                                              setState(() {});
                                            } else {}
                                          },
                                        )
                                      ],
                                    );
                                  });
                            },
                          )
                        ],
                      );
                    });
              },
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.all(15),
                        child: Text(SampleModel.teamList[position].name,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w400))),
                    Divider(thickness: 2)
                  ]));
        },
      ));
    }
  }
}
