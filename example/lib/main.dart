import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_navigator/redux_navigator.dart';

class AppState {}

AppState appReducer(AppState state, dynamic action) {
  return state;
}

void main() {
  /// Initialize navigatorKey which is used for passing to
  /// [navigatorMiddleware] & [MaterialApp].
  final navigatorKey = GlobalKey<NavigatorState>();

  runApp(
    StoreProvider<AppState>(
      store: Store<AppState>(
        appReducer,
        initialState: AppState(),
        middleware: [
          /// Add navigatorMiddleware to middleware with [navigatorKey].
          ...navigatorMiddleware<AppState>(
            navigatorKey,
            additionalMiddlewareBuilders: [
              NavigatorMiddlewareBuilder<AppState, PushAction>(
                callback: (navigatorKey, store, action, next) {
                  navigatorKey.currentState.push<void>(
                    action.route,
                  );
                },
              ),
              NavigatorMiddlewareBuilder<AppState, PopAction>(
                callback: (navigatorKey, store, action, next) {
                  navigatorKey.currentState.pop();
                },
              ),
            ],
          ),
        ],
      ),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),

        /// Pass navigatorKey to [MaterialApp].
        navigatorKey: navigatorKey,
        home: const HomePage(),
      ),
    ),
  );
}

/// A page which presents list of infinity indexes.
class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Get Store by using StoreProvider. The store will be used dispatching
    /// Action of Navigator.
    final store = StoreProvider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('redux_heaven_demo'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => InkWell(
          /// Dispatch PushAction to navigate DetailPage.
          ///
          /// You can also use PushNamedAction with routeName parameter.
          onTap: () => store.dispatch(
            PushAction(
              MaterialPageRoute<void>(
                builder: (context) => DetailPage(index: index),
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Item: $index',
                  style: Theme.of(context).textTheme.button,
                ),
                const Icon(Icons.navigate_next)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Destination of [PushAction] above.
class DetailPage extends StatelessWidget {
  const DetailPage({
    @required this.index,
    Key key,
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Detail Page : $index'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () => store.dispatch(const PopAction()),
          child: const Text('POP'),
        ),
      ),
    );
  }
}
