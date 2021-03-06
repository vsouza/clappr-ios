import Quick
import Nimble
@testable import Clappr

class CoreTests: QuickSpec {
    override func spec() {
        let options = [kSourceUrl: "http//test.com"]
        var core: Core!
        let loader = Loader(externalPlugins: [StubPlayback.self])

        beforeEach {
            core = Core(loader: loader, options: options as Options)
        }

        describe("Core") {
            context("Options") {

                it("Should have a constructor with options") {
                    let options = ["SomeOption": true]
                    let core = Core(loader: loader, options: options as Options)

                    expect(core.options["SomeOption"] as? Bool) == true
                }

                context("Fullscreen") {
                    it("Should start as embed video when `kFullscreen: false`") {
                        let options: Options = [kFullscreen: false]
                        let core = Core(options: options)
                        core.parentView = UIView()
                        core.render()
                        expect(core.parentView?.subviews.contains(core)).to(beTrue())
                        expect(core.mediaControl?.fullscreen).to(beFalse())
                    }

                    it("Should start as embed video when `kFullscreen` was not passed") {
                        let core = Core()
                        core.parentView = UIView()
                        core.render()
                        expect(core.parentView?.subviews.contains(core)).to(beTrue())
                        expect(core.mediaControl?.fullscreen).to(beFalse())
                    }

                    it("Should start as fullscreen video when `kFullscreen: true` was passed") {
                        let options: Options = [kFullscreen: true]
                        let core = Core(options: options)
                        core.parentView = UIView()

                        self.expectation(forNotification: InternalEvent.didEnterFullscreen.rawValue, object: core.fullscreenHandler) { notification in
                            return true
                        }

                        self.expectation(forNotification: InternalEvent.willEnterFullscreen.rawValue, object: core.fullscreenHandler) { notification in
                            return true
                        }

                        core.render()
                        self.waitForExpectations(timeout: 2, handler: nil)
                        expect(core.parentView?.subviews.contains(core)).to(beFalse())
                        expect(core.fullscreenController.view.subviews.contains(core)).to(beTrue())
                        expect(core.mediaControl?.fullscreen).to(beTrue())
                    }

                    it("Should start as embed video when `kFullscreen: true` and `kFullscreenByApp: true` was passed") {
                        let options: Options = [kFullscreen: true, kFullscreenByApp: true]
                        let core = Core(options: options)
                        core.parentView = UIView()
                        core.render()
                        expect(core.parentView?.subviews.contains(core)).to(beTrue())
                        expect(core.mediaControl?.fullscreen).to(beFalse())
                    }

                    it("Should start as fullscreen video when `kFullscreen: true` and `kFullscreenByApp: false` was passed") {
                        let options: Options = [kFullscreen: true]
                        let core = Core(options: options)
                        core.parentView = UIView()

                        self.expectation(forNotification: InternalEvent.didEnterFullscreen.rawValue, object: core.fullscreenHandler) { notification in
                            return true
                        }

                        self.expectation(forNotification: InternalEvent.willEnterFullscreen.rawValue, object: core.fullscreenHandler) { notification in
                            return true
                        }

                        core.render()
                        self.waitForExpectations(timeout: 2, handler: nil)
                        expect(core.parentView?.subviews.contains(core)).to(beFalse())
                        expect(core.fullscreenController.view.subviews.contains(core)).to(beTrue())
                        expect(core.mediaControl?.fullscreen).to(beTrue())
                    }
                    
                }
            }

            context("Containers") {
                it("Should be created given a source") {
                    expect(core.activeContainer).toNot(beNil())
                    expect(core.plugins).to(beEmpty())
                    expect(core.containers).toNot(beEmpty())
                }
            }

            context("Media Control") {
                it("Should have container reference") {
                    expect(core.mediaControl).toNot(beNil())
                    expect(core.mediaControl?.container) == core.activeContainer
                }

                it("Should be the top view on core") {
                    core.render()
                    expect(core.subviews.last) == core.mediaControl
                }
            }

            describe("Plugins") {
                context("Addition") {
                    it("Should be able to add plugins") {
                        core.addPlugin(FakeCorePlugin())
                        expect(core.plugins.count) == 1
                    }

                    it("Should add plugin as subview after rendered") {
                        let plugin = FakeCorePlugin()
                        core.addPlugin(plugin)
                        core.render()

                        expect(plugin.superview) == core
                    }
                }

                context("Verification") {
                    it("Should return true if a plugin is installed") {
                        core.addPlugin(FakeCorePlugin())
                        let containsPlugin = core.hasPlugin(FakeCorePlugin.self)
                        expect(containsPlugin).to(beTrue())
                    }

                    it("Should return false if a plugin isn't installed") {
                        core.addPlugin(UICorePlugin())
                        let containsPlugin = core.hasPlugin(FakeCorePlugin.self)
                        expect(containsPlugin).to(beFalse())
                    }
                }
            }

            describe("OptionWrapper") {

                var optionsUnboxer: OptionsUnboxer!

                context("Default values or nil") {

                    beforeEach {
                        optionsUnboxer = OptionsUnboxer(options: [:])
                    }

                    it("should returns `false` for `fullscreen`") {
                        expect(optionsUnboxer.fullscreen).to(beFalse())
                    }

                    it("should returns `false` for `kFullscreenByApp`") {
                        expect(optionsUnboxer.fullscreenControledByApp).to(beFalse())
                    }
                }

                context("Set") {

                    it("should returns correct value for `fullscreen`") {
                        optionsUnboxer = OptionsUnboxer(options: [kFullscreen: true])
                        expect(optionsUnboxer.fullscreen).to(beTrue())

                    }

                    it("should returns correct value for `kFullscreenByApp`") {
                        optionsUnboxer = OptionsUnboxer(options: [kFullscreenByApp: true])
                        expect(optionsUnboxer.fullscreenControledByApp).to(beTrue())
                    }
                }
            }
        }
    }

    class StubPlayback: Playback {
        override var pluginName: String {
            return "stupPlayback"
        }
    }

    class FakeCorePlugin: UICorePlugin {
        override var pluginName: String {
            return "FakeCorePLugin"
        }
    }
}
