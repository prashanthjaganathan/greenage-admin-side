import 'package:image_picker/image_picker.dart';

class ReportDetails {
  late int report_id;
  late String name;
  late int user_id;
  late String priority;
  late double latitude;
  late double longitude;
  late String comment;
  late String title;
  late XFile reportImageFile;
  late String reportImageAsStr;
  String address = "";
  //  return Image.memory(
  //     Uint8List.fromList(imageBytes),
  //     fit: BoxFit.cover,
  //   );
}
