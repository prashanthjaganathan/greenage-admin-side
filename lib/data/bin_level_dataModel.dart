class DataModel {
  String binLevel;

  DataModel.fromJson(Map<String, dynamic> json)
      : binLevel = json['feeds'][0]['field1'];

  // A method that converts the object to JSON
  Map<String, dynamic> toJson() => {
        'field1': binLevel,
      };
}
