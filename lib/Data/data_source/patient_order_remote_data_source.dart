import '../../index/index_main.dart';

abstract class PatientOrderRemoteDataSource {
  Future<void> createOrder(OrderModel model);

  Future<void> updateOrder(OrderModel model);

  Future<void> deleteOrder(OrderModel model);

  Future<void> startListening({required String patientUid});

  Future<void> stopListening();

  Stream<OrderModel> get onAdded;

  Stream<OrderModel> get onChanged;

  Stream<String> get onRemoved;
}
