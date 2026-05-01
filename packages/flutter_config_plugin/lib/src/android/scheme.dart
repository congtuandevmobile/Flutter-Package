library;

import 'package:xml/xml.dart';

import '../types.dart';
import '../with_mod.dart';

/// Appends a custom URI scheme to the AndroidManifest.xml.
/// It targets the activity with `android:launchMode="singleTask"` (typically the MainActivity)
/// and adds an intent-filter for VIEW/DEFAULT/BROWSABLE.
ConfigPlugin withAndroidScheme(String scheme) {
  return (config) => withMod(
        config,
        platform: 'android',
        modName: 'manifest',
        action: (props) async {
          final doc = props.modResults!;
          _appendScheme(scheme, doc);
          return props.copyWith(modResults: doc);
        },
      );
}

void _appendScheme(String scheme, XmlDocument doc) {
  final app = doc.rootElement.findElements('application').firstOrNull;
  if (app == null) return;

  XmlElement? targetActivity;
  
  // Find the singleTask activity
  for (final activity in app.findElements('activity')) {
    if (activity.getAttribute('android:launchMode') == 'singleTask' || 
        activity.getAttribute('android:name') == '.MainActivity') {
      targetActivity = activity;
      break;
    }
  }

  if (targetActivity == null) return;

  XmlElement? targetFilter;

  // Find existing valid intent filter
  for (final filter in targetActivity.findElements('intent-filter')) {
    final actions = filter.findElements('action').map((e) => e.getAttribute('android:name')).toList();
    final categories = filter.findElements('category').map((e) => e.getAttribute('android:name')).toList();

    if (actions.contains('android.intent.action.VIEW') &&
        !categories.contains('android.intent.category.LAUNCHER')) {
      targetFilter = filter;
      break;
    }
  }

  // If not found, create a new intent-filter
  if (targetFilter == null) {
    targetFilter = XmlElement(XmlName('intent-filter'));
    
    final action = XmlElement(XmlName('action'));
    action.setAttribute('android:name', 'android.intent.action.VIEW');
    targetFilter.children.add(action);

    final catDefault = XmlElement(XmlName('category'));
    catDefault.setAttribute('android:name', 'android.intent.category.DEFAULT');
    targetFilter.children.add(catDefault);

    final catBrowsable = XmlElement(XmlName('category'));
    catBrowsable.setAttribute('android:name', 'android.intent.category.BROWSABLE');
    targetFilter.children.add(catBrowsable);

    targetActivity.children.add(targetFilter);
  }

  // Check if scheme already exists
  final existingData = targetFilter.findElements('data');
  for (final data in existingData) {
    if (data.getAttribute('android:scheme') == scheme) {
      return; // Already has this scheme
    }
  }

  // Add the new scheme
  final data = XmlElement(XmlName('data'));
  data.setAttribute('android:scheme', scheme);
  targetFilter.children.add(data);
}
