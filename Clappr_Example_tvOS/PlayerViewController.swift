//
//  PlayerViewController.swift
//  Clappr_Example_tvOS
//
//  Created by Igor Oliveira on 19/09/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import Clappr

class PlayerViewController: UIViewController {

    var player: Player!

    override func viewDidLoad() {
        super.viewDidLoad()
        let options: Options = [
            kSourceUrl: "http://clappr.io/highline.mp4",
            kPosterUrl: "http://clappr.io/poster.png",
            kAutoPlay: true
            ]
        player = Player(options: options)

        listenToPlayerEvents()

        player.attachTo(controller: self)
    }

    func listenToPlayerEvents() {
        player.on(Event.playing) { _ in print("on Play") }

        player.on(Event.didPause) { _ in print("on Pause") }

        player.on(Event.didStop) { _ in print("on Stop") }

        player.on(Event.didComplete) { _ in print("on Complete") }

        player.on(Event.ready) { _ in print("on Ready") }

        player.on(Event.error) { userInfo in print("on Error: \(String(describing: userInfo))") }

        player.on(Event.requestFullscreen) { _ in print("on Enter Fullscreen") }

        player.on(Event.exitFullscreen) { _ in print("on Exit Fullscreen") }

        player.on(Event.stalled) { _ in print("on Stalled") }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    deinit {
        player.destroy()
        player = nil
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
