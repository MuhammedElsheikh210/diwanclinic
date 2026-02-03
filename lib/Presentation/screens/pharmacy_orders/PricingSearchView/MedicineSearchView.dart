import '../../../../index/index_main.dart';

class MedicineSearchView extends StatelessWidget {
  final Function(MedicineModel) onSelect;

  const MedicineSearchView({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PricingSearchController>(
      builder: (c) {
        return Scaffold(
          backgroundColor: AppColors.background,

          // ───────────────── AppBar ─────────────────
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(72),
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 12, 12),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 🔙 Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Get.back(),
                    ),

                    // 🔍 Search field
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        controller: c.searchController,
                        onChanged: c.onSearchChanged,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: "ابحث عن اسم الدواء",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: c.searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    c.searchController.clear();
                                    c.searchResults.clear();
                                    c.update();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ───────────────── Body ─────────────────
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildBody(context, c),
          ),
        );
      },
    );
  }

  // ───────────────── Body States ─────────────────
  Widget _buildBody(BuildContext context, PricingSearchController c) {
    // 🔄 Loading
    if (c.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 💤 Initial
    if (c.searchController.text.isEmpty) {
      return const _EmptyHint(
        icon: Icons.medication_outlined,
        title: "ابحث عن دواء",
        subtitle: "اكتب اسم الدواء للبدء",
      );
    }

    // 📭 No results
    if (c.searchResults.isEmpty) {
      return const _EmptyHint(
        icon: Icons.search_off,
        title: "لا توجد نتائج مطابقة",
        subtitle: "يرجى تجربة اسم دواء مختلف",
      );
    }

    // 📋 Results
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: c.searchResults.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final m = c.searchResults[i];

        return _MedicineCard(
          medicine: m,
          onTap: () {
            onSelect(m);
            Get.back();
          },
        );
      },
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final MedicineModel medicine;
  final VoidCallback onTap;

  const _MedicineCard({required this.medicine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 💊 Icon
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.medication, color: AppColors.primary),
            ),

            const SizedBox(width: 14),

            // 📄 Name + Company
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name,
                    maxLines: 3,
                    style: context.typography.mdMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (medicine.company != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        medicine.company!,
                        style: context.typography.smRegular.copyWith(
                          color: AppColors.textSecondaryParagraph,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 💰 Price
            Text(
              "${medicine.price ?? 0} ج",
              style: context.typography.mdBold.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyHint({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: context.typography.mdMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: context.typography.smRegular.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
