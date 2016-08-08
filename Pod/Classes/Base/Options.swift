/// Player initialization options.
public typealias Options = [String : AnyObject]

/// Poster URL (`String`).
public let kPosterUrl = "posterUrl"
/// Source URL (`String`).
public let kSourceUrl = "sourceUrl"
/// Custom media control (`MediaControl`).
public let kMediaControl = "mediaControl"
/// Start in fullscreen mode (`Bool`).
public let kFullscreen = "fullscreen"
/// Disable fullscreen button (`Bool`).
public let kFullscreenDisabled = "fullscreenDisabled"
/// Start media at this position (`NSTimeInterval`).
public let kStartAt = "startAt"
/// Start playing media automatically (`Bool`).
public let kAutoPlay = "autoplay"
/// Custom message for Playback not Supported error (`String`).
public let kPlaybackNotSupportedMessage = "playbackNotSupportedMessage"
/// Media MIME type (`String`).
public let kMimeType = "mimeType"
/// Default subtitle to be displayed (`String`).
public let kDefaultSubtitle = "defaultSubtitle"
/// Default audio source for media (`String`).
public let kDefaultAudioSource = "defaultAudioSource"
