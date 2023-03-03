class PaymentTypeModel {
  final int code;
  final String typeName;
  final String typeDescription;

  PaymentTypeModel(
      {required this.code,
      required this.typeName,
      required this.typeDescription});

  factory PaymentTypeModel.fromJson(Map<String, dynamic> json) {
    return PaymentTypeModel(
      code: json['Code'],
      typeName: json['TypeName'],
      typeDescription: json['TypeDescription'],
    );
  }
}
