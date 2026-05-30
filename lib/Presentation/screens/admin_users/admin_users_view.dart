import '../../../index/index_main.dart';
import 'widgets/admin_user_card.dart';
import 'widgets/admin_doctor_expandable_card.dart';

class AdminUsersView extends StatelessWidget {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: GetBuilder<AdminUsersViewModel>(
        init: AdminUsersViewModel(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.background_neutral_25,
            appBar: _buildAppBar(context, controller),
            body: Column(
              children: [
                _buildSearchBar(context, controller),
                _buildFilterTabs(context, controller),
                Expanded(child: _buildBody(context, controller)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // App Bar
  // ============================================================

  AppBar _buildAppBar(BuildContext context, AdminUsersViewModel controller) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0.8,
      centerTitle: true,
      title: Text(
        'إدارة المستخدمين',
        style: context.typography.lgBold.copyWith(
          color: AppColors.textDisplay,
          fontSize: 20,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textDisplay),
      actions: [
        IconButton(
          onPressed: controller.reloadData,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'تحديث',
        ),
      ],
    );
  }

  // ============================================================
  // Search Bar
  // ============================================================

  Widget _buildSearchBar(BuildContext context, AdminUsersViewModel controller) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      child: TextField(
        controller: controller.searchController,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'بحث بالاسم أو رقم الهاتف...',
          hintStyle: context.typography.smRegular.copyWith(
            color: AppColors.field_text_placeholder,
          ),
          hintTextDirection: TextDirection.rtl,
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.grayMedium),
          suffixIcon: controller.searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () => controller.searchController.clear(),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: AppColors.grayMedium,
                )
              : null,
          filled: true,
          fillColor: AppColors.background_neutral_100,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Filter Tabs
  // ============================================================

  Widget _buildFilterTabs(BuildContext context, AdminUsersViewModel controller) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip(
              context,
              label: 'الكل',
              filter: AdminUserFilter.all,
              controller: controller,
              count: controller.isLoadingDoctors || controller.isLoadingPharmacy || controller.isLoadingPatients
                  ? null
                  : controller.totalCount,
            ),
            SizedBox(width: 8.w),
            _filterChip(
              context,
              label: 'الأطباء',
              filter: AdminUserFilter.doctors,
              controller: controller,
              icon: Icons.medical_services_outlined,
              count: controller.isLoadingDoctors ? null : controller.doctorsCount,
            ),
            SizedBox(width: 8.w),
            _filterChip(
              context,
              label: 'الصيادلة',
              filter: AdminUserFilter.pharmacy,
              controller: controller,
              icon: Icons.local_pharmacy_outlined,
              count: controller.isLoadingPharmacy ? null : controller.pharmacyCount,
            ),
            SizedBox(width: 8.w),
            _filterChip(
              context,
              label: 'العملاء',
              filter: AdminUserFilter.patients,
              controller: controller,
              icon: Icons.people_outline,
              count: controller.isLoadingPatients ? null : controller.patientsCount,
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(
    BuildContext context, {
    required String label,
    required AdminUserFilter filter,
    required AdminUsersViewModel controller,
    IconData? icon,
    int? count,
  }) {
    final isSelected = controller.selectedFilter == filter;
    final textColor = isSelected ? AppColors.white : AppColors.textSecondaryParagraph;

    return GestureDetector(
      onTap: () => controller.onFilterChanged(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background_neutral_100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderNeutralPrimary,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: isSelected ? AppColors.white : AppColors.grayMedium),
              SizedBox(width: 5.w),
            ],
            Text(
              label,
              style: context.typography.smMedium.copyWith(
                color: textColor,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (count != null) ...[
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.white.withValues(alpha: 0.25)
                      : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: context.typography.xsBold.copyWith(
                    color: isSelected ? AppColors.white : AppColors.primary,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Body
  // ============================================================

  Widget _buildBody(BuildContext context, AdminUsersViewModel controller) {
    if (controller.isCurrentTabLoading) {
      return const ShimmerLoader();
    }

    switch (controller.selectedFilter) {
      case AdminUserFilter.all:
        return _buildAllList(context, controller);
      case AdminUserFilter.doctors:
        return _buildDoctorsList(context, controller);
      case AdminUserFilter.pharmacy:
        return _buildFlatList(context, controller.filteredPharmacists, controller);
      case AdminUserFilter.patients:
        return _buildFlatList(context, controller.filteredPatients, controller);
    }
  }

  // ── All tab ─────────────────────────────────────────────────

  Widget _buildAllList(BuildContext context, AdminUsersViewModel controller) {
    final list = controller.filteredAll;
    if (list.isEmpty) return _emptyState(context, 'لا يوجد مستخدمون');

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: list.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final user = list[index];
        return AdminUserCard(user: user, controller: controller);
      },
    );
  }

  // ── Doctors tab ──────────────────────────────────────────────

  Widget _buildDoctorsList(BuildContext context, AdminUsersViewModel controller) {
    final doctors = controller.filteredDoctors;
    if (doctors.isEmpty) return _emptyState(context, 'لا يوجد أطباء');

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: doctors.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        final assistants = controller.assistantsOf(doctor.uid ?? '');
        return AdminDoctorExpandableCard(
          doctor: doctor,
          assistants: assistants,
          controller: controller,
        );
      },
    );
  }

  // ── Flat list (pharmacy / patients) ─────────────────────────

  Widget _buildFlatList(
    BuildContext context,
    List<LocalUser> list,
    AdminUsersViewModel controller,
  ) {
    if (list.isEmpty) return _emptyState(context, 'لا يوجد نتائج');

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: list.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        return AdminUserCard(user: list[index], controller: controller);
      },
    );
  }

  // ── Empty state ──────────────────────────────────────────────

  Widget _emptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off_outlined, size: 64, color: AppColors.grayMedium.withValues(alpha: 0.5)),
          SizedBox(height: 16.h),
          Text(
            message,
            style: context.typography.mdMedium.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),
        ],
      ),
    );
  }
}
