import '../../../index/index_main.dart';

class TransactionsEntity extends BaseEntity {
  // 🔹 Identifiers & Keys
  final String? key;
  final String? keyMerchant;
  final String? keyCurior;
  final String? keyInvoice;
  final String? keyWallet;
  final String? keyExpenseCategory;
  final String? keyFrom;
  String? keyTo;
  final String? transfer_name;
  final String? uid_order;
  final String? uid_expense;

  // 🔹 Names & Titles
  final String? transactionTitle;
  final String? fromNameValue;
  String? toNameValue;
  final String? merchantName;
  final String? curiorName;
  final String? invoiceTitle;
  final String? bileTitle;
  final String? walletName;
  final String? expenseCategoryName;
  final String? expenseCategoryType;
  final String? sort_by;

  // 🔹 Amounts
  num? totalAmount;
  num? amountRest;
  num? paidAmount;
  num? pending_amount;

  // 🔹 Status
  String? status;
  String? statusKey;
  final String? transactionType;
  final String? transactionIcomeOutcome;

  // sell or refund
  final String? process_type;

  // cash or visa
  final String? sell_type;

  // 🔹 Dates
  final int? createAt;
  final int? payDate;

  // 🔹 New Fields
  final UsersEntity? usersEntity;
  final double? total;
  final String? order_status;
  int? return_product;
  int? isRepeatExpense;
  int? repeatValue;
  String? image;

  TransactionsEntity({
    this.key,
    this.keyMerchant,
    this.keyCurior,
    this.keyInvoice,
    this.keyWallet,
    this.process_type,
    this.sell_type,
    this.keyExpenseCategory,
    this.isRepeatExpense,
    this.repeatValue,
    this.image,
    this.sort_by,
    this.keyFrom,
    this.keyTo,
    this.return_product,
    this.transfer_name,
    this.uid_expense,
    this.uid_order,
    this.transactionTitle,
    this.fromNameValue,
    this.toNameValue,
    this.merchantName,
    this.curiorName,
    this.invoiceTitle,
    this.bileTitle,
    this.walletName,
    this.expenseCategoryName,
    this.expenseCategoryType,
    this.totalAmount,
    this.amountRest,
    this.paidAmount,
    this.pending_amount,
    this.status,
    this.statusKey,
    this.transactionType,
    this.transactionIcomeOutcome,
    this.createAt,
    this.payDate,
    this.usersEntity,
    this.total,
    this.order_status,
    super.uid,
  });

  @override
  List<Object?> get props => [
    key,
    keyMerchant,
    uid_order,
    sell_type,
    process_type,
    uid_expense,
    isRepeatExpense,
    repeatValue,
    image,
    keyCurior,
    keyInvoice,
    keyWallet,
    keyExpenseCategory,
    return_product,
    keyFrom,
    keyTo,
    transfer_name,
    transactionTitle,
    fromNameValue,
    toNameValue,
    merchantName,
    curiorName,
    invoiceTitle,
    bileTitle,
    walletName,
    expenseCategoryName,
    expenseCategoryType,
    totalAmount,
    amountRest,
    paidAmount,
    pending_amount,
    status,
    statusKey,
    transactionType,
    transactionIcomeOutcome,
    createAt,
    payDate,
    usersEntity,
    total,
    order_status,
    uid,
  ];

  factory TransactionsEntity.fromJson(Map<String, dynamic> json) {
    return TransactionsEntity(
      key: json['key'],
      uid_order: json['uid_order'],
      uid_expense: json['uid_expense'],
      sell_type: json['sell_type'],
      process_type: json['process_type'],
      return_product: json['return_product'],
      isRepeatExpense: json['isRepeatExpense'],
      repeatValue: json['repeatValue'],
      image: json['image'],
      keyMerchant: json['key_merchant'],
      keyCurior: json['key_curior'],
      keyInvoice: json['key_invoice'],
      keyWallet: json['key_wallet'],
      keyExpenseCategory: json['key_expense_category'],
      keyFrom: json['key_from'],
      keyTo: json['key_to'],
      transfer_name: json['transfer_name'],
      transactionTitle: json['transaction_title'],
      fromNameValue: json['from_name_value'],
      toNameValue: json['to_name_value'],
      merchantName: json['merchant_name'],
      curiorName: json['curior_name'],
      invoiceTitle: json['invoice_title'],
      bileTitle: json['bile_title'],
      walletName: json['wallet_name'],
      expenseCategoryName: json['expense_category_name'],
      expenseCategoryType: json['expenseCategoryType'],
      totalAmount: json['total_amount']?.toDouble(),
      amountRest: json['amount_rest']?.toDouble(),
      paidAmount: json['paid_amount']?.toDouble(),
      pending_amount: json['pending_amount']?.toDouble(),
      status: json['status'],
      statusKey: json['status_key'],
      transactionType: json['transaction_type'],
      transactionIcomeOutcome: json['transactionIcomeOutcome'],
      createAt: json['create_at'],
      payDate: json['pay_date'],
      total: json['total']?.toDouble(),
      order_status: json['order_status'],
      uid: json['uid'],
    );
  }

