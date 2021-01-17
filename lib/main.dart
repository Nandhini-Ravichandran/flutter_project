import 'dart:async';

import 'package:flutter/material.dart';

import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AnubavamApp());
}

class AnubavamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Anubavam',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: InitialPage());
  }
}

class InitialPage extends StatefulWidget {
  InitialPage({Key key}) : super(key: key);

  @override
  IntialPageState createState() => IntialPageState();
}

class IntialPageState extends State<InitialPage> {
  bool isInitialLoading;
  bool isCompleted;

  @override
  void initState() {
    isInitialLoading = true;
    isCompleted = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget renderWidget;
    if (isInitialLoading) {
      isInitialLoading = false;
      renderWidget = Stack(children: [
        Container(decoration: BoxDecoration(color: Colors.white)),
        Align(
            alignment: Alignment.center,
            child: Image.asset('assets/images/anubavam.png', scale: 0.7))
      ]);
      Future.delayed(const Duration(milliseconds: 500), () => setState(() {}));
    } else if (!isInitialLoading && !isCompleted) {
      renderWidget = Stack(children: [
        Container(decoration: BoxDecoration(color: Colors.white)),
        Align(
            alignment: Alignment.center,
            child: Image.asset('assets/images/anubavam.png', scale: 0.7)),
        Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.25),
            child: CircularProgressIndicator())
      ]);
      Future.delayed(Duration(milliseconds: 2000), () {
        isCompleted = true;
        setState(() {});
      });
    } else {
      renderWidget = LoginPage();
    }
    return renderWidget;
  }
}
