import 'package:scoped_model/scoped_model.dart';
import 'package:simple_permissions/simple_permissions.dart';

class PermissionModel extends Model {
  bool readExternalStoragePermission = false;
  ask() async {
    var isAllowed = await SimplePermissions.checkPermission(
        Permission.WriteExternalStorage);
    if (isAllowed)
      readExternalStoragePermission = true;
    else {
      var permState = await SimplePermissions.requestPermission(
          Permission.WriteExternalStorage);
      if (permState == PermissionStatus.authorized) {
        readExternalStoragePermission = true;
      } else if (permState == PermissionStatus.deniedNeverAsk) {
        await SimplePermissions.openSettings();
      }
    }
    notifyListeners();
  }
}
