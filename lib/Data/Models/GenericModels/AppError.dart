import 'package:equatable/equatable.dart';

class AppError extends Equatable {
  final String messege;
  const AppError(this.messege);

  @override
  // TODO: implement props
  List<Object?> get props => [messege];
}
