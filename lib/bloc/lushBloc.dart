import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../events/LushEvents.dart';
import '../UserRepository/userRepository.dart';
import '../states/LushState.dart';

class LushBloc extends Bloc<LushEvent, LushState> {
  final UserRepository userRepository;
  late String? token, signUpSuccess;

  LushBloc({required this.userRepository}) : super(AppLaunch());

  LushState get initialState => AppLaunch();

  @override
  Stream<LushState> mapEventToState(LushEvent event) async* {}
}
