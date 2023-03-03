class SiparisModel {
  final String cariName;
  final String orderGuid;
  final int orderID;
  final String ficheNo;
  final String orderDate;
  final String paymentTypeName;
  final int lineCount;
  final double total;
  final DeliveryAddressDetailModel deliveryAddresDetail;

  SiparisModel(
      {required this.cariName,
      required this.orderGuid,
      required this.orderID,
      required this.ficheNo,
      required this.orderDate,
      required this.paymentTypeName,
      required this.lineCount,
      required this.total,
      required this.deliveryAddresDetail});

  factory SiparisModel.fromJson(Map<String, dynamic> json) {
    return SiparisModel(
        cariName: json['CariName'],
        orderGuid: json['OrderGuid'],
        orderID: json['OrderID'],
        ficheNo: json['FicheNo'],
        orderDate: json['OrderDate'],
        paymentTypeName: json['PaymentTypeName'],
        lineCount: json['LineCount'],
        total: json['Total'],
        deliveryAddresDetail:
            DeliveryAddressDetailModel.fromJson(json['DeliveryAdressDetail']));
  }
}

class DeliveryAddressDetailModel {
  final int id;
  final String adresBasligi;
  late final String mobilePhone;
  late final String email;
  final String address;
  final String? relatedPerson;

  // create a fromJson method but take all attributes start with lowercase
  DeliveryAddressDetailModel.fromJson(Map<String, dynamic> json)
      : id = json['ID'],
        adresBasligi = json['AdresBasligi'],
        mobilePhone = json["MobilePhone"],
        email = json['Email'],
        address = json['Address'],
        relatedPerson = json['RelatedPerson'];
}
