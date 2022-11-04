import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
  late WalletConnect connector;
  late SessionStatus session;
  String data = '';
  String signatureMetamask = '';

  void connect() async {
// Create a connector
    connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientId: '4af2e046c7a7cbff0a96dc0f594b7e13',
      clientMeta: PeerMeta(
        name: 'WalletConnect',
        description: 'WalletConnect Developer App',
        url: 'https://saddamnur.xyz',
        icons: [
          'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
        ],
      ),
    );
    setState(() {});

// Subscribe to event
    connector.on('connect', (session) {
      // print(session);
      // setState(() {
      //   data = session.toString();
      // });
    });
    connector.on('session_update', (payload) {
      // print(payload);
      // setState(() {
      //   data = payload.toString();
      // });
    });
    connector.on('disconnect', (session) {
      // print(session);
      // setState(() {
      //   data = session.toString();
      // });
    });

// Create a new session
    if (!connector.connected) {
      session = await connector.createSession(
        // chainId: 1,
        onDisplayUri: (uri) async {
          await launchUrl(Uri.parse(connector.session.toUri()),
              mode: LaunchMode.externalApplication);
          print(uri);
          setState(() {
            data = uri;
          });
        },
      );
      setState(() {});
    }
  }

  sign() async {
    String? signmessage = "Sign Message";
    List<String?> params = [connector.session.accounts.first, signmessage];
    await launchUrl(Uri.parse(connector.session.toUri()),
        mode: LaunchMode.externalApplication);
    String method = "personal_sign";
    log(Uri.parse(connector.session.toUri()).toString());
    final _signature = await connector.sendCustomRequest(
      method: method,
      params: params,
    );

    print(_signature);
    setState(() {
      signatureMetamask = _signature;
    });
  }

  send() async {
    dynamic params = {
      "from": connector.session.accounts.first,
      "to": "0xd46e8dd67c5d32be8058bb8eb970870f07244567",
      "gas": "0x76c0", // 30400
      "gasPrice": "0x9184e72a000", // 10000000000000
      "value": "0x9184e72a", // 2441406250
      "data":
          "0xd46e8dd67c5d32be8d46e8dd67c5d32be8058bb8eb970870f072445675058bb8eb970870f072445675"
    };

    await launchUrl(Uri.parse(connector.session.toUri()),
        mode: LaunchMode.externalApplication);

    String method = "eth_sendTransaction";
    log(Uri.parse(connector.session.toUri()).toString());
    final _signature = await connector.sendCustomRequest(
      method: method,
      params: [params],
    );

    print(_signature);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              QrImage(
                data: data,
                version: QrVersions.auto,
                size: 200.0,
                eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.circle, color: Colors.green),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.circle,
                  color: Colors.black,
                ),
              ),
              Text(data),
              ElevatedButton(
                  onPressed: () async {
                    connect();
                  },
                  child: Text('Connect')),
              ElevatedButton(
                  onPressed: () async {
                    sign();
                  },
                  child: Text('Sign')),
              Text(signatureMetamask),
              SizedBox(
                height: 100,
              ),
              ElevatedButton(
                  onPressed: () async {
                    send();
                  },
                  child: Text('Send'))
            ],
          ),
        ),
      ),
    );
  }
}
