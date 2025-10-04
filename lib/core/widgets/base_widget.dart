import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/ui_helpers.dart';

abstract class BaseWidget<T extends ConsumerWidget> extends ConsumerWidget {
  const BaseWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => UIHelpers.hideKeyboard(),
      child: buildWidget(context, ref),
    );
  }

  Widget buildWidget(BuildContext context, WidgetRef ref);
}

class BaseStatefulWidget extends ConsumerStatefulWidget {
  const BaseStatefulWidget({super.key});

  @override
  ConsumerState<BaseStatefulWidget> createState() => _BaseStatefulWidgetState();
}

class _BaseStatefulWidgetState extends ConsumerState<BaseStatefulWidget> {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool value) {
    if (mounted) {
      setState(() {
        _isLoading = value;
      });
    }
  }

  void setError(String? error) {
    if (mounted) {
      setState(() {
        _error = error;
      });
      if (error != null) {
        UIHelpers.showErrorSnackBar(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => UIHelpers.hideKeyboard(),
      child: buildWidget(context, ref),
    );
  }

  Widget buildWidget(BuildContext context, WidgetRef ref) {
    throw UnimplementedError('buildWidget must be implemented');
  }
}
