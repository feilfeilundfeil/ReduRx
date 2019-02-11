/// 👌 A thin layer of a Redux-based state manager on top of RxDart.
library redurx;

import 'dart:async';

import 'package:rxdart/rxdart.dart';

export 'src/log_middleware.dart';

/// Base interface for all action types.
abstract class ActionType {}

/// Action for synchronous requests.
abstract class Action<T> implements ActionType {
  /// Method to perform a synchronous mutation on the state.
  T reduce(T state);
  /// Method to perform logic after the action was reduced.
  void afterReduce(Store<T> store, T state) {}
}

/// Reducer function type for state mutations.
typedef T Computation<T>(T state);

/// Action for asynchronous requests.
abstract class AsyncAction<T> implements ActionType {

  /// Method to check if an AsyncAction should be reduced.
  bool shouldReduce(Store<T> store, T state) => true;
  /// Method to perform a asynchronous mutation on the state.
  Future<Computation<T>> reduce(T state);
  /// Method to perform logic after the asyncAction was reduced.
  void afterReduce(Store<T> store, T state) {}
}

/// Interface for Middlewares.
abstract class Middleware<T> {
  /// Called before action reducer.
  void beforeAction(Store<T> store, ActionType action, T state) {}

  /// Called after action reducer.
  void afterAction(Store<T> store, ActionType action, T state) {}
}

/// The heart of the idea, this is where we control the State and dispatch Actions.
class Store<T> {
  /// You can create the Store given an [initialState].
  Store([T initialState])
      : subject = BehaviorSubject<T>(seedValue: initialState);

  /// This is where RxDart comes in, we manage the final state using a [BehaviorSubject].
  final BehaviorSubject<T> subject;

  /// List of middlewares to be applied.
  final List<Middleware<T>> middlewares = [];

  /// Gets the subject stream.
  Stream<T> get stream => subject.stream;

  /// Gets the subject current value/store's current state.
  T get state => subject.value;

  /// Maps the current subject stream to a new Stream.
  Stream<S> map<S>(S convert(T state)) => stream.map(convert);

  /// Dispatches actions that mutates the current state.
  Store<T> dispatch(ActionType action) {
    if (action is Action<T>) {
      _beforeMiddleware(action, state);
      final newState = action.reduce(state);
      subject.add(newState);
      _afterMiddleware(action, state);
      action.afterReduce(this, state);
    }
    if (action is AsyncAction<T>) {
      _beforeMiddleware(action, state);
      if (action.shouldReduce(this, state)) {
        action.reduce(state).then((computation) {
          final newState = computation(state);
          subject.add(newState);
          _afterMiddleware(action, state);
          action.afterReduce(this, state);
        });
      }
    }
    return this;
  }

  /// Adds middlewares to the store.
  Store<T> add(Middleware<T> middleware) {
    middlewares.add(middleware);
    return this;
  }

  /// Closes the stores subject.
  void close() => subject.close();

  void _beforeMiddleware(ActionType action, T state) {
    for (var middleware in middlewares) {
      middleware.beforeAction(this, action, state);
    }
  }

  void _afterMiddleware(ActionType action, T state) {
    for (var middleware in middlewares) {
      middleware.afterAction(this, action, state);
    }
  }
}
