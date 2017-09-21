import Kingfisher
import UIKit

open class PosterPlugin: UIContainerPlugin {
    fileprivate var poster = UIImageView(frame: CGRect.zero)
    fileprivate var playButton = UIButton(frame: CGRect.zero)

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override var pluginName: String {
        return "poster"
    }

    public required init() {
        super.init()
    }

    public required init(context: UIBaseObject) {
        super.init(context: context)
        translatesAutoresizingMaskIntoConstraints = false
        poster.contentMode = .scaleAspectFit
        bindContainerEvents()
    }

    open override func render() {
        guard let container = container else { return }
        if let urlString = container.options[kPosterUrl] as? String {
            setPosterImage(with: urlString)
        } else {
            isHidden = true
            container.mediaControlEnabled = false
        }

        configurePlayButton()
        configureViews()
    }

    fileprivate typealias PosterUrl = String
    fileprivate func setPosterImage(with urlString: PosterUrl) {
        if let url = URL(string: urlString) {
            poster.kf.setImage(with: url)
        } else {
            Logger.logWarn("invalid URL.", scope: pluginName)
        }
    }

    fileprivate func configurePlayButton() {
        let image = UIImage(named: "poster-play", in: Bundle(for: PosterPlugin.self),
                            compatibleWith: nil)
        playButton.setBackgroundImage(image, for: UIControlState())
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(PosterPlugin.playTouched), for: .touchUpInside)
    }

    @objc func playTouched() {
        container?.playback?.seek(0)
        container?.playback?.play()
    }

    fileprivate func configureViews() {
        container?.addMatchingConstraints(self)
        addSubviewMatchingConstraints(poster)

        addSubview(playButton)

        let xCenterConstraint = NSLayoutConstraint(item: playButton, attribute: .centerX,
                                                   relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        addConstraint(xCenterConstraint)

        let yCenterConstraint = NSLayoutConstraint(item: playButton, attribute: .centerY,
                                                   relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        addConstraint(yCenterConstraint)
    }

    private func bindPlaybackEvents() {
        if let playback = container?.playback {
            listenTo(playback, eventName: Event.playing.rawValue) { [weak self] _ in self?.playbackStarted() }
            listenTo(playback, eventName: Event.ready.rawValue) { [weak self] _ in self?.playbackReady() }
            listenTo(playback, eventName: Event.stalled.rawValue) { [weak self] _ in self?.playbackStalled() }
            listenTo(playback, eventName: Event.didComplete.rawValue) { [weak self] _ in self?.playbackEnded() }
        }
    }

    private func bindContainerEvents() {
        guard let container = container else { return }
        listenTo(container, eventName: InternalEvent.didChangePlayback.rawValue) { [weak self] _ in self?.didChangePlayback() }
        listenTo(container, eventName: Event.requestPosterUpdate.rawValue) { [weak self] info in self?.updatePoster(info) }
    }

    private func didChangePlayback() {
        stopListening()
        bindPlaybackEvents()
        bindContainerEvents()
    }

    fileprivate func playbackStalled() {
        playButton.isHidden = true
    }

    fileprivate func playbackStarted() {
        isHidden = true
        container?.mediaControlEnabled = true
    }

    fileprivate func playbackEnded() {
        container?.mediaControlEnabled = false
        playButton.isHidden = false
        isHidden = false
    }

    fileprivate func playbackReady() {
        if container?.playback?.pluginName == "NoOp" {
            isHidden = true
        }
    }

    fileprivate func updatePoster(_ info: EventUserInfo) {
        Logger.logInfo("Updating poster", scope: pluginName)
        guard let posterUrl = info?[kPosterUrl] as? String else {
            Logger.logWarn("Unable to update poster, no url was found", scope: pluginName)
            return
        }
        trigger(Event.willUpdatePoster)
        setPosterImage(with: posterUrl)
        trigger(Event.didUpdatePoster)

    }
}
