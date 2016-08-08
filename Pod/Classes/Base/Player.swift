/**
 Clappr is an open source, event based, plugin oriented extensible media player.

 Player is the main class and interface to Clappr. Once instantiated it should be [attached to](attachTo:) a UIView before playback can begin. The player will occupy the whole View and resize the video to fit that area. Applications requiring finer control over playback should implement the WebmediaPlayerEventListener protocol and register this listener to the player setting the eventListener property.

 By default the player will try to play the video immediately after being attached, using the production environment. The application can override these options using a dictionary passed to either initWithOptions: or initWithVideoId:options:.

 **Example usage**

     let options = [kSourceUrl : "http://clappr.io/highline.mp4"]
     player = Player(options: options)

 */
public class Player: BaseObject {
    /// Player unique `Core`
    public private(set) var core: Core

    /// Current active Container.
    public var activeContainer: Container? {
        return core.activeContainer
    }

    /// Current active Playback.
    public var activePlayback: Playback? {
        return core.activePlayback
    }

    /// Whether or not Player is in fullscreen mode.
    public var isFullscreen: Bool {
        return core.isFullscreen
    }

    /// Whether or not the media is playing.
    public var isPlaying: Bool {
        return activePlayback?.isPlaying ?? false
    }

    /// Whether or not the media is paused.
    public var isPaused: Bool {
        return activePlayback?.isPaused ?? false
    }

    /// Whether or not the media is buffering.
    public var isBuffering: Bool {
        return activePlayback?.isBuffering ?? false
    }

    /// Media duration in seconds.
    public var duration: Double {
        return activePlayback?.duration ?? 0
    }

    /// Current media playing position.
    public var position: Double {
        return activePlayback?.position ?? 0
    }
    
    /// List of media subtitles resources.
    public var subtitles: [MediaOption]? {
        return activePlayback?.subtitles
    }
    
    /// List of media audio sources.
    public var audioSources: [MediaOption]? {
        return activePlayback?.audioSources
    }
    
    /// Current selected subtitle.
    public var selectedSubtitle: MediaOption? {
        get {
            return activePlayback?.selectedSubtitle
        }
        set {
            activePlayback?.selectedSubtitle = newValue
        }
    }
    
    /// Current selected audio source.
    public var selectedAudioSource: MediaOption? {
        get {
            return activePlayback?.selectedAudioSource
        }
        set {
            activePlayback?.selectedAudioSource = newValue
        }
    }

    /**
     Creates a player.
     
     - parameter options: 
        Available `Options` keys are: `kPosterUrl`, `kSourceUrl`, `kMediaControl`, `kFullscreen`, `kFullscreenDisabled`, `kStartAt`, `kAutoPlay`, `kPlaybackNotSupportedMessage`, `kMimeType`, `kDefaultSubtitle`, `kDefaultAudioSource`
     - parameter externalPlugins: List of additional plugins

     The player created must be attached with `attachTo(_:controller:)` to a `UIView` before being used. The player returned can later on be reused to play other sources by using `load(_:mimeType:)` .
     */
    public init(options: Options = [:], externalPlugins: [Plugin.Type] = []) {
        let loader = Loader(externalPlugins: externalPlugins, options: options)
        self.core = CoreFactory.create(loader , options: options)
    }
    
    /**
     Attaches the player to a `UIView` under a `UIViewController`.

     - parameter view: a visible UIView created by the application using this player.
     - parameter controller:

     After the player has been created, it must be included within a UIView using this method. The player will resize itself and fit the video under the containing view without distorting.
     */
    public func attachTo(view: UIView, controller: UIViewController) {
        bindEvents()
        core.parentController = controller
        core.parentView = view
        core.render()
    }
    
    public func load(source: String, mimeType: String? = nil) {
        core.container.load(source, mimeType: mimeType)
        play()
    }
    
    public func play() {
        core.container.play()
    }
    
    public func pause() {
        core.container.pause()
    }
    
    public func stop() {
        core.container.stop()
    }
    
    public func seek(timeInterval: NSTimeInterval) {
        core.container.seek(timeInterval)
    }
    
    public func setFullscreen(fullscreen: Bool) {
        core.setFullscreen(fullscreen)
    }
    
    public func on(event: PlayerEvent, callback: EventCallback) -> String {
        return on(event.rawValue, callback: callback)
    }
    
    private func bindEvents() {
        for (event, callback) in coreBindings() {
            listenTo(core, eventName: event.rawValue, callback: callback)
        }
        for (event, callback) in containerBindings() {
            listenTo(core.container, eventName: event.rawValue, callback: callback)
        }
    }

    private func coreBindings() -> [CoreEvent : EventCallback] {
        return [
            .EnterFullscreen : { [weak self] (info: EventUserInfo) in self?.forward(.EnterFullscreen, userInfo: info)},
            .ExitFullscreen  : { [weak self] (info: EventUserInfo) in self?.forward(.ExitFullscreen, userInfo: info)}
        ]
    }
    
    private func containerBindings() -> [ContainerEvent : EventCallback] {
        return [
            .Play  : { [weak self] (info: EventUserInfo) in self?.forward(.Play, userInfo: info)},
            .Ready : { [weak self] (info: EventUserInfo) in self?.forward(.Ready, userInfo: info)},
            .Ended : { [weak self] (info: EventUserInfo) in self?.forward(.Ended, userInfo: info)},
            .Error : { [weak self] (info: EventUserInfo) in self?.forward(.Error, userInfo: info)},
            .Stop  : { [weak self] (info: EventUserInfo) in self?.forward(.Stop, userInfo: info)},
            .Pause : { [weak self] (info: EventUserInfo) in self?.forward(.Pause, userInfo: info)}
        ]
    }
    
    private func forward(event: PlayerEvent, userInfo: EventUserInfo) {
        trigger(event.rawValue, userInfo: userInfo)
    }
    
    deinit {
        stopListening()
    }
}