  String toStringRepresentation() {
    return "Key: ${key ?? ''}, "
        "Key Merchant: ${keyMerchant ?? ''}, "
        "process_type: ${process_type ?? ''}, "
        "sell_type: ${sell_type ?? ''}, "
        "Key Curior: ${keyCurior ?? ''}, "
        "Key Invoice: ${keyInvoice ?? ''}, "
        "Key Wallet: ${keyWallet ?? ''}, "
        "Key Expense Category: ${keyExpenseCategory ?? ''}, "
        "Key From: ${keyFrom ?? ''}, "
        "Key To: ${keyTo ?? ''}, "
        "Transfer Name: ${transfer_name ?? ''}, "
        "UID Order: ${uid_order ?? ''}, "
        "UID Expense: ${uid_expense ?? ''}, "
        "Transaction Title: ${transactionTitle ?? ''}, "
        "From Name Value: ${fromNameValue ?? ''}, "
        "To Name Value: ${toNameValue ?? ''}, "
        "Merchant Name: ${merchantName ?? ''}, "
        "Curior Name: ${curiorName ?? ''}, "
        "Invoice Title: ${invoiceTitle ?? ''}, "
        "Bile Title: ${bileTitle ?? ''}, "
        "Wallet Name: ${walletName ?? ''}, "
        "Expense Category Name: ${expenseCategoryName ?? ''}, "
        "Total Amount: ${totalAmount?.toString() ?? ''}, "
        "Amount Rest: ${amountRest?.toString() ?? ''}, "
        "Paid Amount: ${paidAmount?.toString() ?? ''}, "
        "Pending Amount: ${pending_amount?.toString() ?? ''}, "
        "Status: ${status ?? ''}, "
        "Status Key: ${statusKey ?? ''}, "
        "Transaction Type: ${transactionType ?? ''}, "
        "Transaction Income Outcome: ${transactionIcomeOutcome ?? ''}, "
        "Created At: ${createAt?.toString() ?? ''}, "
        "Pay Date: ${payDate?.toString() ?? ''}, "
        "Total: ${total?.toString() ?? ''}, "
        "Order Status: ${order_status ?? ''}, "
        "Return Product: ${return_product?.toString() ?? ''}, "
        "Is Repeat Expense: ${isRepeatExpense?.toString() ?? ''}, "
        "Repeat Value: ${repeatValue?.toString() ?? ''}, "
        "Image: ${image ?? ''}";
  }

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    void addIfPresent(String key, dynamic value) {
      if (value != null && (value is! String || value.isNotEmpty)) {
        data[key] = value;
      }
    }

