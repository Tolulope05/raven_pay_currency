import 'dart:async';
import 'package:raven_pay_currency/imports.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class OrderBookViewModel extends BaseViewModel {
  late StreamController<dynamic> orderBookController;
  WebSocketChannel? orderBookChannel;
  double averagePrice = 0.0;
  String symbol = "btcusdt";
  int orderContent = 10;

  init() async {
    orderBookController = StreamController<dynamic>.broadcast();
    String streamNameOrderBook = "$symbol@depth";
    String orderBookWebSocketUrl =
        "wss://stream.binance.com:9443/ws/$streamNameOrderBook";
    orderBookChannel =
        WebSocketChannel.connect(Uri.parse(orderBookWebSocketUrl));
    orderBookChannel!.stream.listen((data) {
      orderBookController.add(data);
    });
    averagePriceEventBus.on<AveragePriceEvent>().listen((event) {
      averagePrice = event.input;
      notifyListeners();
    });
  }

  setOrderContent(int input) {
    orderContent = input;
    notifyListeners();
  }
}
