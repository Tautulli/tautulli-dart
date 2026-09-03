import '../connection.dart';
import '../net/uri.dart';
import '../types/image_fallback.dart';

/// Synchronous URI builder for pms_image_proxy.
///
/// No HTTP call is made — the returned [Uri] is passed directly to an image
/// loading widget (e.g. CachedNetworkImage) which handles the actual request.
class ImageService {
  final TautulliConnection _connection;
  ImageService(TautulliConnection connection) : _connection = connection;

  /// Constructs a pms_image_proxy URI from the given parameters.
  ///
  /// Provide either [img] (Plex image path) or [ratingKey], or both.
  /// [background] is a hex color without `#`, such as `'282828'`. The three
  /// flags are sent only when true: the server reads `refresh` and `clip` by
  /// truthiness, so `'0'` would count as set, and the mere presence of
  /// `return_hash` switches the response to JSON. With [returnHash] the URI
  /// therefore answers `{"response": ...}` carrying the image hash, not image
  /// bytes, and must not be handed to an image widget.
  Uri buildImageUrl({
    String? img,
    int? ratingKey,
    int? width,
    int? height,
    int? opacity,
    String? background,
    int? blur,
    String? imgFormat,
    ImageFallback? fallback,
    bool? refresh,
    bool? returnHash,
    bool? clip,
  }) {
    final params = <String, String>{
      'cmd': 'pms_image_proxy',
      'apikey': _connection.apiKey,
      if (_connection.useDeviceToken) 'app': 'true',
    };

    if (img != null) params['img'] = img;
    if (ratingKey != null) params['rating_key'] = ratingKey.toString();
    if (width != null) params['width'] = width.toString();
    if (height != null) params['height'] = height.toString();
    if (opacity != null) params['opacity'] = opacity.toString();
    if (background != null) params['background'] = background;
    if (blur != null) params['blur'] = blur.toString();
    if (imgFormat != null) params['img_format'] = imgFormat;
    if (fallback != null) params['fallback'] = fallback.value;
    if (refresh == true) params['refresh'] = '1';
    if (returnHash == true) params['return_hash'] = '1';
    if (clip == true) params['clip'] = '1';

    return buildTautulliUri(_connection, params);
  }
}