    // ✅ Scalar Fields
    addIfPresent('key', key);
    addIfPresent('process_type', process_type);
    addIfPresent('sell_type', sell_type);
    addIfPresent('uid_expense', uid_expense);
    addIfPresent('uid_order', uid_order);
    addIfPresent('return_product', return_product);
    addIfPresent('isRepeatExpense', isRepeatExpense);
    addIfPresent('repeatValue', repeatValue);
    addIfPresent('image', image);
    addIfPresent('key_merchant', keyMerchant);
    addIfPresent('key_curior', keyCurior);
    addIfPresent('key_invoice', keyInvoice);
    addIfPresent('key_wallet', keyWallet);
    addIfPresent('key_expense_category', keyExpenseCategory);
    addIfPresent('key_from', keyFrom);
    addIfPresent('key_to', keyTo);
    addIfPresent('transfer_name', transfer_name);
    addIfPresent('transaction_title', transactionTitle);
    addIfPresent('from_name_value', fromNameValue);
    addIfPresent('to_name_value', toNameValue);
    addIfPresent('merchant_name', merchantName);
    addIfPresent('curior_name', curiorName);
    addIfPresent('invoice_title', invoiceTitle);
    addIfPresent('bile_title', bileTitle);
    addIfPresent('wallet_name', walletName);
    addIfPresent('expense_category_name', expenseCategoryName);
    addIfPresent('expenseCategoryType', expenseCategoryType);
    addIfPresent('total_amount', totalAmount);
    addIfPresent('amount_rest', amountRest);
    addIfPresent('paid_amount', paidAmount);
    addIfPresent('pending_amount', pending_amount);
    addIfPresent('status', status);
    addIfPresent('status_key', statusKey);
    addIfPresent('transaction_type', transactionType);
    addIfPresent('transactionIcomeOutcome', transactionIcomeOutcome);
    addIfPresent('create_at', createAt);
    addIfPresent('pay_date', payDate);
    addIfPresent('uid', uid);
    addIfPresent('total', total);
    addIfPresent('order_status', order_status);

    return data;
  }

  TransactionsEntity copyWith({
    String? key,
    String? uid_expense,
    String? uid_order,
    String? keyMerchant,
    String? keyCurior,
    String? keyInvoice,
    String? keyWallet,
    String? keyExpenseCategory,
    String? keyFrom,
    String? keyTo,
    String? transfer_name,
    int? return_Product,
    int? isRepeatExpense,
    int? repeatValue,
    String? image,
    String? transactionTitle,
    String? fromNameValue,
    String? toNameValue,
    String? process_type,
    String? sell_type,
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
    num? pending_amount,
    String? status,
    String? statusKey,
    String? transactionType,
    String? transactionIcomeOutcome,
    int? createAt,
    int? payDate,
    UsersEntity? usersEntity,
    double? total,
    String? order_status,
    String? uid,
  }) {
    return TransactionsEntity(
      key: key ?? this.key,
      process_type: process_type ?? this.process_type,
      sell_type: sell_type ?? this.sell_type,
      uid_expense: uid_expense ?? this.uid_expense,
      uid_order: uid_order ?? this.uid_order,
      keyMerchant: keyMerchant ?? this.keyMerchant,
      keyCurior: keyCurior ?? this.keyCurior,
      keyInvoice: keyInvoice ?? this.keyInvoice,
      keyWallet: keyWallet ?? this.keyWallet,
      keyExpenseCategory: keyExpenseCategory ?? this.keyExpenseCategory,
      keyFrom: keyFrom ?? this.keyFrom,
      keyTo: keyTo ?? this.keyTo,
      transfer_name: transfer_name ?? this.transfer_name,
      return_product: return_Product ?? return_product,
      isRepeatExpense: isRepeatExpense ?? this.isRepeatExpense,
      repeatValue: repeatValue ?? this.repeatValue,
      image: image ?? this.image,
      transactionTitle: transactionTitle ?? this.transactionTitle,
      fromNameValue: fromNameValue ?? this.fromNameValue,
      toNameValue: toNameValue ?? this.toNameValue,
      merchantName: merchantName ?? this.merchantName,
      curiorName: curiorName ?? this.curiorName,
      invoiceTitle: invoiceTitle ?? this.invoiceTitle,
      bileTitle: bileTitle ?? this.bileTitle,
      walletName: walletName ?? this.walletName,
      expenseCategoryName: expenseCategoryName ?? this.expenseCategoryName,
      expenseCategoryType: expenseCategoryType ?? this.expenseCategoryType,
      totalAmount: totalAmount ?? this.totalAmount,
      amountRest: amountRest ?? this.amountRest,
      paidAmount: paidAmount ?? this.paidAmount,
      pending_amount: pending_amount ?? this.pending_amount,
      status: status ?? this.status,
      statusKey: statusKey ?? this.statusKey,
      transactionType: transactionType ?? this.transactionType,
      transactionIcomeOutcome:
          transactionIcomeOutcome ?? this.transactionIcomeOutcome,
      createAt: createAt ?? this.createAt,
      payDate: payDate ?? this.payDate,
      usersEntity: usersEntity ?? this.usersEntity,
      total: total ?? this.total,
      order_status: order_status ?? this.order_status,
      uid: uid ?? this.uid,
    );
  }
}
