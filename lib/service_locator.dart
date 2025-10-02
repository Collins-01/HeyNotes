import 'package:get_it/get_it.dart';
import 'package:hey_notes/core/services/categories_service.dart';
import 'package:hey_notes/core/services/notes_service.dart';

GetIt sl = GetIt.instance;

void setupLocator() {
  sl.registerLazySingleton<CategoryService>(() => CategoryService());
  sl.registerLazySingleton<NotesService>(() => NotesService());
}
