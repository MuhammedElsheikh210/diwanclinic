import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class PatientOrderRepository {
  Future<void> startListening({required String patientUid});
  Future<void> stopListening();
  Future<void> dispose();

  Stream<OrderModel> get onAdded;
  Stream<OrderModel> get onChanged;
  Stream<String> get onRemoved;

  Future<Either<AppError, Unit>> addOrder(OrderModel model);
  Future<Either<AppError, Unit>> updateOrder(OrderModel model);
  Future<Either<AppError, Unit>> deleteOrder(OrderModel model);
}

