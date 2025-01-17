class MergedItem {
  final String itemno;
  final String name;
  final String categoryid;
  final String barcode;
  final String minprice;
  final String stockCode;
  final String qty;

  MergedItem({
    required this.itemno,
    required this.name,
    required this.categoryid,
    required this.barcode,
    required this.minprice,
    required this.stockCode,
    required this.qty,
  });

  factory MergedItem.fromJson(Map<String, dynamic> json) {
    return MergedItem(
      itemno: json['itemno'] ?? '',
      name: json['name'] ?? '',
      categoryid: json['categoryid'] ?? '',
      barcode: json['barcode'] ?? '',
      minprice: json['minprice'] ?? '',
      stockCode: json['stock_code'] ?? '',
      qty: json['qty'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemno': itemno,
      'name': name,
      'categoryid': categoryid,
      'barcode': barcode,
      'minprice': minprice,
      'stock_code': stockCode,
      'qty': qty,
    };
  }
}
