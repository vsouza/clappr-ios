import Quick
import Nimble
import Clappr

class MediaControlTests: QuickSpec {
    
    override func spec() {
        describe("MediaControl") {
            let options = [kSourceUrl : "http://globo.com/video.mp4"]
            var container: Container!
            var playback: StubedPlayback!
            
            beforeEach() {
                playback = StubedPlayback(options: options as Options)
                container = Container(playback: playback)
            }
            
            context("Initialization") {
                
                it("Should have a init method to setup with container") {
                    let mediaControl = MediaControl.create()
                    mediaControl.setup(container)
                    
                    expect(mediaControl).toNot(beNil())
                    expect(mediaControl.container) == container
                }
            }
            
            context("Behavior") {
                var mediaControl: MediaControl!
                
                beforeEach() {
                    mediaControl = MediaControl.create()
                    mediaControl.setup(container)
                }
                
                context("Visibility") {
                    it("Should start with controls hidden") {
                        expect(mediaControl.controlsOverlayView!.alpha) == 0
                        expect(mediaControl.controlsWrapperView!.alpha) == 0
                        expect(mediaControl.controlsHidden).to(beTrue())
                    }
                    
                    it("Should show it's control after when media control is enabled on container") {
                        container.mediaControlEnabled = true
                        
                        expect(mediaControl.controlsOverlayView!.alpha) == 1
                        expect(mediaControl.controlsWrapperView!.alpha) == 1
                        expect(mediaControl.controlsHidden).to(beFalse())
                    }
                    
                    it("Should hide it's control after hide is called and media control is enabled") {
                        container.mediaControlEnabled = true
                        mediaControl.hide()
                        
                        expect(mediaControl.controlsOverlayView!.alpha) == 0
                        expect(mediaControl.controlsWrapperView!.alpha) == 0
                        expect(mediaControl.controlsHidden).to(beTrue())
                    }
                    
                    it("Should show it's control after show is called and media control is enabled") {
                        container.mediaControlEnabled = true
                        mediaControl.hide()
                        mediaControl.show()
                        
                        expect(mediaControl.controlsOverlayView!.alpha) == 1
                        expect(mediaControl.controlsWrapperView!.alpha) == 1
                        expect(mediaControl.controlsHidden).to(beFalse())
                    }
                }
                
                context("Play") {
                    it("Should call container play when is paused") {
                        mediaControl.playbackControlState = .paused
                        mediaControl.playbackControlButton!.sendActions(for: UIControlEvents.touchUpInside)
                        expect(container.isPlaying).to(beTrue())
                    }
                    
                    it("Should call container play when is stopped") {
                        mediaControl.playbackControlState = .stopped
                        mediaControl.playbackControlButton!.sendActions(for: UIControlEvents.touchUpInside)
                        expect(container.isPlaying).to(beTrue())
                    }
                    
                    it("Should trigger playing event ") {
                        var callbackWasCalled = false
                        mediaControl.once(MediaControlEvent.playing.rawValue) { _ in
                            callbackWasCalled = true
                        }
                        
                        mediaControl.playbackControlButton!.sendActions(for: UIControlEvents.touchUpInside)
                        
                        expect(callbackWasCalled).to(beTrue())
                    }
                }
                
                context("Pause") {
                    beforeEach() {
                        mediaControl.playbackControlState = .playing
                        playback.type = .vod
                    }
                    
                    it("Should call container pause when is playing") {
                        mediaControl.playbackControlButton!.sendActions(for: UIControlEvents.touchUpInside)
                        expect(container.isPlaying).to(beFalse())
                    }
                    
                    it("Should change playback control state to paused") {
                        mediaControl.playbackControlButton!.sendActions(for: UIControlEvents.touchUpInside)
                        expect(mediaControl.playbackControlState) == PlaybackControlState.paused
                    }
                    
                    it("Should trigger not playing event when selecting button") {
                        var callbackWasCalled = false
                        mediaControl.once(MediaControlEvent.notPlaying.rawValue) { _ in
                            callbackWasCalled = true
                        }
                        
                        mediaControl.playbackControlButton!.sendActions(for: UIControlEvents.touchUpInside)
                        
                        expect(callbackWasCalled).to(beTrue())
                    }
                }
                
                context("Stop") {
                    beforeEach() {
                        mediaControl.playbackControlState = .playing
                        playback.type = .live
                        container.trigger(ContainerEvent.ready.rawValue)
                    }
                    
                    it("Should call container pause when is live video is playing") {
                        mediaControl.playbackControlButton!.sendActions(for: UIControlEvents.touchUpInside)
                        expect(container.isPlaying).to(beFalse())
                    }
                    
                    it("Should change playback control state to stopped") {
                        mediaControl.playbackControlButton!.sendActions(for: UIControlEvents.touchUpInside)
                        expect(mediaControl.playbackControlState) == PlaybackControlState.stopped
                    }
                    
                    it("Should trigger not playing event when selecting button") {
                        var callbackWasCalled = false
                        mediaControl.once(MediaControlEvent.notPlaying.rawValue) { _ in
                            callbackWasCalled = true
                        }
                        
                        mediaControl.playbackControlButton!.sendActions(for: UIControlEvents.touchUpInside)
                        
                        expect(callbackWasCalled).to(beTrue())
                    }
                }
                
                context("Live") {
                    it("Should hide labels when playback is live") {
                        mediaControl.playbackControlState = .playing
                        playback.type = .live
                        container.trigger(ContainerEvent.ready.rawValue)
                        
//                        expect(mediaControl.labelsWrapperView.hidden).to(beTrue())
                    }
                }
                
                context("Current Time") {
                    it("Should start with 00:00 as current time") {
                        expect(mediaControl.currentTimeLabel!.text) == "00:00"
                    }
                    
                    it ("Should listen to current time updates") {
                        let info: EventUserInfo = ["position" : 78.0]
                        playback.trigger(PlaybackEvent.timeUpdated.rawValue, userInfo: info)
                        
                        expect(mediaControl.currentTimeLabel!.text) == "01:18"
                    }
                }
                
                context("Duration") {
                    it("Should start with 00:00 as duration") {
                        expect(mediaControl.currentTimeLabel!.text) == "00:00"
                    }
                    
                    it ("Should listen to Ready event ") {
                        playback.trigger(PlaybackEvent.ready.rawValue)
                        
                        expect(mediaControl.durationLabel!.text) == "00:30"
                    }
                }
                
                context("End") {
                    it("Should reset play button state after container end event") {
                        mediaControl.playbackControlState = .playing
                        container.trigger(ContainerEvent.ended.rawValue)
                        
                        expect(mediaControl.playbackControlState) == PlaybackControlState.stopped
                    }
                }

                context("Fullscreen") {
                    it("Should hide fullscreen button if disabled via options") {
                        let options = [kFullscreenDisabled: true]
                        container = Container(playback: playback, options: options as Options)
                        mediaControl.setup(container)

                        expect(mediaControl.fullscreenButton?.isHidden) == true
                    }

                    it("Should show fullscreen button if no option is set") {
                        expect(mediaControl.fullscreenButton?.isHidden) == false
                    }
                }
            }
        }
    }
    
    class StubedPlayback: Playback {
        var playing = false
        var type = PlaybackType.vod
        
        override var pluginName: String {
            return "Playback"
        }
        
        override var isPlaying: Bool {
            return playing
        }
        
        override func play() {
            playing = true
        }
        
        override func pause() {
            playing = false
        }
        
        override var playbackType: PlaybackType {
            return type
        }
        
        override var duration: Double {
            return 30
        }
    }
}