import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Reading and Writing Files',
      home: FlutterDemo(storage: CounterStorage()),
    ),
  );
}

class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    return File('C:/Users/andrei.sokolov/Desktop/counter.txt');
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<List<int>> readCounters() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      List<int> myList = json.decode(contents).cast<int>();
      return  myList;
    } catch (e) {
      // If encountering an error, return 0
      return [0];
    }
  }

  Future<File> writeCounter(int counter) async {
  final file = await _localFile;
  return file.writeAsString('$counter');
}

  Future<File> writeList(String text) async {
    final file = await _localFile;
    return file.writeAsString(text);
  }

}

class FlutterDemo extends StatefulWidget {
  const FlutterDemo({super.key, required this.storage});

  final CounterStorage storage;

  @override
  State<FlutterDemo> createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  int _counter = 1;
  List<int> values = [];

  @override
  void initState() {
    super.initState();
    /*widget.storage.readCounter().then((value) {
      setState(() {
        _counter = value;
        //values.add(_counter);
      });
    });*/
    widget.storage.readCounters().then((values2) {
      setState(() {
        values = values2;
        _counter = values2.last;
      });
    });
  }

  Future<File> _incrementCounter() {
    setState(() {
      _counter++;     
    });
    values.add(_counter);
    return widget.storage.writeList(values.toString());
  }

  /*Future<File> _incrementCounter() {
    setState(() {
      _counter++;
    });

    // Write the variable as a string to the file.
    return widget.storage.writeCounter(_counter);
  }*/

  @override
  Widget build(BuildContext context) {

    final textContoller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading and Writing Files'),
      ),
      body: Column(
        children: [

          Center(
            child: Text(
              'Button tapped $_counter time${_counter == 1 ? '' : 's'}.',
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: textContoller,
                textCapitalization:
                    TextCapitalization.sentences, //текст с заглавной буквы
                maxLines: 1,
                decoration: const InputDecoration(
                    hintText: 'Текст',
                    labelText: 'Введите текст',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 0.75,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ))),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}