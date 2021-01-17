import 'package:anubavam/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sqflite/sqflite.dart';

import 'db_helper.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showPassword, isNewUser, forgotPassword;
  DatabaseHelper databaseHelper;
  Database dbClient;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void initState() {
    showPassword = false;
    isNewUser = false;
    forgotPassword = false;
    DatabaseHelper.initUserDatabase();
    super.initState();
  }

  Future<void> signIn() async {
    dbClient = await DatabaseHelper.userDatabase;
    try {
      User user =
          await getLogin(_usernameController.text, _passwordController.text);
      if (user != null) {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) => MyHomePage()));
      } else {
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text('Invalid User name and Password')));
      }
    } catch (e) {
      _scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text('Login failed')));
    }
  }

  Future<User> getLogin(String user, String password) async {
    dbClient = await DatabaseHelper.userDatabase;
    var res = await dbClient.rawQuery(
        "SELECT * FROM user WHERE username = '$user' and password = '$password'");

    if (res.length > 0) {
      return new User.fromMap(res.first);
    }
    return null;
  }

  Future<void> signUp() async {
    dbClient = await DatabaseHelper.userDatabase;
    await dbClient.insert("user", {
      "username": _usernameController.text.toString(),
      "password": _passwordController.text.toString()
    });
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text('Successfully Registered')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Container(
                    width: 250,
                    height: 100,
                    child: Image.asset('assets/images/anubavam.png')),
              ),
              Spacer(
                flex: 1,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.account_circle),
                      border: OutlineInputBorder(),
                      labelText: 'Email ID',
                      hintText: 'Enter valid email id'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: forgotPassword
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                            'We will send your password to the mentioned email ID',
                            style: TextStyle(fontSize: 12)),
                      )
                    : TextField(
                        controller: _passwordController,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: showPassword
                                  ? Icon(Icons.visibility)
                                  : Icon(Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(),
                            labelText: 'Password'),
                      ),
              ),
              Visibility(
                  visible: isNewUser,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: TextField(
                      controller: _confirmPasswordController,
                      obscureText: !showPassword,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: showPassword
                                ? Icon(Icons.visibility)
                                : Icon(Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(),
                          labelText: 'Confirm Password'),
                    ),
                  )),
              FlatButton(
                onPressed: () {
                  setState(() {
                    forgotPassword = !forgotPassword;
                  });
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.blue, fontSize: 15),
                ),
              ),
              Container(
                height: 50,
                width: 150,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20)),
                child: FlatButton(
                  onPressed: () {
                    if (isNewUser) {
                      if (_confirmPasswordController.text.toString() ==
                          _passwordController.text.toString()) {
                        signUp();
                        setState(() {
                          isNewUser = false;
                        });
                      } else {
                        _scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text(
                                'Password and Confirmation password should be same')));
                      }
                    } else {
                      signIn();
                    }
                  },
                  child: Text(
                    forgotPassword
                        ? 'RECOVER'
                        : isNewUser
                            ? 'SIGNUP'
                            : 'LOGIN',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  setState(() {
                    isNewUser = !isNewUser;
                  });
                },
                child: Text(
                  isNewUser ? 'Already Have An Account?' : 'New User?',
                  style: TextStyle(color: Colors.blue, fontSize: 15),
                ),
              ),
              Spacer(
                flex: 1,
              ),
            ],
          ),
        ));
  }
}

class User {
  String _username;
  String _password;

  User(this._username, this._password);

  User.fromMap(dynamic obj) {
    this._username = obj['username'];
    this._password = obj['password'];
  }

  String get username => _username;
  String get password => _password;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["username"] = _username;
    map["password"] = _password;
    return map;
  }
}
