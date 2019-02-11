import '../redurx.dart';

/// Middleware that prints when action's reducers are applied.
class LogMiddleware<T> extends Middleware<T> {
  /// Prints before the Action reducer call.
  @override
  void beforeAction(store, action, state) {
    print('MIDDLEWARE before: ${action.runtimeType}: $state');
  }

  /// Prints after the Action reducer call.
  @override
  void afterAction(store, action, state) {
    print('MIDDLEWARE after: ${action.runtimeType}: $state');
  }
}
