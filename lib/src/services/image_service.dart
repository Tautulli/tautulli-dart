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
  Uri buildImageUrl({
    String? img,
    int? ratingKey,
    int? width,
    int? height,
    int? opacity,
    int? background,
    int? blur,
    String? imgFormat,
    ImageFallback? fallback,
    bool? refresh,
    bool? returnHash,
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
    if (background != null) params['background'] = background.toString();
    if (blur != null) params['blur'] = blur.toString();
    if (imgFormat != null) params['img_format'] = imgFormat;
    if (fallback != null) params['fallback'] = fallback.value;
    if (refresh != null) params['refresh'] = refresh ? '1' : '0';
    if (returnHash != null) params['return_hash'] = returnHash ? '1' : '0';

    return buildTautulliUri(_connection, params);
  }
}
