import 'package:flutter/material.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final String labelText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final Widget? hint;
  final String Function(T)? getSearchableText;

  const SearchableDropdown({
    super.key,
    required this.labelText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.hint,
    this.getSearchableText,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<DropdownMenuItem<T>> _filteredItems = [];
  bool _isDropdownOpen = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      setState(() {
        _filteredItems = widget.items;
      });
      _filterItems(_searchController.text);
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && !_isDropdownOpen) {
      _openDropdown();
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(widget.items);
      } else {
        _filteredItems = widget.items.where((item) {
          try {
            final searchText = (item.value != null ? widget.getSearchableText?.call(item.value!) : null) ?? 
                             (item.child is Text ? (item.child as Text).data : item.value?.toString()) ?? '';
            return searchText.toLowerCase().contains(query.toLowerCase());
          } catch (e) {
            // If there's any error in text extraction, include the item
            return true;
          }
        }).toList();
      }
    });
    
    // Defer the overlay update to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isDropdownOpen) {
        _updateOverlay();
      }
    });
  }

  void _openDropdown() {
    if (_isDropdownOpen) return;
    
    _isDropdownOpen = true;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    if (!_isDropdownOpen) return;
    
    _isDropdownOpen = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _updateOverlay() {
    if (_isDropdownOpen && _overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);

    }
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible barrier to detect outside taps
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _closeDropdown();
                _focusNode.unfocus();
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // The actual dropdown
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height + 8, // Add 8px gap between input and dropdown
            width: size.width,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 500),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Search bar
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Търсене...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterItems('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 14),
                        onChanged: _filterItems,
                      ),
                    ),
                    // Dropdown items
                    Flexible(
                      child: _filteredItems.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              child: Text(
                                'Няма намерени резултати',
                                style: TextStyle(color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _filteredItems.length,
                              itemBuilder: (context, index) {
                                // Defensive check to prevent RangeError
                                if (index >= _filteredItems.length) {
                                  return const SizedBox.shrink();
                                }
                                final item = _filteredItems[index];
                                final isSelected = item.value == widget.value;
                                
                                return InkWell(
                                  onTap: () {
                                    widget.onChanged?.call(item.value);
                                    _searchController.clear();
                                    _filterItems('');
                                    _closeDropdown();
                                    _focusNode.unfocus();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: DefaultTextStyle(
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                            child: item.child,
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check,
                                            color: Theme.of(context).primaryColor,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayText() {
    if (widget.value == null) return '';
    
    final selectedItem = widget.items.firstWhere(
      (item) => item.value == widget.value,
      orElse: () => DropdownMenuItem<T>(value: widget.value, child: const Text('')),
    );
    
    return widget.getSearchableText?.call(widget.value!) ?? 
           (selectedItem.child as Text).data ?? '';
  }

  @override
  void dispose() {
    _closeDropdown();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.enabled) {
          if (_isDropdownOpen) {
            _closeDropdown();
          } else {
            _focusNode.requestFocus();
          }
        }
      },
      child: AbsorbPointer(
        absorbing: !widget.enabled,
        child: TextFormField(
          focusNode: _focusNode,
          readOnly: true,
          decoration: InputDecoration(
            labelText: widget.labelText,
            border: const OutlineInputBorder(),
            suffixIcon: Icon(
              _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: widget.enabled ? null : Colors.grey,
            ),
            enabled: widget.enabled,
          ),
          controller: TextEditingController(text: _getDisplayText()),
          validator: widget.validator != null 
              ? (value) => widget.validator!(widget.value)
              : null,
          onTap: () {
            if (widget.enabled) {
              if (_isDropdownOpen) {
                _closeDropdown();
              } else {
                _openDropdown();
              }
            }
          },
        ),
      ),
    );
  }
}
