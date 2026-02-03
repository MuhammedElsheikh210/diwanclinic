import 'package:diwanclinic/Presentation/screens/expenses/expenses/status.dart';

import '../../../../../../index/index_main.dart';

class TransactionStatusButtonsWidget extends StatelessWidget {
  final TransactionsEntity? transactionsEntity;
  final bool? showDeleteEdit;
  final void Function()? onPay;
  final void Function()? onDetails;
  final void Function()? onEdit;
  final void Function()? onDelete;

  const TransactionStatusButtonsWidget({
    super.key,
    required this.transactionsEntity,
    this.onPay,
    this.onEdit,
    this.showDeleteEdit,
    this.onDelete,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Visibility(
            visible:
                transactionsEntity?.statusKey == BilesStatus.comming.name ||
                transactionsEntity?.statusKey == BilesStatus.not_paid.name,

            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: PrimaryTextButton(
                onTap: onPay,
                appButtonSize: AppButtonSize.large,
                customBackgroundColor: AppColors.primary,
                elevation: 0,
                customBorder: BorderSide(
                  color: ColorMappingImpl().borderNeutralPrimary,
                  width: 1,
                ),
                label: AppText(
                  text: "دفع",
                  textStyle: context.typography.mdMedium.copyWith(
                    color: ColorMappingImpl().white,
                  ),
                ),
              ),
            ),
          ),
        ),

        showDeleteEdit == false
            ? const SizedBox()
            : InkWell(
                onTap: () {
                  showCustomBottomSheet(
                    context: context,
                    child: ButtonsListWidget(
                      onUpdate: () {
                        Get.back();
                        onEdit!();
                      },
                      onDelete: () {
                        Get.back();
                        onDelete!();
                      },
                    ),
                  );
                },
                child: SizedBox(
                  width: 45,
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: ColorMappingImpl().background_black_default,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Icon(
                      Icons.more_horiz,
                      color: ColorMappingImpl().white,
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
