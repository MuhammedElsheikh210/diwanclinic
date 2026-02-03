class BulkOrderModel {
  final String key;
  final int orderNum;
  final int orderReserved;

  BulkOrderModel({
    required this.key,
    required this.orderNum,
    required this.orderReserved,
  });

  Map<String, dynamic> toJson() {
    return {"order_num": orderNum, "key": key, "order_reserved": orderReserved};
  }
}
