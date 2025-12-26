// // lib/controllers/notice_controller.dart
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:attendance_app/models/notice_model.dart';
// import 'package:get/get.dart';
// import '../services/notice_service.dart';

// class NoticeController extends GetxController {
//   // ══════════════════════════════════════════════════════════
//   // OBSERVABLES
//   // ══════════════════════════════════════════════════════════
//   final isLoading = false.obs;
//   final isLoadingMore = false.obs;
//   final isSearching = false.obs;
//   final hasError = false.obs;
//   final errorMessage = ''.obs;

//   // Filters
//   // final selectedClass = 'All'.obs;
//   final selectedStatus = 'All'.obs;
//   // final selectedGender = 'All'.obs;
//   final searchQuery = ''.obs;

//   // Notice data
//   final notice = <NoticeModel>[].obs;
//   final filteredNotice = <NoticeModel>[].obs;
//   final selectedNotice = Rxn<NoticeModel>();

//   // Pagination
//   final currentPage = 1.obs;
//   final totalPages = 1.obs;
//   final totalNotice = 0.obs;
//   final pageSize = 20.obs;
//   final hasMoreData = true.obs;

//   // Controllers
//   final searchController = TextEditingController();
//   final scrollController = ScrollController();

//   // Debounce timer for search
//   Timer? _debounceTimer;

//   // ══════════════════════════════════════════════════════════
//   // LIFECYCLE
//   // ══════════════════════════════════════════════════════════
//   @override
//   void onInit() {
//     super.onInit();
//     _initController();
//   }

//   @override
//   void onReady() {
//     super.onReady();
//     _fetchInitialData();
//   }

//   Future<void> _fetchInitialData() async {
//     await Future.microtask(() async {
//       await fetchNotices();
//     });
//   }

//   void _initController() {
//     searchController.addListener(_onSearchChanged);
//     scrollController.addListener(_onScroll);
//   }

//   Future<void> fetchNotices({bool refresh = false}) async {
//     if (refresh) {
//       currentPage.value = 1;
//       hasMoreData.value = true;
//       notice.clear();
//     }

//     if (!hasMoreData.value && !refresh) return;

//     isLoading.value = true;
//     hasError.value = false;

//     try {
//       final result = await NoticeService.getAllNotice(
//         page: currentPage.value,
//         limit: 20,
//       );

//       if (result['success'] == true) {
//         final List<NoticeModel> fetchedNotices = result['notices'];
        
//         if (refresh) {
//           notice.value = fetchedNotices;
//         } else {
//           notice.addAll(fetchedNotices);
//         }

//         // Check if more data available
//         final pagination = result['pagination'];
//         if (pagination != null) {
//           hasMoreData.value = currentPage.value < (pagination['totalPages'] ?? 1);
//         } else {
//           hasMoreData.value = fetchedNotices.length >= 20;
//         }

//         currentPage.value++;
//       } else {
//         hasError.value = true;
//         errorMessage.value = result['message'] ?? 'Failed to fetch notices';
//       }
//     } catch (e) {
//       hasError.value = true;
//       errorMessage.value = e.toString();
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   // ══════════════════════════════════════════════════════════
//   // MOCK DATA
//   // ══════════════════════════════════════════════════════════
//   void _loadMockNotice() {
//     final mockNotice = List.generate(
//       25,
//       (index) => NoticeModel(
//         id: 'NOT${(index + 1).toString().padLeft(3, '0')}',
//         title: 'Notice ${index + 1}',
//         status: index % 10 == 0 ? 'Inactive' : 'Active',
//         createdAt: DateTime.now().subtract(Duration(days: index * 10)),
//       ),
//     );

//     notice.value = mockNotice;
//     totalNotice.value = mockNotice.length;
//     hasMoreData.value = false;
//     _applyFilters();

//     isLoading.value = false;
//     isLoadingMore.value = false;
//   }

//   // ══════════════════════════════════════════════════════════
//   // FILTER FUNCTIONALITY
//   // ══════════════════════════════════════════════════════════
//   void _applyFilters() {
//     List<NoticeModel> result = List.from(notice);

//     // Apply search filter
//     if (searchQuery.value.isNotEmpty) {
//       final query = searchQuery.value.toLowerCase();
//       result = result.where((notice) {
//         return notice.title!.toLowerCase().contains(query);
//       }).toList();
//     }

//     // Apply status filter
//     if (selectedStatus.value != 'All') {
//       result = result.where((notice) {
//         return notice.status!.toLowerCase() ==
//             selectedStatus.value.toLowerCase();
//       }).toList();
//     }

//     filteredNotice.value = result;
//   }


  
//   // ══════════════════════════════════════════════════════════
//   // SEARCH FUNCTIONALITY
//   // ══════════════════════════════════════════════════════════
//   void _onSearchChanged() {
//     _debounceTimer?.cancel();
//     _debounceTimer = Timer(const Duration(milliseconds: 500), () {
//       final query = searchController.text.trim();
//       if (query != searchQuery.value) {
//         searchQuery.value = query;
//         _performSearch();
//       }
//     });
//   }


