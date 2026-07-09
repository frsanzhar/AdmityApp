/// Opening external web links (source citations, university sites).
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [raw] in the external browser.
///
/// Prepends `https://` when [raw] has no scheme (catalog data stores bare hosts
/// like `nu.edu.kz`). Shows a SnackBar on failure and never throws. The
/// [ScaffoldMessenger] is captured synchronously, so no `BuildContext` is used
/// across the await.
Future<void> openExternalLink(BuildContext context, String raw) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  var url = raw.trim();
  if (url.isEmpty) return;
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = 'https://$url';
  }
  final uri = Uri.tryParse(url);
  if (uri == null) {
    messenger?.showSnackBar(
      const SnackBar(content: Text('Неверная ссылка')),
    );
    return;
  }
  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) {
      messenger?.showSnackBar(
        const SnackBar(content: Text('Не удалось открыть ссылку')),
      );
    }
  } on Object {
    messenger?.showSnackBar(
      const SnackBar(content: Text('Не удалось открыть ссылку')),
    );
  }
}
