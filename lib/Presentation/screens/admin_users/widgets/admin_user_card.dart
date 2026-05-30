import '../../../../index/index_main.dart';

class AdminUserCard extends StatelessWidget {
  final LocalUser user;
  final AdminUsersViewModel controller;

  const AdminUserCard({
    super.key,
    required this.user,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.borderNeutralPrimary, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _avatar(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? '—',
                  style: context.typography.mdBold.copyWith(
                    color: AppColors.textDisplay,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((user.phone ?? '').isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(
                    user.phone!,
                    style: context.typography.smRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                ],
                SizedBox(height: 6.h),
                _roleBadge(context),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline, color: AppColors.errorForeground),
            iconSize: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _avatar() {
    final initial = (user.name ?? '?').isNotEmpty
        ? (user.name![0]).toUpperCase()
        : '?';
    final color = _typeColor();

    if (user.hasImage) {
      return CircleAvatar(
        radius: 22.r,
        backgroundColor: color.withValues(alpha: 0.15),
        backgroundImage: NetworkImage(user.profileImage!),
      );
    }

    return CircleAvatar(
      radius: 22.r,
      backgroundColor: color.withValues(alpha: 0.15),
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
        ),
      ),
    );
  }

  Widget _roleBadge(BuildContext context) {
    final color = _typeColor();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _typeLabel(),
        style: context.typography.xsRegular.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _typeColor() {
    final type = user.user.userType;
    switch (type) {
      case UserType.doctor:
        return AppColors.primary;
      case UserType.assistant:
        return AppColors.blueForeground;
      case UserType.pharmacy:
        return const Color(0xFFE65100);
      case UserType.patient:
        return AppColors.grayMedium;
      default:
        return AppColors.grayMedium;
    }
  }

  String _typeLabel() {
    final type = user.user.userType;
    switch (type) {
      case UserType.doctor:
        return 'طبيب';
      case UserType.assistant:
        return 'مساعد';
      case UserType.pharmacy:
        return 'صيدلي';
      case UserType.patient:
        return 'مريض';
      default:
        return user.user.userType?.name ?? '—';
    }
  }

  void _confirmDelete(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => ConfirmBottomSheet(
        title: 'حذف ${_typeLabel()}',
        message: 'هل أنت متأكد من حذف "${user.name ?? ''}"؟\nلن تتمكن من استعادة البيانات بعد الحذف.',
        confirmText: 'حذف',
        cancelText: 'إلغاء',
        onConfirm: () => controller.deleteUser(user),
      ),
    );
  }
}
