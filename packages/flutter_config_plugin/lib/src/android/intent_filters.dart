library;

import 'package:xml/xml.dart';

import '../types.dart';
import '../with_mod.dart';
import 'manifest_helpers.dart';

/// A single intent filter configuration.
class IntentFilterConfig {
  const IntentFilterConfig({
    required this.action,
    this.categories = const [],
    this.data = const [],
    this.autoVerify = false,
  });

  /// android.intent.action.VIEW, MAIN, etc.
  final String action;
  final List<String> categories;
  final List<Map<String, String>> data;
  final bool autoVerify;
}

// ---------------------------------------------------------------------------
// withAndroidIntentFilters
// ---------------------------------------------------------------------------

/// Add intent filters to the main `<activity>`.
ConfigPlugin withAndroidIntentFilters(List<IntentFilterConfig> filters) {
  return (config) => withMod(
        config,
        platform: 'android',
        modName: 'manifest',
        action: (props) async {
          final doc = props.modResults!;
          final activity = getMainActivityOrThrow(doc);

          // Remove previously generated filters.
          activity.children.removeWhere((node) =>
              node is XmlElement &&
              node.name.local == 'intent-filter' &&
              node.getAttribute('data-generated') == 'true');

          for (final filter in filters) {
            activity.children.add(_buildIntentFilter(filter));
          }

          return props.copyWith(modResults: doc);
        },
      );
}

XmlElement _buildIntentFilter(IntentFilterConfig filter) {
  final el = XmlElement(XmlName('intent-filter'));
  if (filter.autoVerify) {
    el.setAttribute('android:autoVerify', 'true');
  }
  el.setAttribute('data-generated', 'true');

  // <action>
  final actionEl = XmlElement(XmlName('action'));
  actionEl.setAttribute(
      'android:name', 'android.intent.action.${filter.action}');
  el.children.add(actionEl);

  // <category>
  for (final cat in filter.categories) {
    final catEl = XmlElement(XmlName('category'));
    catEl.setAttribute('android:name', 'android.intent.category.$cat');
    el.children.add(catEl);
  }

  // <data>
  for (final datum in filter.data) {
    final dataEl = XmlElement(XmlName('data'));
    for (final attr in datum.entries) {
      dataEl.setAttribute('android:${attr.key}', attr.value);
    }
    el.children.add(dataEl);
  }

  return el;
}
