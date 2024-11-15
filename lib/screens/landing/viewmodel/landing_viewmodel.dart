import 'dart:async';
import 'package:raven_pay_currency/imports.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

class LandingViewModel extends BaseViewModel {
  late StreamController<dynamic> streamController;
  late StreamController<dynamic> twenty4hrController;
  late StreamController<dynamic> orderBookController;
  WebSocketChannel? orderBookChannel;
  WebSocketChannel? twenty4hrChannel;
  WebSocketChannel? channel;
  List<KLineData> kLineDataList = [];
  BodyTabEnum bodyTabEnum = BodyTabEnum.chart;
  bool isSubscribed = false;
  String interval = '1h';
  String symbol = "btcusdt";

  init() async {
    streamController = StreamController<dynamic>.broadcast();
    twenty4hrController = StreamController<dynamic>.broadcast();
    orderBookController = StreamController<dynamic>.broadcast();
    channel = WebSocketChannel.connect(
      Uri.parse('wss://stream.binance.com:9443/ws'),
    );
    //

    if (twenty4hrChannel != null) twenty4hrChannel!.sink.close();
    String streamName = "$symbol@ticker";
    String binanceWebSocketUrl = "wss://stream.binance.com:9443/ws/$streamName";
    twenty4hrChannel = WebSocketChannel.connect(Uri.parse(binanceWebSocketUrl));

    String streamNameOrderBook = "$symbol@depth";
    String orderBookWebSocketUrl =
        "wss://stream.binance.com:9443/ws/$streamNameOrderBook";
    orderBookChannel =
        WebSocketChannel.connect(Uri.parse(orderBookWebSocketUrl));
    sendRequest();
  }

  setBodyTab(BodyTabEnum tab) {
    bodyTabEnum = tab;
    notifyListeners();
  }

  void sendRequest() {
    if (isSubscribed) return;
    final request = jsonEncode(
      {
        "method": "SUBSCRIBE",
        "params": ["btcusdt@aggTrade"],
        "id": 1
      },
    );
    channel!.stream.listen((data) {
      streamController.add(data);
    });
    twenty4hrChannel!.stream.listen((event) {
      twenty4hrController.add(event);
    });
    channel!.sink.add(request);
  }

  setStream(String input) {
    interval = input;
    notifyListeners();
  }

  setInterval(String input) {
    interval = input;
    notifyListeners();
  }

  @override
  void dispose() {
    if (channel == null) return;
    channel!.sink.close(status.goingAway);
    streamController.close();
    super.dispose();
  }
}
