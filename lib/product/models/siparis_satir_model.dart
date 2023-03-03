class SiparisSatirModel {
  final int id;
  final ProductModel product;
  final double amount;

  bool isAdded = false;

  SiparisSatirModel(
      {required this.id, required this.product, required this.amount});

  factory SiparisSatirModel.fromJson(Map<String, dynamic> json) {
    return SiparisSatirModel(
        id: json['ID'],
        product: ProductModel.fromJson(json['Product']),
        amount: json['Amount']);
  }
}

class ProductModel {
  final int id;
  final String barcode;
  final String name;
  final double miktar;
  late final String aciklama;
  final String unitCode;
  final String mainImageThumbUrl;

  ProductModel(
      {required this.id,
      required this.barcode,
      required this.name,
      required this.miktar,
      required String? acikla,
      required this.unitCode,
      required this.mainImageThumbUrl}) {
    if (acikla != null) {
      aciklama = acikla.isEmpty ? "-----" : acikla;
    } else {
      aciklama = "-----";
    }
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
        id: json['ID'],
        barcode: json['Barcode'],
        name: json['Name'],
        miktar: json['Miktar'],
        acikla: json['Aciklama'],
        unitCode: json['UnitCode'],
        mainImageThumbUrl: json['MainImageThumbUrl']);
  }
}
