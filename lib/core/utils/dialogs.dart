import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A utility class for showing platform-appropriate dialogs
class AppDialogs {
  /// Shows a confirmation dialog with customizable options
  /// Returns `true` if confirmed, `false` if cancelled
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
    bool isDestructive = true,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => Platform.isIOS || Platform.isMacOS
              ? CupertinoAlertDialog(
                  title: Text(title),
                  content: Text(message),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(cancelText),
                    ),
                    CupertinoDialogAction(
                      onPressed: () => Navigator.of(context).pop(true),
                      isDestructiveAction: isDestructive,
                      child: Text(confirmText),
                    ),
                  ],
                )
              : AlertDialog(
                  title: Text(title),
                  content: Text(message),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(cancelText.toUpperCase()),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: isDestructive
                          ? TextButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.error,
                            )
                          : null,
                      child: Text(confirmText.toUpperCase()),
                    ),
                  ],
                ),
        ) ??
        false;
  }

  /// Shows a confirmation dialog specifically for deleting items
  static Future<bool> showDeleteConfirmation({
    required BuildContext context,
    String itemName = 'item',
  }) async {
    return showConfirmationDialog(
      context: context,
      title: 'Delete $itemName',
      message: 'Are you sure you want to delete this $itemName?',
      confirmText: 'Delete',
      isDestructive: true,
    );
  }
}
