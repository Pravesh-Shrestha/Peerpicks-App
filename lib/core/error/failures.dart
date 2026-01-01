import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({String message = "Local Database Failure"})
    : super(message);
}

class ApiFailure extends Failure {
  final int? statusCode;

  const ApiFailure({String message = "API Failure", this.statusCode})
    : super(message);
}
