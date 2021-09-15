import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

// override para não ter erro de handshake no Emulador quando usa o NetworkImage (NÃO USAR EM PRODUÇÃO)
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}


Future<void> main() async {
  HttpOverrides.global = new MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
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
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _imgLink = '';
  late RemoteConfig remoteConfig;

  _MyHomePageState() {
    _configureRemoteConfig();
  }

  void _configureRemoteConfig() async {
    remoteConfig = RemoteConfig.instance;
    remoteConfig.setDefaults(<String, dynamic>{
      'img_link': 'https://logodownload.org/wp-content/uploads/2019/08/localiza-hertz-logo.png',
    });
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: Duration(seconds: 10),
      minimumFetchInterval: Duration(seconds: 10),
    ));
  }

  Future<void> _associateImgLink() async {
    await remoteConfig.fetchAndActivate();
    String imgLink = remoteConfig.getString('img_link');
    setState(() {
      _imgLink = imgLink;
    });
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
            const Text(
              'You have pushed the button this many times:',
            ),
            Image(
              image: NetworkImage(_imgLink),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _associateImgLink,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
