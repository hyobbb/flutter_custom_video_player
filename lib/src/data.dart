enum SourceType {
  /// The video was included in the app's asset files.
  asset,

  /// The video was downloaded from the internet.
  network,

  /// The video was loaded off of the local filesystem.
  file,
}

class VideoSource {
  final SourceType type;
  final String url;
  final int? duration; //milliseconds
  final String? thumbUrl;

  const VideoSource({
    required this.type,
    required this.url,
    this.duration,
    this.thumbUrl,
  });
}