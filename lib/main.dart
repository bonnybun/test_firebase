import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:test_firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Object? _subscriptionResponse;
  Object? _response;
  final DatabaseReference _organizationRef =
      FirebaseDatabase.instance.ref("organizations/0");
  final DatabaseReference _dataRef =
      FirebaseDatabase.instance.ref("organizations/0/data");

  StreamSubscription<DatabaseEvent>? _subscription;

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _toggleSubscription,
              child: Text(
                  "${_subscription == null ? "Subscribe" : "Unsubscribe"}  '${_organizationRef.path}'"),
            ),
            Text(
              'Subscription Response : $_subscriptionResponse',
              maxLines: 30,
            ),
            ElevatedButton(
              onPressed: _getData,
              child: Text("Get   '${_dataRef.path}'"),
            ),
            ElevatedButton(
              onPressed: _onceData,
              child: Text("Once  '${_dataRef.path}'"),
            ),
            Text(
              '$_response',
              maxLines: 30,
            ),
          ],
        ),
      ),
    );
  }

  void _onOrganizationsUpdated(DatabaseEvent event) {
    setState(() {
      _subscriptionResponse = event.snapshot.value;
    });
  }

  void _toggleSubscription() {
    if (_subscription == null) {
      setState(() {
        _subscription =
            _organizationRef.onValue.listen(_onOrganizationsUpdated);
      });
    } else {
      _subscription?.cancel();
      setState(() {
        _response = null;
        _subscriptionResponse = null;
        _subscription = null;
      });
    }
  }

  void _getData() async {
    final value = (await _dataRef.get()).value;
    setState(() {
      _response = "get : $value";
    });
  }

  void _onceData() async {
    final value = (await _dataRef.once()).snapshot.value;
    setState(() {
      _response = "once : $value";
    });
  }
}
