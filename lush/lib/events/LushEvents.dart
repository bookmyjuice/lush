// import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
// import '../models/User.dart';

abstract class LushEvent extends Equatable {
  const LushEvent();

  @override
  List<Object> get props => [];
}

class LushStarted extends LushEvent {}
