enum InvoiceType {
  purchase,
  sale,
  returnPurchase,
  returnSale,
  transfer,
  stockCount,
  openingBalance,
  adjustment,
}

extension InvoiceTypeTitleExtension on InvoiceType {
  String get title {
    switch (this) {
      case InvoiceType.purchase:
        return "فواتير شراء";
      case InvoiceType.sale:
        return "فواتير بيع";
      case InvoiceType.returnPurchase:
        return "مرتجع شراء";
      case InvoiceType.returnSale:
        return "مرتجع بيع";
      case InvoiceType.transfer:
        return "تحويل مخزون";
      case InvoiceType.stockCount:
        return "جرد مخزون";
      case InvoiceType.openingBalance:
        return "رصيد افتتاحي";
    // 👇 new one if you want ضبط مخزون
      case InvoiceType.adjustment:
        return "ضبط مخزون";
    }
  }
}


extension InvoiceTypeExtension on InvoiceType {
  String get value {
    switch (this) {
      case InvoiceType.purchase:
        return "purchase";
      case InvoiceType.sale:
        return "sale";
      case InvoiceType.returnPurchase:
        return "return_purchase";
      case InvoiceType.returnSale:
        return "return_sale";
      case InvoiceType.transfer:
        return "transfer";
      case InvoiceType.stockCount:
        return "stock_count";
      case InvoiceType.openingBalance:
        return "opening_balance";
      case InvoiceType.adjustment:
        return "adjustment";
    }


  }



  static InvoiceType fromString(String? value) {
    switch (value) {
      case "purchase":
        return InvoiceType.purchase;
      case "sale":
        return InvoiceType.sale;
      case "return_purchase":
        return InvoiceType.returnPurchase;
      case "return_sale":
        return InvoiceType.returnSale;
      case "transfer":
        return InvoiceType.transfer;
      case "stock_count":
        return InvoiceType.stockCount;
      case "opening_balance":
        return InvoiceType.openingBalance;
      case "adjustment":
        return InvoiceType.adjustment;
      default:
        return InvoiceType.sale; // ✅ default fallback
    }
  }
}
