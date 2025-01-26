import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Azure SignalR Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SignalRDemo(),
    );
  }
}

class SignalRDemo extends StatefulWidget {
  const SignalRDemo({Key? key}) : super(key: key);

  @override
  State<SignalRDemo> createState() => _SignalRDemoState();
}

class _SignalRDemoState extends State<SignalRDemo> {
  late HubConnection _hubConnection;
  String _status = "Disconnected";
  String _receivedMessage = "No messages yet";

  @override
  void initState() {
    super.initState();
    _initializeSignalR();
  }

  Future<void> _initializeSignalR() async {
    // Replace this with your Azure SignalR URL
     const signalRUrl = 'https://automate20250117155727.azurewebsites.net/terminal';

    _hubConnection = HubConnectionBuilder()
        .withUrl(
         "$signalRUrl?X-Auth-Token=abc", // Add token as a query parameter
        HttpConnectionOptions(
          transport: HttpTransportType.webSockets,       ),
        )
        .build();

    // Set up connection state listeners
    _hubConnection.onclose((error) {
      setState(() {
        _status = "Disconnected";
      });
    });

    _hubConnection.onreconnected((connectionId) {
      setState(() {
        _status = "Reconnected";
      });
    });

    // Add a listener for messages
    _hubConnection.on("ReceiveMessage", (message) {
      setState(() {
        _receivedMessage = message?[0] ?? "No message content";
      });
    });

    // Start the connection
    try {
      await _hubConnection.start();
      setState(() {
           _status = "Connected with ID: ${_hubConnection.connectionId}";
     });
    } catch (e) {
      setState(() {
        _status = "Connection failed: $e";
      });
    }
  }

  Future<void> _sendMessage(String message) async {
    if (_hubConnection.state == HubConnectionState.connected) {
      await _hubConnection.invoke("SendMessage", args: [message]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Azure SignalR Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Status: $_status"),
            const SizedBox(height: 20),
            Text("Received Message: $_receivedMessage"),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(labelText: "Enter a message"),
              onSubmitted: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hubConnection.stop();
    super.dispose();
  }
}
