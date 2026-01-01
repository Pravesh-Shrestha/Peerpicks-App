import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/hive_table_constant.dart';
import '../../../features/auth/data/models/auth_hive_model.dart';

final hiveServiceProvider = Provider((ref) => HiveService());

class HiveService {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
  }

  Future<void> register(AuthHiveModel user) async {
    var box = Hive.box<AuthHiveModel>(HiveTableConstant.authTable);
    await box.put(user.authId, user);
  }

  Future<AuthHiveModel?> login(String email, String password) async {
    var box = Hive.box<AuthHiveModel>(HiveTableConstant.authTable);
    try {
      return box.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
    } catch (e) {
      return null;
    }
  }
}
