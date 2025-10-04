import 'dart:async';
import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final String hintText;
  final Duration debounceDuration;

  const SearchBar({
    super.key,
    this.onChanged,
    this.hintText = 'Search notes...',
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  Timer? _debounce;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  void _onSearchChanged(String query) {
    if (widget.onChanged == null) return;
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(widget.debounceDuration, () {
      if (mounted) {
        widget.onChanged!(query);
      }
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged?.call('');
    _focusNode.unfocus();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: _onSearchChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: _clearSearch,
              )
            : null,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
