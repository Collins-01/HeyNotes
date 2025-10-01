import 'package:flutter/material.dart';

// This is where we handle all the navigation stuff for the app
// Instead of using Navigator.of(context) everywhere, we use this service
// Makes life easier, trust me
//
// HOW TO USE:
// 1. Normal navigation:
//    NavigationService.navigateTo('/profile');
//
// 2. Replace current screen:
//    NavigationService.navigateReplacement('/home');
//
// 3. Clear all screens and go to new one (like after login):
//    NavigationService.navigateAndRemoveUntil('/dashboard');
//
// 4. Show a simple dialog:
//    final shouldDelete = await NavigationService.showDialog<bool>(
//      child: AlertDialog(
//        title: Text('Oya, you sure?'),
//        content: Text('This action no get undo o!'),
//        actions: [
//          TextButton(
//            onPressed: () => NavigationService.goBack(false),
//            child: Text('Abeg cancel'),
//          ),
//          TextButton(
//            onPressed: () => NavigationService.goBack(true),
//            child: Text('I sure!'),
//          ),
//        ],
//      ),
//    );
//
// 5. Show bottom sheet (that thing that slides up):
//    final result = await NavigationService.showBottomSheet(
//      child: Container(
//        padding: EdgeInsets.all(16),
//        child: Column(
//          mainAxisSize: MainAxisSize.min,
//          children: [
//            Text('Wetin you wan do?'),
//            // Your content here
//          ],
//        ),
//      ),
//    );
class NavigationService {
  // This makes sure we only have one instance of this class
  // Na singleton pattern we dey use here
  static final NavigationService _instance = NavigationService._internal();

  // This key na our secret weapon to navigate from anywhere
  // No need to pass BuildContext upandan
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // This one makes sure we no go create multiple instances
  factory NavigationService() {
    return _instance;
  }

  // Private constructor - no direct instantiation o!
  NavigationService._internal();

  // Get the current context if available
  // Returns null if the navigator no dey ready yet
  static BuildContext? get context => navigatorKey.currentContext;

  // Use this to move to a new screen
  //
  // Parameters:
  // - routeName: The name of the route wey you don set for your app
  // - arguments: Any data wey you wan pass to the next screen (optional)
  //
  // Example:
  // NavigationService.navigateTo('/profile', arguments: userId);
  static Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    assert(routeName.isNotEmpty, 'Abeg enter route name o!');
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  // Use this when you want to replace the current screen
  // E.g., after login, you no want make user go back to login screen
  //
  // Parameters:
  // - routeName: The new route wey go replace the current one
  // - arguments: Any data wey you wan pass (optional)
  //
  // Example:
  // NavigationService.navigateReplacement('/home');
  static Future<dynamic> navigateReplacement(
    String routeName, {
    dynamic arguments,
  }) {
    assert(routeName.isNotEmpty, 'Abeg enter route name o!');
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  // This one go clear all the screens wey don pass
  // and start fresh with the new route
  // Perfect for after login/logout
  //
  // Example:
  // NavigationService.navigateAndRemoveUntil('/onboarding');
  static Future<dynamic> navigateAndRemoveUntil(
    String routeName, {
    dynamic arguments,
  }) {
    assert(routeName.isNotEmpty, 'Abeg enter route name o!');
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) =>
          false, // This one na the magic wey go clear all previous screens
      arguments: arguments,
    );
  }

  // Use this to go back to the previous screen
  // You fit pass result if you wan return something
  //
  // Example 1: Just go back
  // NavigationService.goBack();
  //
  // Example 2: Go back with result
  // NavigationService.goBack(true); // For yes/no scenarios
  static void goBack<T extends Object?>([T? result]) {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop(result);
    }
  }

  // Check if you fit go back
  // Returns true if you get where you dey go back to
  static bool canPop() {
    return navigatorKey.currentState!.canPop();
  }

  // This one go dey remove screens until e see the one wey you want
  // E go dey useful when you wan reach home or any particular screen
  //
  // Example:
  // NavigationService.popUntil('/home'); // Go dey remove screens until e see home
  static void popUntil(String routeName) {
    assert(routeName.isNotEmpty, 'Abeg enter route name o!');
    navigatorKey.currentState!.popUntil(
      (route) => route.settings.name == routeName,
    );
  }

  // Show dialog anyhow wey you like am
  //
  // Parameters:
  // - child: The widget wey go show inside the dialog
  // - barrierDismissible: If true, user fit tap outside to close (default: true)
  // - barrierColor: The color of the background (default: semi-transparent black)
  //
  // Example:
  // final shouldDelete = await NavigationService.showDialog<bool>(
  //   child: AlertDialog(
  //     title: Text('Oya, you sure?'),
  //     content: Text('This action no get undo o!'),
  //     actions: [
  //       TextButton(
  //         onPressed: () => NavigationService.goBack(false),
  //         child: Text('Abeg cancel'),
  //       ),
  //       TextButton(
  //         onPressed: () => NavigationService.goBack(true),
  //         child: Text('I sure!'),
  //       ),
  //     ],
  //   ),
  // );
  static Future<T?> showDialog<T>({
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
  }) {
    return showGeneralDialog<T>(
      context: navigatorKey.currentContext!,
      barrierDismissible: barrierDismissible,
      // barrierColor: barrierColor,
      barrierLabel:
          barrierLabel ??
          MaterialLocalizations.of(
            navigatorKey.currentContext!,
          ).modalBarrierDismissLabel,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  // Show bottom sheet (that thing wey dey slide from bottom)
  //
  // Parameters:
  // - child: The widget wey go show inside
  // - isScrollControlled: If true, the sheet go fit take full height (default: false)
  // - enableDrag: If true, user fit drag am up and down (default: true)
  //
  // Example:
  // final result = await NavigationService.showBottomSheet(
  //   child: Container(
  //     padding: EdgeInsets.all(16),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Text('Wetin you wan do?'),
  //         // Your content here
  //       ],
  //     ),
  //   ),
  // );
  static Future<T?> showBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = false,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: navigatorKey.currentContext!,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => child,
    );
  }
}
