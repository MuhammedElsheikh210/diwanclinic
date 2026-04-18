// import 'package:pointofsale/Presentation/screens/home/home_controller.dart';
//
// import '../../../index/index_main.dart';
//
// class ExpenseHomeCardWidget extends StatelessWidget {
//   final TransactionsEntity? transactionsEntity;
//   final HomeController controller;
//
//   const ExpenseHomeCardWidget({
//     required this.transactionsEntity,
//     required this.controller,
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 350.w,
//       height: 300,
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(25.r),
//         border: Border.all(color: ColorMappingImpl().borderNeutralPrimary),
//       ),
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header Section with Status Badge
//           HeaderWidget(
//             name: transactionsEntity?.bileTitle ?? "بند المصروف",
//             title: ": نوع المصروف",
//             status_label: transactionsEntity?.status,
//             status_name: transactionsEntity?.statusKey?.toLowerCase() ?? "",
//           ),
//
//           const SizedBox(height: 10),
//           // Paid Amount
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: MerchantListTileWidget(
//                     icon: IconsConstants.payment_type,
//                     showLeading: true,
//                     title: "المبلغ المدفوع",
//                     body: "${transactionsEntity?.totalAmount ?? "0"} ج.م",
//                   ),
//                 ),
//                 Expanded(
//                   child: MerchantListTileWidget(
//                     icon: IconsConstants.payment_type,
//                     showLeading: false,
//                     title: "بند المصروفات",
//                     body: transactionsEntity?.expenseCategoryName ?? "",
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Wallet Name (Paid From)
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10.0),
//             child: Row(
//               children: [
//                 // Expense Date
//                 Expanded(
//                   child: MerchantListTileWidget(
//                     icon: IconsConstants.calendar,
//                     showLeading: true,
//                     title: "تاريخ الدفع",
//                     body: DatesUtilis.convertTimestamp(
//                       transactionsEntity?.createAt ?? 0,
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: MerchantListTileWidget(
//                     icon: IconsConstants.sales,
//                     showLeading: false,
//                     title: "الحساب المدفوع منه",
//                     body: transactionsEntity?.walletName ?? "غير محدد",
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           Padding(
//             padding: EdgeInsets.only(
//               left: 8.0.w,
//               bottom: 10.h,
//               top: 10.h,
//               right: 8.w,
//             ),
//             child: TransactionStatusButtonsWidget(
//               transactionsEntity: transactionsEntity,
//               onPay: () {
//                 if (transactionsEntity?.pending_amount != null &&
//                     transactionsEntity?.pending_amount != 0.0) {
//                   transactionsEntity?.status = BilesStatus.finished.value;
//                   transactionsEntity?.statusKey = BilesStatus.finished.name;
//                   transactionsEntity?.totalAmount =
//                       transactionsEntity?.pending_amount;
//                   transactionsEntity?.pending_amount = 0.0;
//                   processTransaction(
//                     transactionsEntity ?? TransactionsEntity(),
//                   );
//                 } else {
//                   
//                 }
//               },
//               onCancel: () {
//                 transactionsEntity?.status = BilesStatus.cancel.value;
//                 transactionsEntity?.statusKey = BilesStatus.cancel.name;
//                 ExpenseViewModel expenesController = initController(
//                   () => ExpenseViewModel(),
//                 );
//                 expenesController.updateExpense(
//                   transactionsEntity ?? TransactionsEntity(),
//                 );
//               },
//               onDetails: () {
//                 showCustomBottomSheet(
//                   context: context,
//                   child: BilesDetailsView(
//                     transactionsEntity: transactionsEntity,
//                   ),
//                 );
//               },
//               onEdit: () {
//                 if (transactionsEntity?.status == "منتهية" ||
//                     transactionsEntity?.status == "ملغي") {
//                   Loader.showInfo("المصروفات المنتهية لايمكن تعديلها ");
//                 } else {
//                   Get.delete<CreateExpenseViewModel>();
//                   showCustomBottomSheet(
//                     context: context,
//                     child: CreateExpenseView(expenseEntity: transactionsEntity),
//                   );
//                 }
//               },
//               onDelete: () {
//                 ExpenseViewModel expenesController = initController(
//                   () => ExpenseViewModel(),
//                 );
//
//                 expenesController.deleteExpense(
//                   transactionsEntity?.key ?? "",
//                   transactionsEntity ?? TransactionsEntity(),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void processTransaction(TransactionsEntity expense) {
//     WalletTransactionHelper walletHelper = initController(
//       () => WalletTransactionHelper(),
//     );
//
//     walletHelper.processTransaction_Expense(
//       transaction: expense,
//       wallets: controller.listWallets,
//       payFromHome: true,
//     );
//   }
// }
