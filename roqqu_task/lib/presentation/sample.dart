import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class Sample extends StatefulWidget {
  const Sample({super.key});

  @override
  State<Sample> createState() => _SampleState();
}

class _SampleState extends State<Sample> {
  //var wsUrl = Uri.parse("wss://stream.binance.com:9443/ws");

  void bind() async {
    var wsUrl = Uri.parse("wss://stream.binance.com:9443/ws/btcusdt@trade");
    final channel = IOWebSocketChannel.connect(wsUrl);

    channel.stream.listen(
      (message) {
        print("Received: $message");
        channel.sink.add('received: $message');
      },
      onError: (error) => print("Error: $error"),
      onDone: () => print("Closed"),
    );
  }

  @override
  void initState() {
    bind();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [],
      ),
    );
  }
}
