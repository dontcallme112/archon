import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/presentation/auth/bloc/auth_bloc.dart';


final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── External ─────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // ─── Auth ─────────────────────────────────────────────
  sl.registerFactory(() => AuthBloc());
}
