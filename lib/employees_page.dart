import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'db_helper.dart';
import 'helper.dart';

class EmployeesPage extends StatefulWidget {
  EmployeesPage({Key key}) : super(key: key);

  @override
  _EmployeesPageState createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static Database _employeeDatabase;
  static Database _teamDatabase;
  bool isNeedToGetData;
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
    SampleModel.employeeDatabase =
        _employeeDatabase = await DatabaseHelper.employeeDatabase;
    SampleModel.teamDatabase =
        _teamDatabase = await DatabaseHelper.teamDatabase;
    List<Map<String, dynamic>> data = await _teamDatabase.query('team_tb');
    SampleModel.teamList.clear();
    List.generate(data.length, (i) {
      SampleModel.teamList.add(Team(name: data[i]['name']));
    });

    List<Map<String, dynamic>> _data =
        await _employeeDatabase.query('employee_table');
    SampleModel.employeeList..clear();
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
    setState(() {
      isNeedToGetData = false;
    });
  }

  List<dynamic> convertToTeam(String teamDetails) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Employees'),
        ),
        resizeToAvoidBottomPadding: false,

        /// for adding new employee
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.person_add),
          onPressed: () {
            if (SampleModel.teamList != null &&
                SampleModel.teamList.isNotEmpty) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => AddEmployee(
                          key: GlobalKey(), employeesPageState: this)));
            } else {
              _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text('Team not available. Create team first')));
            }
          },
        ),
        body: getWidget());
  }

  Widget getWidget() {
    if (isNeedToGetData) {
      getDataFromDatabase();
      return Center(child: CircularProgressIndicator());
    } else {
      return SafeArea(
          child: ListView.builder(
        cacheExtent: (SampleModel.employeeList.length).toDouble(),
        addAutomaticKeepAlives: true,
        itemCount: SampleModel.employeeList.length,
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
                        content: Text('Select delete or edit employee - ' +
                            SampleModel.employeeList[position].name),
                        actions: <Widget>[
                          RaisedButton(
                            color: Colors.green,
                            child: Text('DELETE'),
                            onPressed: () {
                              if (SampleModel
                                      .employeeList[position].isTeamLead !=
                                  true) {
                                isNeedToGetData = true;
                                _employeeDatabase.delete('employee_table',
                                    where: 'id = ?',
                                    whereArgs: [
                                      SampleModel.employeeList[position].id
                                    ]);
                                Navigator.of(context).pop();
                                setState(() {});
                              } else {
                                List<Employee> employeeList =
                                    getEmployeesUnderLead(SampleModel
                                        .employeeList[position].name);
                                List<String> employeeNames =
                                    getEmployeeNames(employeeList);

                                if (employeeList.isNotEmpty) {
                                  String content = '';
                                  for (int k = 0;
                                      k < employeeNames.length;
                                      k++) {
                                    content = content +
                                        (k + 1).toString() +
                                        '. ' +
                                        employeeNames[k] +
                                        '\n';
                                  }
                                  Navigator.of(context).pop();
                                  _scaffoldKey.currentState.showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Following ' +
                                                  employeeList.length
                                                      .toString() +
                                                  ' employee(s) under ' +
                                                  SampleModel
                                                      .employeeList[position]
                                                      .name +
                                                  '\n\n' +
                                                  content +
                                                  '\n'
                                                      'So please update a new lead for them before delete ' +
                                                  SampleModel
                                                      .employeeList[position]
                                                      .name,
                                              style:
                                                  TextStyle(fontSize: 20.0))));
                                } else {
                                  isNeedToGetData = true;
                                  _employeeDatabase.delete('employee_table',
                                      where: 'id = ?',
                                      whereArgs: [
                                        SampleModel.employeeList[position].id
                                      ]);
                                  Navigator.of(context).pop();
                                  setState(() {});
                                }
                              }
                            },
                          ),
                          RaisedButton(
                            color: Colors.green,
                            child: Text('EDIT'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          EditEmployee(
                                              SampleModel
                                                  .employeeList[position],
                                              this)));
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
                        padding: EdgeInsets.all(10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(SampleModel.employeeList[position].name,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500)),
                              Divider(height: 2, color: Colors.transparent),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      'Age: ' +
                                          SampleModel.employeeList[position].age
                                              .toString(),
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400)),
                                  Text(
                                      'City: ' +
                                          SampleModel
                                              .employeeList[position].city
                                              .toString(),
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400))
                                ],
                              ),
                              Divider(height: 2, color: Colors.transparent),
                              Visibility(
                                  visible: !(SampleModel
                                          .employeeList[position].isTeamLead ??
                                      false),
                                  child: Text(
                                      'Team Lead: ' +
                                          SampleModel.employeeList[position]
                                              .teamLeadName
                                              .toString(),
                                      style: TextStyle(
                                          fontSize: 17,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400))),
                              Divider(height: 5, color: Colors.transparent),
                              Wrap(
                                children: _getTeams(
                                    SampleModel.employeeList[position].teams),
                              )
                            ])),
                  ]));
        },
      ));
    }
  }

  List<String> getEmployeeNames(List<Employee> employees) {
    List<String> employeeList = <String>[];
    for (int i = 0; i < employees.length; i++) {
      employeeList.add(employees[i].name);
    }
    return employeeList;
  }

  List<Employee> getEmployeesUnderLead(String teamLead) {
    List<Employee> allEmployee = SampleModel.employeeList;
    List<Employee> employeeList = <Employee>[];
    for (int i = 0; i < allEmployee.length; i++) {
      if (allEmployee[i].teamLeadName == teamLead) {
        employeeList.add(allEmployee[i]);
      }
    }
    return employeeList;
  }

  List<Widget> _getTeams(List<Team> teams) {
    List<Widget> teamList = <Widget>[];
    for (int i = 0; i < teams.length; i++) {
      teamList.add(Container(
        padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
        child: Container(
            padding: EdgeInsets.all(5),
            child: Text(teams[i].name.toString(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.all(Radius.circular(25)))),
      ));
    }
    return teamList;
  }
}

