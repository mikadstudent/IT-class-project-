// Picks the right notification code for the platform:
// the browser version on web, a do-nothing version elsewhere.
export 'notifier_stub.dart' if (dart.library.js_interop) 'notifier_web.dart';
