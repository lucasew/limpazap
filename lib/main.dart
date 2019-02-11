import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './Files.dart';
import './CleanAllFloatingButton.dart';

void main() {
  runApp(ScopedModel<FilesModel>(model: FilesModel(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext ctx) {
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.green),
        home: Scaffold(
            appBar: AppBar(title: Text("Limpador de WhatsApp")),
            body: Container(
                alignment: Alignment.bottomCenter,
                child: Material(child: FilesWidget())),
            floatingActionButton: CleanAllFloatingButton()));
  }
}
