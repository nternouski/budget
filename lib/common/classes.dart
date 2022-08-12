abstract class ModelCommonInterface {
  late String id;
  ModelCommonInterface.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

abstract class GraphQlQuery {
  late String getAll;
  late String create;
  late String update;
  late String delete;
}
