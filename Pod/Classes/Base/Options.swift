/// Player initialization options.
public typealias Options = [String : AnyObject]

/** 
 Initialization option key.
 
 Value: Media poster URL as a `String`.
 */
public let kPosterUrl = "posterUrl"
/**
 Initialization option key.
 
 Value: Media source URL as a `String`.
 */
public let kSourceUrl = "sourceUrl"
/**
 Initialization option key.
 
 Value: A `MediaControl` to replace the default controls.
 */
public let kMediaControl = "mediaControl"
/**
 Initialization option key.
 
 Value: `Bool` to indicate if Player should start in fullscreen mode.
 */
public let kFullscreen = "fullscreen"
/**
 Initialization option key.
 
 Value: `Bool` to indicate if the fullscreen button should be disabled.
 */
public let kFullscreenDisabled = "fullscreenDisabled"
/**
 Initialization option key.
 
 Value: `NSTimeInterval` to indicate the media start position in seconds.
 */
public let kStartAt = "startAt"
/**
 Initialization option key.
 
 Value: `Bool` to indicate if media should start automatically.
 */
public let kAutoPlay = "autoplay"
/**
 Initialization option key.
 
 Value: `String` to be used as Playback not Supported error.
 */
public let kPlaybackNotSupportedMessage = "playbackNotSupportedMessage"
/**
 Initialization option key.
 
 Value: Media MIME type as a `String`.
 */
public let kMimeType = "mimeType"
/**
 Initialization option key.
 
 Value: Default subtitle track name as a `String`.
 */
public let kDefaultSubtitle = "defaultSubtitle"
/**
 Initialization option key.
 
 Value: Default audio source track name as a `String`.
 */
public let kDefaultAudioSource = "defaultAudioSource"