class AddEmployee extends StatefulWidget {
  AddEmployee({Key key, this.employeesPageState}) : super(key: key);

  final _EmployeesPageState employeesPageState;

  @override
  _AddEmployeeState createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  TextEditingController _employeeNameController = TextEditingController();
  TextEditingController _employeeAgeController = TextEditingController();
  TextEditingController _employeeCityController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Employee> employeeList = SampleModel.employeeList;
  bool isTeamLead = true;
  String _selectedTeamLead;

  Employee currentEmployee;

  List<Team> selectedTeams = <Team>[];

  @override
  Widget build(BuildContext context) {
    List<String> teamLeadList = _getAvailableTeamLead();
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Add Employee'),
        ),
        resizeToAvoidBottomPadding: false,
        body: SafeArea(
          child: Container(
              padding: EdgeInsets.all(10),
              child: ListView(
                children: [
                  Text('Employee Name', style: TextStyle(fontSize: 18)),
                  TextField(
                    controller: _employeeNameController,
                    decoration: InputDecoration(hintText: 'Enter Name Here'),
                  ),
                  Divider(thickness: 4, color: Colors.transparent),
                  Text('Age',
                      style: TextStyle(
                        fontSize: 18,
                      )),
                  TextField(
                    controller: _employeeAgeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: 'Enter Age Here'),
                  ),
                  Divider(thickness: 4, color: Colors.transparent),
                  Text('City', style: TextStyle(fontSize: 18)),
                  TextField(
                      controller: _employeeCityController,
                      decoration: InputDecoration(hintText: 'Enter City Here')),
                  Divider(thickness: 4, color: Colors.transparent),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Is Team Lead', style: TextStyle(fontSize: 18)),
                      Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            value: isTeamLead,
                            onChanged: (bool value) {
                              if (value == false) {
                                List<String> _teamLeads =
                                    _getAvailableTeamLead();
                                if (_teamLeads.isEmpty) {
                                  _scaffoldKey.currentState
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        'Team lead not available. Create team lead first'),
                                  ));
                                }
                              }
                              setState(() {
                                isTeamLead = value;
                              });
                            },
                          ))
                    ],
                  ),
                  Divider(thickness: 4, color: Colors.transparent),
                  Visibility(
                      visible: !isTeamLead,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Team Lead', style: TextStyle(fontSize: 18)),
                          DropdownButton<String>(
                              value: _selectedTeamLead ??
                                  ((teamLeadList == null ||
                                          teamLeadList.isEmpty)
                                      ? ''
                                      : teamLeadList.first),
                              items: teamLeadList.map((String value) {
                                return DropdownMenuItem<String>(
                                    value: value, child: Text('$value'));
                              }).toList(),
                              onChanged: (String value) {
                                setState(() {
                                  _selectedTeamLead = value;
                                });
                              }),
                        ],
                      )),
                  Divider(thickness: 4, color: Colors.transparent),
                  Text('Team', style: TextStyle(fontSize: 18)),
                  Divider(thickness: 4, color: Colors.transparent),
                  SizedBox(
                      height: 50,
                      child: SingleChildScrollView(
                          child: Wrap(
                        children: _getAvailableTeams(SampleModel.teamList),
                      ))),
                  Divider(height: 5, color: Colors.transparent),
                  Align(
                    child: RaisedButton(
                        child: Text('SAVE'),
                        onPressed: () {
                          String validationText = '';

                          if (_employeeNameController.text == '' ||
                              _employeeNameController.text == null) {
                            validationText =
                                validationText + 'Name should not be empty. ';
                          } else if (_employeeNameController.text.length < 5 ||
                              _employeeNameController.text.length > 15) {
                            validationText = validationText +
                                'Name must be 5 to 15 characters only. ';
                          }
                          if (_employeeAgeController.text == '' ||
                              _employeeAgeController.text == null) {
                            validationText =
                                validationText + 'Age should not be empty. ';
                          } else if (_employeeAgeController.text.length != 2) {
                            validationText =
                                validationText + 'Age should be 2 characters. ';
                          } else if (int.tryParse(
                                  _employeeAgeController.text) ==
                              null) {
                            validationText =
                                validationText + 'Age must be integer. ';
                          }
                          if (_employeeNameController.text == '' ||
                              _employeeNameController.text == null) {
                            validationText =
                                validationText + 'City should not be empty. ';
                          } else if (_employeeCityController.text.length < 5 ||
                              _employeeCityController.text.length > 15) {
                            validationText = validationText +
                                'City must be 5 to 15 characters only. ';
                          }
                          if (!isTeamLead && _selectedTeamLead == null) {
                            validationText =
                                validationText + 'Team lead must be selected. ';
                          }
                          if (selectedTeams.isEmpty || selectedTeams == null) {
                            validationText =
                                validationText + 'Team must be selected. ';
                          }

                          if (validationText == '') {
                            currentEmployee = Employee(
                                id: SampleModel.employeeList.length,
                                teamLeadName: _selectedTeamLead,
                                teams: selectedTeams,
                                age: int.tryParse(_employeeAgeController.text),
                                name: _employeeNameController.text,
                                isTeamLead: isTeamLead,
                                city: _employeeCityController.text);
                            if (widget.employeesPageState != null &&
                                widget.employeesPageState.mounted) {
                              widget.employeesPageState.isNeedToGetData = true;
                              SampleModel.employeeDatabase.insert(
                                  'employee_table',
                                  currentEmployee.toMap(selectedTeams));
                              widget.employeesPageState.setState(() {});
                              Navigator.of(context).pop();
                            }
                          } else {
                            _scaffoldKey.currentState.showSnackBar(
                                SnackBar(content: Text(validationText)));
                          }
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                  )
                ],
              )),
        ));
  }

  List<Widget> _getAvailableTeams(List<Team> teams) {
    List<Widget> teamList = <Widget>[];
    for (int i = 0; i < teams.length; i++) {
      teamList.add(Container(
          padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
          child: InkWell(
            onTap: () {
              bool isRemoved = false;
              teams[i].isSelected = !(teams[i].isSelected ?? false);
              if (selectedTeams.isNotEmpty) {
                final int index = selectedTeams.indexOf(teams[i]);
                if (index > -1) {
                  isRemoved = true;
                  selectedTeams.removeAt(index);
                }
              }
              setState(() {
                if (!isRemoved) {
                  selectedTeams.add(teams[i]);
                }
              });
            },
            child: Container(
                padding: EdgeInsets.all(5),
                child: Text(teams[i].name.toString(),
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                decoration: BoxDecoration(
                    color: teams[i].isSelected ?? false
                        ? Colors.blue
                        : Colors.grey[200],
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.all(Radius.circular(25)))),
          )));
    }
    return teamList;
  }

  List<String> _getAvailableTeamLead() {
    List<Employee> employeeList = SampleModel.employeeList;
    List<String> teamLeads = <String>[];
    for (int i = 0; i < employeeList.length; i++) {
      if (employeeList[i].isTeamLead == true) {
        teamLeads.add(employeeList[i].name);
      }
    }
    return teamLeads;
  }
}

