import 'dart:io';

class FilesManupalation {
  Future deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        return "success";
      }
    } catch (e) {
      // Error in getting access to the file.
      print(e);
      return "success";
    }
  }
}
