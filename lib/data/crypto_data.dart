import 'dart:async';

class Crypto {
  String id;
  String name;
  String price_usd;
  String percent_change_1h;
  String symbol;

  Crypto({this.id,this.name, this.price_usd, this.percent_change_1h,this.symbol});

  Crypto.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        name = map['name'],
        price_usd = map['price_usd'],
        percent_change_1h = map['percent_change_1h'],
        symbol = map['symbol'];
}

abstract class CryptoRepository {
  Future<List<Crypto>> fetchCurrencies();
}

class FetchDataException implements Exception {
  final _message;

  FetchDataException([this._message]);

  String toString() {
    if (_message == null) return "Exception";
    return "Exception: $_message";
  }
}
