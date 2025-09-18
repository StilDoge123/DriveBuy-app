class BaseRoute {
  const BaseRoute({
    required this.name,
    required String path,
    String? pathParameter,
  })  : _path = path,
        _pathParameter = pathParameter;

  final String name;
  final String _path;
  String get path => _pathParameter != null ? '$_path/:$_pathParameter' : _path;
  String get basePath => _path;
  final String? _pathParameter;
  String get pathParameter => _pathParameter ?? '';
}
