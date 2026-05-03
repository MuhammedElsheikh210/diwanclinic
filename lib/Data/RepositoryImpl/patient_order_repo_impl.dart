import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class PatientOrderRepositoryImpl implements PatientOrderRepository {
  final PatientOrderRemoteDataSource _remote;

  PatientOrderRepositoryImpl(this._remote);

  StreamSubscription? _addedSub;
  StreamSubscription? _changedSub;
  StreamSubscription? _removedSub;

  final _addedController = StreamController<OrderModel>.broadcast();
  final _changedController = StreamController<OrderModel>.broadcast();
  final _removedController = StreamController<String>.broadcast();

  bool _isListening = false;

  @override
  Stream<OrderModel> get onAdded => _addedController.stream;

  @override
  Stream<OrderModel> get onChanged => _changedController.stream;

  @override
  Stream<String> get onRemoved => _removedController.stream;

  // ============================================================
  // 🎧 START LISTENING
  // ============================================================

  @override
  Future<void> startListening({required String patientUid}) async {
    if (_isListening) return;

    await _remote.startListening(patientUid: patientUid);

    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    _addedSub = _remote.onAdded.listen((model) {
      if (model.key == null) return;
      _addedController.add(model);
    });

    _changedSub = _remote.onChanged.listen((model) {
      if (model.key == null) return;
      _changedController.add(model);
    });

    _removedSub = _remote.onRemoved.listen((key) {
      _removedController.add(key);
    });

    _isListening = true;
  }

  // ============================================================
  // 🛑 STOP
  // ============================================================

  @override
  Future<void> stopListening() async {
    _isListening = false;

    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    await _remote.stopListening();
  }

  // ============================================================
  // 🧹 DISPOSE
  // ============================================================

  @override
  Future<void> dispose() async {
    await stopListening();

    if (!_addedController.isClosed) await _addedController.close();
    if (!_changedController.isClosed) await _changedController.close();
    if (!_removedController.isClosed) await _removedController.close();
  }

  // ============================================================
  // ➕ ADD
  // ============================================================

  @override
  Future<Either<AppError, Unit>> addOrder(OrderModel model) async {
    try {
      await _remote.createOrder(model);
      return const Right(unit);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // 🔄 UPDATE
  // ============================================================

  @override
  Future<Either<AppError, Unit>> updateOrder(OrderModel model) async {
    try {
      await _remote.updateOrder(model);
      return const Right(unit);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ============================================================
  // ❌ DELETE
  // ============================================================

  @override
  Future<Either<AppError, Unit>> deleteOrder(OrderModel model) async {
    try {
      await _remote.deleteOrder(model);
      return const Right(unit);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}