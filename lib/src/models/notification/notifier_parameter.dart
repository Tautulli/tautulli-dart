import '../../utils/cast.dart';

/// A single notification template parameter, returned by
/// `get_notifier_parameters`.
///
/// These describe the tokens available when composing notification text
/// (e.g. `value` `'tautulli_version'` labelled `'Tautulli Version'`).
class NotifierParameter {
  /// Human-readable label for the parameter (e.g. `'Tautulli Version'`).
  final String? name;

  /// Value type of the parameter (e.g. `'str'`, `'int'`).
  final String? type;

  /// Template token for the parameter (e.g. `'tautulli_version'`).
  final String? value;

  const NotifierParameter({this.name, this.type, this.value});

  /// Parses a [NotifierParameter] from a Tautulli API JSON map.
  factory NotifierParameter.fromJson(Map<String, dynamic> json) =>
      NotifierParameter(
        name: Cast.castToString(json['name']),
        type: Cast.castToString(json['type']),
        value: Cast.castToString(json['value']),
      );
}
