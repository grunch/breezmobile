import 'dart:convert';

Map<String, CurrencyData> currencyDataFromJson(String str) =>
    Map.from(json.decode(str)).map((k, v) =>
        MapEntry<String, CurrencyData>(k, CurrencyData.fromJson(k, v)));

class CurrencyData {
  String name;
  String shortName;
  int fractionSize;
  String symbol;

  CurrencyData({
    this.name,
    this.shortName,
    this.fractionSize,
    this.symbol,
  });

  factory CurrencyData.fromJson(String shortName, Map<String, dynamic> json) =>
      CurrencyData(
        name: json["name"],
        shortName: shortName,
        fractionSize: json["fractionSize"] ?? 0,
        symbol: json["symbol"] != null ? json["symbol"]["grapheme"] : shortName,
      );
}
