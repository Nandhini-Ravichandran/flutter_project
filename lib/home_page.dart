import 'package:flutter/material.dart';

import 'employees_page.dart';
import 'teams_page.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[300],
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [
                0.1,
                0.3,
                0.5,
                0.7,
                0.9
              ],
                  colors: [
                Colors.green,
                Colors.orange,
                Colors.red,
                Colors.purple,
                Colors.brown
              ])),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                    width: 250,
                    height: 75,
                    child: RaisedButton(
                      color: Colors.blue[900].withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wrap_text,
                                size: 30, color: Colors.amber[300]),
                            Padding(padding: EdgeInsets.only(left: 10)),
                            Text('Teams',
                                style: TextStyle(
                                    fontSize: 30.0,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[300])),
                          ]),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    TeamsPage()));
                      },
                    )),
                Padding(padding: EdgeInsets.only(top: 50)),
                SizedBox(
                    width: 250,
                    height: 75,
                    child: RaisedButton(
                      color: Colors.amber[200].withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.group,
                                size: 30, color: Colors.blue[900]),
                            Padding(padding: EdgeInsets.only(left: 10)),
                            Text('Employees',
                                style: TextStyle(
                                    fontSize: 30.0,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[900]))
                          ]),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    EmployeesPage(key: GlobalKey())));
                      },
                    )),
              ],
            ),
          )),
    );
  }
}
