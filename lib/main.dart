import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Reading and Writing Files',
      home: FlutterDemo(storage: CounterStorage()),
    ),
  );
}

class CounterStorage {
  Future<File> get _localFile async {
    return File('C:/Users/andrei.sokolov/Desktop/counter.txt');
  }

  Future<File> get _localFile2 async {
    return File('C:/Users/andrei.sokolov/Desktop/string.txt');
  }

  Future<List<int>> readCounters() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      List<int> myList = json.decode(contents).cast<int>();
      return myList;
    } catch (e) {
      // If encountering an error, return 0
      return [0];
    }
  }

  Future<List<String>> readStrings() async {
    try {
      final file = await _localFile2;
      final contents = await file.readAsString();
      List<String> myList = json.decode(contents).cast<String>();
      List<String> result = myList.map((e) => '\"$e\"').toList();
      return result;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  Future<File> writeListOfInt(String text) async {
    final file = await _localFile;
    return file.writeAsString(text);
  }

  Future<File> writeString(String text) async {
    final file2 = await _localFile2;
    return file2.writeAsString(text);
  }

  void clearAll() async {
    final file1 = await _localFile;
    final file2 = await _localFile2;
    file1.delete();
    file2.delete();
  }
}

class FlutterDemo extends StatefulWidget {
  const FlutterDemo({super.key, required this.storage});

  final CounterStorage storage;

  @override
  State<FlutterDemo> createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  final textContoller = TextEditingController();
  int _counter = 0;
  List<int> countersFromList = [];
  List<String> stringFromList = [];
  String stringForScreen = '';

  @override
  void initState() {
    super.initState();
    debugPrint("Run initState");
    widget.storage.readCounters().then((values2) {
      setState(() {
        _counter = 0;
        countersFromList = values2;
        _counter = values2.last;
      });
    });
    widget.storage.readStrings().then((stringForScreen2) {
      setState(() {
        stringFromList = stringForScreen2;
      });
    });
  }

  Future<File> _incrementCounter() {
    setState(() {
      _counter++;
    });
    countersFromList.remove(0);
    countersFromList.add(_counter);
    return widget.storage.writeListOfInt(countersFromList.toString());
  }

  Future<File> _addString() {
    setState(() {
      final String myString = textContoller.text.toString();
      stringFromList.add("\"$myString\"");
      stringForScreen = stringFromList.toString();
    });

    return widget.storage.writeString(stringForScreen);
  }

  void actionFun() {
    if (textContoller.text.isEmpty) {
      return;
    } else {
      _incrementCounter();
      _addString();
      textContoller.clear();
    }
  }

  void clearFun() {
    setState(() {
      _counter = 0;
      countersFromList = [];
      stringFromList = [];
      stringForScreen = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чтение и запись файлов'),
      ),
      body: Column(
        children: [
          Center(
            child: Text(
              'Вы нажали $_counter раз${_counter == 2 || _counter == 3 || _counter == 4 ? 'а' : ''}.',
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
          Text(_counter == 0 ? 'Нет значений' : countersFromList.toString()),
          Text(stringFromList.isEmpty
              ? 'Нет значений'
              : stringFromList.toString()),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: ElevatedButton(
                onPressed: () {
                  widget.storage.clearAll();
                  clearFun();
                },
                child: const Icon(Icons.delete)),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: actionFun,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
