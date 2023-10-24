class NetworkDebugger {
  List<bool Function(List<int>)> filters;
  Function(List<int>) action;

  NetworkDebugger({required this.action, this.filters = const []});

  void digestMesssage(List<int> buffer) {
    for (var filter in filters) {
      if (!filter(buffer)) {
        return;
      }
    }
    action(buffer);
  }
}