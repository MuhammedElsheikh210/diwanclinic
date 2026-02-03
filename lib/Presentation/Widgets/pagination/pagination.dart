import '../../../index/index_main.dart';

class PaginationController<T> extends GetxController {
  final Future<List<T?>> Function(int page) fetchData;

  PaginationController({
    required this.fetchData,
  });

  final RxList<T?> items = <T>[].obs; // Use RxList for reactive updates
  bool isLoading = false; // Initial loading flag
  RxBool isLoadingMore = false.obs; // Pagination loading flag
  bool hasMoreData = true; // Track if there's more data to load
  int currentPage = 1;
  final ScrollController scrollController = ScrollController();

  /// Load the initial set of data
  Future<void> loadInitialData({void Function(List<T?>)? onDataLoaded}) async {
    reset();
    await _fetchData(onDataLoaded: onDataLoaded);
  }

  /// Load additional data for pagination
  Future<void> loadMoreData({void Function(List<T?>)? onDataLoaded}) async {
    if (isLoadingMore.value || !hasMoreData) return;
    currentPage++;
    await _fetchData(isLoadMore: true, onDataLoaded: onDataLoaded);
  }

  Future<void> _fetchData({
    bool isLoadMore = false,
    void Function(List<T?>)? onDataLoaded,
  }) async {
    if (isLoading || isLoadingMore.value) return;

    if (!isLoadMore) isLoading = true;
    if (isLoadMore) isLoadingMore.value = true;

    update();

    try {
      final List<T?> response = await fetchData(currentPage);
      if (onDataLoaded != null) onDataLoaded(response);

      if (response.isEmpty) {
        hasMoreData = false;
        if (!isLoadMore) items.clear(); // Ensure items are cleared if no data
      } else {
        items.addAll(response);
      }
    } catch (e) {
      hasMoreData = false;
      print('Error fetching data: $e');
    }

    isLoading = false;
    isLoadingMore.value = false;

    update();
  }

  /// Reset the pagination state
  void reset() {
    items.clear();
    currentPage = 1;
    hasMoreData = true;
  }

  /// Scroll to a specific item in the list
  void scrollToItem(int index, {double itemHeight = 100.0}) {
    if (scrollController.hasClients) {
      final position = index * itemHeight;
      scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Reset and reload initial data
  void resetAndLoadInitial({void Function(List<T?>)? onDataLoaded}) {
    reset();
    loadInitialData(onDataLoaded: onDataLoaded);
  }
}