//     // ══════════════════════════════════════════════════════════
//   // SCROLL LISTENER FOR PAGINATION
//   // ══════════════════════════════════════════════════════════
//   void _onScroll() {
//     if (scrollController.position.pixels >=
//         scrollController.position.maxScrollExtent - 200) {
//       loadMore();
//     }
//   }

//     Future<void> _performSearch() async {
//     if (searchQuery.value.isEmpty) {
//       _applyFilters();
//       return;
//     }

//     isSearching.value = true;

//     if (searchQuery.value.length >= 2) {
//       await fetchNotices(refresh: true);
//     } else {
//       _applyFilters();
//     }

//     isSearching.value = false;
//   }


//    // ══════════════════════════════════════════════════════════
//   // LOAD MORE (PAGINATION)
//   // ══════════════════════════════════════════════════════════
//   Future<void> loadMore() async {
//     if (isLoadingMore.value || !hasMoreData.value) return;

//     isLoadingMore.value = true;
//     currentPage.value++;
//     await fetchNotices();
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/notice_model.dart';
import '../services/notice_service.dart';

class NoticeController extends GetxController {
  // ══════════════════════════════════════════════════════════
  // OBSERVABLES
  // ══════════════════════════════════════════════════════════
  final RxList<NoticeModel> notices = <NoticeModel>[].obs;
  final RxList<NoticeModel> filteredNotices = <NoticeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedStatus = 'All'.obs;

  // Search Controller
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // Status Options
  final List<String> statusOptions = ['All', 'Active', 'Inactive'];

  @override
  void onInit() {
    super.onInit();
    fetchNotices();
    _setupScrollListener();
    _setupSearchListener();
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // ══════════════════════════════════════════════════════════
  // SCROLL LISTENER FOR PAGINATION
  // ══════════════════════════════════════════════════════════
  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        loadMore();
      }
    });
  }

  // ══════════════════════════════════════════════════════════
  // SEARCH LISTENER WITH DEBOUNCE
  // ══════════════════════════════════════════════════════════
  void _setupSearchListener() {
    debounce(
      searchQuery,
      (_) => _filterNotices(),
      time: const Duration(milliseconds: 300),
    );
  }

  // ══════════════════════════════════════════════════════════
  // FETCH NOTICES
  // ══════════════════════════════════════════════════════════
  Future<void> fetchNotices({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      notices.clear();
      filteredNotices.clear();
    }

    if (!hasMoreData.value && !refresh) return;
    if (isLoading.value || isLoadingMore.value) return;

    if (notices.isEmpty) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    hasError.value = false;

    try {
      final result = await NoticeService.getAllNotice(
        page: currentPage.value,
        limit: 20,
        status: selectedStatus.value != 'All' ? selectedStatus.value : null,
      );

      if (result['success'] == true) {
        final List<NoticeModel> fetchedNotices = result['notices'];

        if (refresh || currentPage.value == 1) {
          notices.value = fetchedNotices;
        } else {
          notices.addAll(fetchedNotices);
        }

        _filterNotices();

        // Check if more data available
        final pagination = result['pagination'];
        if (pagination != null) {
          hasMoreData.value =
              currentPage.value < (pagination['totalPages'] ?? 1);
        } else {
          hasMoreData.value = fetchedNotices.length >= 20;
        }

        currentPage.value++;
      } else {
        hasError.value = true;
        errorMessage.value = result['message'] ?? 'Failed to fetch notices';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // REFRESH NOTICES
  // ══════════════════════════════════════════════════════════
  Future<void> refreshNotices() async {
    await fetchNotices(refresh: true);
  }

  // ══════════════════════════════════════════════════════════
  // LOAD MORE
  // ══════════════════════════════════════════════════════════
  void loadMore() {
    if (!isLoading.value && !isLoadingMore.value && hasMoreData.value) {
      fetchNotices();
    }
  }

  // ══════════════════════════════════════════════════════════
  // SEARCH
  // ══════════════════════════════════════════════════════════
  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _filterNotices();
  }

  // ══════════════════════════════════════════════════════════
  // FILTER NOTICES
  // ══════════════════════════════════════════════════════════
  void _filterNotices() {
    if (searchQuery.value.isEmpty) {
      filteredNotices.value = notices.toList();
    } else {
      filteredNotices.value = notices.where((notice) {
        return notice.title
            .toLowerCase()
            .contains(searchQuery.value.toLowerCase());
      }).toList();
    }
  }

  // ══════════════════════════════════════════════════════════
  // SET STATUS FILTER
  // ══════════════════════════════════════════════════════════
  void setStatusFilter(String status) {
    selectedStatus.value = status;
    fetchNotices(refresh: true);
  }

  // ══════════════════════════════════════════════════════════
  // GET NOTICE BY ID
  // ══════════════════════════════════════════════════════════
  NoticeModel? getNoticeById(String id) {
    try {
      return notices.firstWhere((notice) => notice.id == id);
    } catch (e) {
      return null;
    }
  }
}
