import '../../../index/index_main.dart';

class PaginatedListView<T> extends StatelessWidget {
  final PaginationController<T> controller;
  final Widget Function(BuildContext context, T? item, int index) itemBuilder;
  final Widget? shimmerLoader;
  final Widget? paginationLoader;
  final Widget? emptyStateWidget;

  const PaginatedListView({
    Key? key,
    required this.controller,
    required this.itemBuilder,
    this.shimmerLoader,
    this.paginationLoader,
    this.emptyStateWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show shimmer loader during the initial loading
      if (controller.isLoading && controller.items.isEmpty) {
        return shimmerLoader ?? Container();
      }

      // Show an empty state message when no data is found
      if (!controller.isLoading && controller.items.isEmpty) {
        return Center(
          child: Text(
            'لا توجد بيانات',
            style: context.typography.mdMedium,
          ),
        );
      }

      // Handle the ListView with pagination
      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent &&
              !controller.isLoadingMore.value &&
              controller.hasMoreData) {
            controller.loadMoreData();
          }
          return false;
        },
        child: ListView.builder(
          controller: controller.scrollController,
          itemCount: controller.items.length +
              (controller.isLoadingMore.value && controller.hasMoreData
                  ? 1
                  : 0),
          itemBuilder: (context, index) {
            if (index < controller.items.length) {
              return itemBuilder(context, controller.items[index], index);
            } else if (controller.hasMoreData &&
                controller.isLoadingMore.value) {
              return paginationLoader ??
                  const Center(child: CircularProgressIndicator());
            }
            return const SizedBox.shrink();
          },
        ),
      );
    });
  }
}
