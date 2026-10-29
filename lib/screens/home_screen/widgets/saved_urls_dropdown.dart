import 'package:flutter/material.dart';

class SavedUrlsDropdown extends StatelessWidget {
  const SavedUrlsDropdown({
    super.key,
    required this.urls,
    required this.selectedUrl,
    required this.onChanged,
  });

  final List<String> urls;
  final String? selectedUrl;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: const ValueKey('saved_url_dropdown'),
      isExpanded: true,
      initialValue: urls.contains(selectedUrl) ? selectedUrl : null,
      decoration: const InputDecoration(
        labelText: 'Previous successful URLs',
        border: OutlineInputBorder(),
      ),
      items: urls
          .map(
            (url) => DropdownMenuItem(
              value: url,
              child: Text(url, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}
