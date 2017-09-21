//
//  ViewController.swift
//  Clappr_Example_tvOS
//
//  Created by Igor Oliveira on 19/09/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import Clappr

class ViewControllerTVOS: UIViewController {

    @IBOutlet weak var playerContainer: UIView!
    
    var player: Player?

    override func viewDidLoad() {
        super.viewDidLoad()

        Logger.setLevel(.debug)

        let options: Options = [
            kSourceUrl: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8",
            kPosterUrl: "http://clappr.io/poster.png",
            kAutoPlay: true
            ]
        player = Player(options: options)

        listenToPlayerEvents()

        player?.attachTo(playerContainer, controller: self)
    }

    func listenToPlayerEvents() {
        player?.on(Event.playing) { _ in print("on Play") }

        player?.on(Event.didPause) { _ in print("on Pause") }

        player?.on(Event.didStop) { _ in print("on Stop") }

        player?.on(Event.didComplete) { _ in print("on Complete") }

        player?.on(Event.ready) {  _ in
            print("on Ready")
        }

        player?.on(Event.error) { userInfo in print("on Error: \(String(describing: userInfo))") }

        player?.on(Event.requestFullscreen) { _ in print("on Enter Fullscreen") }

        player?.on(Event.exitFullscreen) { _ in print("on Exit Fullscreen") }

        player?.on(Event.stalled) { _ in print("on Stalled") }
    }

    @IBAction func playVideo(_ sender: Any) {
        let playerViewController = PlayerViewController()
        self.present(playerViewController, animated: true)
    }

}


