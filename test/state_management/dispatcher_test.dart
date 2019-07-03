// Copyright Rouven T. Kruse. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:cage/src/_private.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    resetDispatcher();
  });

  group('listenToChanges()', () {
    test(
        'It should subscribe to the dispatcher event stream and return the StreamSubscription',
        () {
      final StreamSubscription<Envelope> subscription =
          listenToDispatcher((final Envelope envelope) {});

      expect(subscription, isNotNull);
    });
  });

  group('disposeDispatcher()', () {
    test('It should close the subscription stream and cancel any subscription',
        () {
      final StreamSubscription<Envelope> subscription =
          listenToDispatcher((final Envelope envelope) {});

      final StreamController<Envelope> streamController = disposeDispatcher();

      expect(streamController.isClosed, true);

      streamController.close();

      subscription.cancel();
    });
  });

  group('Dispatcher', () {
    test('It should create', () {
      expect(Dispatcher(), isNotNull);
    });

    test('It should always return the same instance', () {
      expect(Dispatcher(), Dispatcher());
    });

    group('dispatchAction()', () {
      test('It should add the commit to the stream', () async {
        const ActionToken actionToken = ActionToken('dispatcher_action');

        listenToDispatcher((final Envelope envelope) {
          expect(envelope, isNotNull);
          expect(envelope.actionToken, actionToken);
        });

        Dispatcher().dispatchAction(actionToken);
      });
    });
  });
}
