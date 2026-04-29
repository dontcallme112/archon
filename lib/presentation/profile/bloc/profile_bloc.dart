import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/repositories.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;

  ProfileBloc({required this.userRepository}) : super(ProfileLoading()) {
    on<LoadProfileData>(_onLoad);
  }

  Future<void> _onLoad(
    LoadProfileData event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final user = await userRepository.getCurrentUser();
      final projects = await userRepository.getMyProjects();

      if (user == null) {
        emit(ProfileError('Пользователь не найден'));
        return;
      }

      emit(ProfileLoaded(
        user: user,
        projects: projects,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}