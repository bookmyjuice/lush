import 'package:equatable/equatable.dart';

abstract class LushEvent extends Equatable {
  const LushEvent();

  @override
  List<Object> get props => [];
}

class LushStarted extends LushEvent {}