class EditEmployee extends StatefulWidget {
  const EditEmployee(this.employee, this.employeesPageState, {Key key})
      : super(key: key);

  final Employee employee;

  final _EmployeesPageState employeesPageState;

  @override
  _EditEmployeeState createState() => _EditEmployeeState(employee);
}

class _EditEmployeeState extends State<EditEmployee> {
  _EditEmployeeState(this.employee);
  Employee employee;
  TextEditingController _employeeNameController = TextEditingController();
  TextEditingController _employeeAgeController = TextEditingController();
  TextEditingController _employeeCityController = TextEditingController();

  List<Employee> employeeList = SampleModel.employeeList;
  bool isTeamLead;
  String _selectedTeamLead;
  Employee currentEmployee;
  List<Team> currentTeams;

  @override
  void initState() {
    super.initState();
    currentTeams = List<Team>.from(employee.teams);
    _selectedTeamLead = employee.teamLeadName;
    isTeamLead = employee.isTeamLead;
    _employeeNameController.text = employee.name;
    _employeeAgeController.text = employee.age.toString();
    _employeeCityController.text = employee.city;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    List<String> teamLeadList = _getAvailableTeamLead();
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Edit Employee Details'),
        ),
        resizeToAvoidBottomPadding: false,
        body: SafeArea(
          child: Container(
              padding: EdgeInsets.all(10),
              child: ListView(
                children: [
                  Text('Employee Name', style: TextStyle(fontSize: 18)),
                  TextField(controller: _employeeNameController),
                  Divider(thickness: 4, color: Colors.transparent),
                  Text('Age',
                      style: TextStyle(
                        fontSize: 18,
                      )),
                  TextField(
                      controller: _employeeAgeController,
                      keyboardType: TextInputType.number),
                  Divider(thickness: 4, color: Colors.transparent),
                  Text('City', style: TextStyle(fontSize: 18)),
                  TextField(controller: _employeeCityController),
                  Divider(thickness: 4, color: Colors.transparent),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Is Team Lead', style: TextStyle(fontSize: 18)),
                      Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            value: isTeamLead,
                            onChanged: (bool value) {
                              setState(() {
                                isTeamLead = value;
                              });
                            },
                          ))
                    ],
                  ),
                  Divider(thickness: 4, color: Colors.transparent),
                  Visibility(
                      visible: !isTeamLead,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Team Lead', style: TextStyle(fontSize: 18)),
                          DropdownButton<String>(
                              value: _selectedTeamLead ?? teamLeadList.first,
                              items: teamLeadList.map((String value) {
                                return DropdownMenuItem<String>(
                                    value: value, child: Text('$value'));
                              }).toList(),
                              onChanged: (String value) {
                                setState(() {
                                  _selectedTeamLead = value;
                                });
                              }),
                        ],
                      )),
                  Divider(thickness: 4, color: Colors.transparent),
                  Text('Team', style: TextStyle(fontSize: 18)),
                  Divider(thickness: 4, color: Colors.transparent),
                  SizedBox(
                      height: 50,
                      child: SingleChildScrollView(
                          child: Wrap(
                        children: _getAvailableTeams(),
                      ))),
                  Divider(height: 5, color: Colors.transparent),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RaisedButton(
                          child: Text('CANCEL'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                      RaisedButton(
                          child: Text('SAVE'),
                          onPressed: () {
                            String validationText = '';

                            if (_employeeNameController.text == '' ||
                                _employeeNameController.text == null) {
                              validationText =
                                  validationText + 'Name should not be empty. ';
                            } else if (_employeeNameController.text.length <
                                    5 ||
                                _employeeNameController.text.length > 15) {
                              validationText = validationText +
                                  'Name must be 5 to 15 characters only. ';
                            }
                            if (_employeeAgeController.text == '' ||
                                _employeeAgeController.text == null) {
                              validationText =
                                  validationText + 'Age should not be empty. ';
                            } else if (_employeeAgeController.text.length !=
                                2) {
                              validationText = validationText +
                                  'Age should be 2 characters. ';
                            } else if (int.tryParse(
                                    _employeeAgeController.text) ==
                                null) {
                              validationText =
                                  validationText + 'Age must be integer. ';
                            }
                            if (_employeeNameController.text == '' ||
                                _employeeNameController.text == null) {
                              validationText =
                                  validationText + 'City should not be empty. ';
                            } else if (_employeeCityController.text.length <
                                    5 ||
                                _employeeCityController.text.length > 15) {
                              validationText = validationText +
                                  'City must be 5 to 15 characters only. ';
                            }
                            if (!isTeamLead && _selectedTeamLead == null) {
                              validationText = validationText +
                                  'Team lead must be selected. ';
                            }
                            if (currentTeams.isEmpty || currentTeams == null) {
                              validationText =
                                  validationText + 'Team must be selected. ';
                            }

                            if (validationText == '') {
                              currentEmployee = Employee(
                                  id: employee.id,
                                  teamLeadName: _selectedTeamLead,
                                  teams: currentTeams,
                                  age:
                                      int.tryParse(_employeeAgeController.text),
                                  name: _employeeNameController.text,
                                  isTeamLead: isTeamLead,
                                  city: _employeeCityController.text);
                              if (widget.employeesPageState != null &&
                                  widget.employeesPageState != null &&
                                  widget.employeesPageState.mounted) {
                                widget.employeesPageState.isNeedToGetData =
                                    true;
                                SampleModel.employeeDatabase.update(
                                    'employee_table',
                                    currentEmployee.toMap(currentTeams),
                                    where: 'id = ?',
                                    whereArgs: [employee.id]);
                                widget.employeesPageState.setState(() {});
                                Navigator.of(context).pop();
                              }
                            } else {
                              _scaffoldKey.currentState.showSnackBar(
                                  SnackBar(content: Text(validationText)));
                            }
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)))
                    ],
                  )
                ],
              )),
        ));
  }

  List<Widget> _getAvailableTeams() {
    List<Widget> teamList = <Widget>[];
    final List<Team> teamNames = List<Team>.from(SampleModel.teamList);
    for (int i = 0; i < teamNames.length; i++) {
      for (int j = 0; j < currentTeams.length; j++) {
        if (currentTeams[j].name == teamNames[i].name) {
          teamNames[i].isSelected = true;
          break;
        }
      }
      teamList.add(StatefulBuilder(
          builder: (BuildContext buildContext, StateSetter updateCurrentChild) {
        return Container(
            padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: InkWell(
              onTap: () {
                bool isRemoved = false;
                teamNames[i].isSelected = !teamNames[i].isSelected;
                final int index = getIndexFromTeams(teamNames[i], currentTeams);
                if (index > -1) {
                  isRemoved = true;
                  currentTeams.removeAt(index);
                }
                updateCurrentChild(() {
                  if (!isRemoved) {
                    currentTeams.add(teamNames[i]);
                  }
                });
              },
              child: Container(
                  padding: EdgeInsets.all(5),
                  child: Text(teamNames[i].name.toString(),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                  decoration: BoxDecoration(
                      color: teamNames[i].isSelected == true
                          ? Colors.blue
                          : Colors.grey[200],
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(25)))),
            ));
      }));
    }
    return teamList;
  }

  int getIndexFromTeams(Team currenTeam, List<Team> allTeams) {
    if (allTeams.isNotEmpty) {
      for (int i = 0; i < allTeams.length; i++) {
        if (allTeams[i].name == currenTeam.name) {
          return i;
        }
      }
    }
    return -1;
  }

  List<String> _getAvailableTeamLead() {
    List<Employee> employeeList = SampleModel.employeeList;
    List<String> teamLeads = <String>[];
    for (int i = 0; i < employeeList.length; i++) {
      if (employeeList[i].isTeamLead == true) {
        teamLeads.add(employeeList[i].name);
      }
    }
    return teamLeads;
  }
}
