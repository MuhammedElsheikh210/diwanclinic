import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../index/index_main.dart';

class OrderRepositoryImpl extends OrderRepository {
  final OrderDataSourceRepo _orderDataSourceRepo;

  OrderRepositoryImpl(this._orderDataSourceRepo);

  // ============================================================
  // 🌊 STREAM SUBSCRIPTIONS
  // ============================================================

  StreamSubscription? _addedSub;
  StreamSubscription? _changedSub;
  StreamSubscription? _removedSub;

  // ============================================================
  // 🌊 STREAM CONTROLLERS
  // ============================================================

  final _addedController = StreamController<OrderModel>.broadcast();
  final _changedController = StreamController<OrderModel>.broadcast();
  final _removedController = StreamController<String>.broadcast();

  @override
  Stream<OrderModel> get onAdded => _addedController.stream;

  @override
  Stream<OrderModel> get onChanged => _changedController.stream;

  @override
  Stream<String> get onRemoved => _removedController.stream;

  // ============================================================
  // 🎧 START REALTIME LISTENING
  // ============================================================

  @override
  Future<void> startListening() async {

    await _orderDataSourceRepo.startListening();

    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    // ============================================================
    // 🟢 ADDED
    // ============================================================

    _addedSub = _orderDataSourceRepo.onAdded.listen((model) {
      if (!_addedController.isClosed) {
        _addedController.add(model);
      }
    });

    // ============================================================
    // 🔄 CHANGED
    // ============================================================

    _changedSub = _orderDataSourceRepo.onChanged.listen((model) {
      if (!_changedController.isClosed) {
        _changedController.add(model);
      }
    });

    // ============================================================
    // ❌ REMOVED
    // ============================================================

    _removedSub = _orderDataSourceRepo.onRemoved.listen((key) {
      if (!_removedController.isClosed) {
        _removedController.add(key);
      }
    });
  }

  // ============================================================
  // 🛑 DISPOSE
  // ============================================================

  @override
  Future<void> dispose() async {
    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    await _orderDataSourceRepo.stopListening();

    if (!_addedController.isClosed) {
      await _addedController.close();
    }

    if (!_changedController.isClosed) {
      await _changedController.close();
    }

    if (!_removedController.isClosed) {
      await _removedController.close();
    }
  }

  // ============================================================
  // 🌐 FETCH ALL ORDERS
  // ============================================================

  @override
  Future<Either<AppError, List<OrderModel>>>
  fetchAllOrdersDomain() async {
    try {
      final result = await _orderDataSourceRepo.fetchAllOrders();

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // 📥 GET ORDERS
  // ============================================================

  @override
  Future<Either<AppError, List<OrderModel?>>> getOrdersDomain(
      Map<String, dynamic> data,
      SQLiteQueryParams query,
      bool? isFiltered,
      ) async {
    try {
      final result = await _orderDataSourceRepo.getOrders(
        data,
        query,
        isFiltered,
      );

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // ➕ ADD ORDER
  // ============================================================

  @override
  Future<Either<AppError, SuccessModel>> addOrderDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _orderDataSourceRepo.addOrder(
        data,
        key,
      );

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // 🔄 UPDATE ORDER
  // ============================================================

  @override
  Future<Either<AppError, SuccessModel>> updateOrderDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _orderDataSourceRepo.updateOrder(
        data,
        key,
      );

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // ❌ DELETE ORDER
  // ============================================================

  @override
  Future<Either<AppError, SuccessModel>> deleteOrderDomain(
      Map<String, dynamic> data,
      String key,
      ) async {
    try {
      final result = await _orderDataSourceRepo.deleteOrder(
        data,
        key,
      );

      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}