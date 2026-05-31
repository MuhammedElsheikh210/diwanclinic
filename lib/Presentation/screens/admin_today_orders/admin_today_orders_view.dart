import '../../../index/index_main.dart';

class AdminTodayOrdersView extends StatefulWidget {
  const AdminTodayOrdersView({super.key});

  @override
  State<AdminTodayOrdersView> createState() => _AdminTodayOrdersViewState();
}

class _AdminTodayOrdersViewState extends State<AdminTodayOrdersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AdminTodayOrdersViewModel _vm;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _vm = initController(() => AdminTodayOrdersViewModel());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminTodayOrdersViewModel>(
      init: _vm,
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background_neutral_25,
          appBar: _buildAppBar(context, controller),
          body: Column(
            children: [
              _buildDoctorDropdown(context, controller),
              if (controller.selectedDoctor != null) ...[
                _buildStatsRow(context, controller),
                _buildTabs(context, controller),
              ],
              Expanded(child: _buildBody(context, controller)),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // App Bar
  // ============================================================

  AppBar _buildAppBar(
    BuildContext context,
    AdminTodayOrdersViewModel controller,
  ) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0.8,
      centerTitle: true,
      title: Column(
        children: [
          Text(
            'طلبات اليوم',
            style: context.typography.lgBold.copyWith(
              color: AppColors.textDisplay,
              fontSize: 18,
            ),
          ),
          Text(
            controller.todayLabel,
            style: context.typography.smRegular.copyWith(
              color: AppColors.textSecondaryParagraph,
              fontSize: 11,
            ),
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: AppColors.textDisplay),
      actions: [
        if (controller.selectedDoctor != null)
          IconButton(
            onPressed: controller.reloadCurrent,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث',
          ),
      ],
    );
  }

  // ============================================================
  // Doctor Dropdown
  // ============================================================

  Widget _buildDoctorDropdown(
    BuildContext context,
    AdminTodayOrdersViewModel controller,
  ) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر الطبيب',
            style: context.typography.smMedium.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),
          SizedBox(height: 8.h),
          controller.isLoadingDoctors
              ? Container(
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: AppColors.background_neutral_100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: AppColors.background_neutral_100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: controller.selectedDoctor != null
                          ? AppColors.primary.withValues(alpha: 0.4)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<LocalUser>(
                      isExpanded: true,
                      hint: Text(
                        'اختر دكتور...',
                        style: context.typography.mdRegular.copyWith(
                          color: AppColors.field_text_placeholder,
                        ),
                      ),
                      value: controller.selectedDoctor,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                      ),
                      style: context.typography.mdMedium.copyWith(
                        color: AppColors.textDisplay,
                      ),
                      items: controller.doctors.map((doctor) {
                        return DropdownMenuItem<LocalUser>(
                          value: doctor,
                          child: Text(
                            'د. ${doctor.name ?? ""}',
                            style: context.typography.mdMedium.copyWith(
                              color: AppColors.textDisplay,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: controller.selectDoctor,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // ============================================================
  // Stats Row
  // ============================================================

  Widget _buildStatsRow(
    BuildContext context,
    AdminTodayOrdersViewModel controller,
  ) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Row(
        children: [
          _statCard(
            context,
            label: 'الإجمالي',
            value: controller.orders.length,
            color: AppColors.primary,
            icon: Icons.receipt_long_rounded,
          ),
          SizedBox(width: 8.w),
          _statCard(
            context,
            label: 'الحالية',
            value: controller.activeOrders.length,
            color: Colors.orange,
            icon: Icons.pending_actions_rounded,
          ),
          SizedBox(width: 8.w),
          _statCard(
            context,
            label: 'المنتهية',
            value: controller.finishedOrders.length,
            color: const Color(0xFF10B981),
            icon: Icons.task_alt_rounded,
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required String label,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            SizedBox(height: 4.h),
            Text(
              '$value',
              style: context.typography.lgBold.copyWith(color: color),
            ),
            Text(
              label,
              style: context.typography.xsRegular.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Tabs
  // ============================================================

  Widget _buildTabs(
    BuildContext context,
    AdminTodayOrdersViewModel controller,
  ) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Container(
        height: 46.h,
        decoration: BoxDecoration(
          color: const Color(0xffE5E5E5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            _tabItem(
              context,
              title: 'الحالية (${controller.activeOrders.length})',
              index: 0,
            ),
            _tabItem(
              context,
              title: 'المنتهية (${controller.finishedOrders.length})',
              index: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(BuildContext context, {required String title, required int index}) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: context.typography.smMedium.copyWith(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Body
  // ============================================================

  Widget _buildBody(
    BuildContext context,
    AdminTodayOrdersViewModel controller,
  ) {
    if (controller.selectedDoctor == null) {
      return _emptyState(
        context,
        icon: Icons.person_search_rounded,
        message: 'اختر دكتور لعرض طلبات اليوم',
      );
    }

    if (controller.isLoadingOrders) {
      return const ShimmerLoader();
    }

    final list = _tabController.index == 0
        ? controller.activeOrders
        : controller.finishedOrders;

    if (list.isEmpty) {
      return _emptyState(
        context,
        icon: Icons.inbox_rounded,
        message: 'لا يوجد طلبات في هذه الفئة',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final order = list[index];
        return OrderCard(
          order: order,
          onOrderDetails: () => Get.to(
            () => OrderDetailsScreen(order: order),
          ),
        );
      },
    );
  }

  Widget _emptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.grayMedium.withValues(alpha: 0.4),
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: context.typography.mdMedium.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
