import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class PatientOrderUseCases {
  final PatientOrderRepository _repository;

  PatientOrderUseCases(this._repository);

  // ============================================================
  // 🔥 START REALTIME
  // ============================================================

  Future<void> startListening({required String patientUid}) {
    return _repository.startListening(patientUid: patientUid);
  }

  Future<void> stopListening() {
    return _repository.stopListening();
  }

  // ============================================================
  // 🔥 REALTIME STREAMS
  // ============================================================

  Stream<OrderModel> get onAdded => _repository.onAdded;

  Stream<OrderModel> get onChanged => _repository.onChanged;

  Stream<String> get onRemoved => _repository.onRemoved;

  // ============================================================
  // ☁️ REMOTE OPERATIONS (Realtime Only)
  // ============================================================

  Future<Either<AppError, Unit>> addOrder(OrderModel order) {
    return _repository.addOrder(order);
  }

  Future<Either<AppError, Unit>> updateOrder(OrderModel order) {
    return _repository.updateOrder(order);
  }

  Future<Either<AppError, Unit>> deleteOrder(OrderModel order) {
    return _repository.deleteOrder(order);
  }

  // ============================================================
  // 🛑 DISPOSE
  // ============================================================

  Future<void> dispose() {
    return _repository.dispose();
  }
}