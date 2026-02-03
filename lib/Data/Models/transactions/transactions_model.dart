import '../../../index/index_main.dart';

class TransactionsModel extends TransactionsEntity {
  TransactionsModel({
    String? key,
    int? isRepeatExpense,
    int? repeatValue,
    String? image,
    String? keyMerchant,
    String? keyCurior,
    String? keyInvoice,
    String? keyWallet,
    String? keyExpenseCategory,
    String? keyFrom,
    String? keyTo,
    String? transfer_name,
    num? pending_amount,
    String? transactionIcomeOutcome,
    String? fromNameValue,
    String? toNameValue,
    String? merchantName,
    String? curiorName,
    String? invoiceTitle,
    String? bileTitle,
    String? walletName,
    String? expenseCategoryName,
    String? expenseCategoryType,
    num? totalAmount,
    num? amountRest,
    num? paidAmount,
    String? status,
    String? statusKey,
    String? transactionType,
    int? createAt,
    int? payDate,
    String? uid,
    int? return_product,
    double? total,
    String? order_status,
    String? process_type,
    String? sell_type,
  }) : super(
         key: key,
         isRepeatExpense: isRepeatExpense,
         repeatValue: repeatValue,
         image: image,
         keyMerchant: keyMerchant,
         keyCurior: keyCurior,
         keyInvoice: keyInvoice,
         keyWallet: keyWallet,
         return_product: return_product,
         keyExpenseCategory: keyExpenseCategory,
         keyFrom: keyFrom,
         keyTo: keyTo,
         transfer_name: transfer_name,
         pending_amount: pending_amount,
         transactionIcomeOutcome: transactionIcomeOutcome,
         fromNameValue: fromNameValue,
         toNameValue: toNameValue,
         merchantName: merchantName,
         curiorName: curiorName,
         invoiceTitle: invoiceTitle,
         bileTitle: bileTitle,
         walletName: walletName,
         expenseCategoryName: expenseCategoryName,
         expenseCategoryType: expenseCategoryType,
         totalAmount: totalAmount,
         amountRest: amountRest,
         paidAmount: paidAmount,
         status: status,
         statusKey: statusKey,
         transactionType: transactionType,
         createAt: createAt,
         payDate: payDate,
         uid: uid,
         total: total,
         order_status: order_status,
         process_type: process_type,
         sell_type: sell_type,
       );

  factory TransactionsModel.fromJson(Map<String, dynamic> json) {
    // if (json['products'] != null) {
    //   if (json['products'] is String) {
    //     final decoded = jsonDecode(json['products']);
    //     parsedProducts =
    //         decoded
    //             .map<ProductModel?>(
    //               (e) => e != null ? ProductModel.fromJson(e) : null,
    //             )
    //             .toList();
    //   } else if (json['products'] is List) {
    //     parsedProducts =
    //         (json['products'] as List)
    //             .map<ProductModel?>(
    //               (e) => e != null ? ProductModel.fromJson(e) : null,
    //             )
    //             .toList();
    //   }
    // }

    return TransactionsModel(
      key: json['key'],
      isRepeatExpense: json['isRepeatExpense'],
      repeatValue: json['repeatValue'],
      image: json['image'],
      return_product: json['return_product'],
      keyMerchant: json['key_merchant'],
      keyCurior: json['key_curior'],
      keyInvoice: json['key_invoice'],
      keyWallet: json['key_wallet'],
      keyExpenseCategory: json['key_expense_category'],
      keyFrom: json['key_from'],
      keyTo: json['key_to'],
      transfer_name: json['transfer_name'],
      transactionIcomeOutcome: json['transactionIcomeOutcome'],
      fromNameValue: json['from_name_value'],
      toNameValue: json['to_name_value'],
      merchantName: json['merchant_name'],
      curiorName: json['curior_name'],
      invoiceTitle: json['invoice_title'],
      bileTitle: json['bile_title'],
      walletName: json['wallet_name'],
      expenseCategoryName: json['expense_category_name'],
      expenseCategoryType: json['expenseCategoryType'],
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      amountRest: (json['amount_rest'] as num?)?.toDouble(),
      paidAmount: (json['paid_amount'] as num?)?.toDouble(),
      pending_amount: (json['pending_amount'] as num?)?.toDouble(),
      status: json['status'],
      statusKey: json['status_key'],
      transactionType: json['transaction_type'],
      createAt: json['create_at'],
      payDate: json['pay_date'],
      uid: json['uid'],
      total: (json['total'] as num?)?.toDouble(),
      order_status: json['order_status'],
      process_type: json['process_type'],
      sell_type: json['sell_type'],
    );
  }
}
