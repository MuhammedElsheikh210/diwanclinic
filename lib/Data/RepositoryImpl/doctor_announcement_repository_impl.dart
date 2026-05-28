import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class DoctorAnnouncementRepositoryImpl implements DoctorAnnouncementRepository {
  final DoctorAnnouncementDataSource _remote;

  DoctorAnnouncementRepositoryImpl(this._remote);

  StreamSubscription? _addedSub;
  StreamSubscription? _changedSub;
  StreamSubscription? _removedSub;

  final _addedController =
      StreamController<DoctorAnnouncementModel>.broadcast();
  final _changedController =
      StreamController<DoctorAnnouncementModel>.broadcast();
  final _removedController = StreamController<String>.broadcast();

  @override
  Stream<DoctorAnnouncementModel> get onAdded => _addedController.stream;

  @override
  Stream<DoctorAnnouncementModel> get onChanged => _changedController.stream;

  @override
  Stream<String> get onRemoved => _removedController.stream;

  @override
  Future<void> startListening({
    required String doctorKey,
    required String date,
  }) async {
    await _remote.startListening(doctorKey: doctorKey, date: date);

    _addedSub?.cancel();
    _changedSub?.cancel();
    _removedSub?.cancel();

    _addedSub = _remote.onAdded.listen((model) {
      _addedController.add(model);
    });

    _changedSub = _remote.onChanged.listen((model) {
      _changedController.add(model);
    });

    _removedSub = _remote.onRemoved.listen((key) {
      _removedController.add(key);
    });
  }

  @override
  Future<Either<AppError, Unit>> createAnnouncementDomain(
    DoctorAnnouncementModel model,
  ) async {
    try {
      await _remote.createAnnouncement(model);
      return const Right(unit);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, DoctorAnnouncementModel?>> fetchLatestDomain({
    required String doctorKey,
    required String date,
  }) async {
    try {
      final result = await _remote.fetchLatestAnnouncement(
        doctorKey: doctorKey,
        date: date,
      );
      return Right(result);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, Unit>> deactivatePreviousDomain({
    required String doctorKey,
    required String date,
  }) async {
    try {
      await _remote.deactivatePreviousAnnouncements(
        doctorKey: doctorKey,
        date: date,
      );
      return const Right(unit);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<void> dispose() async {
    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    await _remote.stopListening();

    if (!_addedController.isClosed) await _addedController.close();
    if (!_changedController.isClosed) await _changedController.close();
    if (!_removedController.isClosed) await _removedController.close();
  }
}
