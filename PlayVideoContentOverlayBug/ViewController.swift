//
//  ViewController.swift
//  PlayVideoContentOverlayBug
//
//  Created by Angel Olvera on 2019-09-05.
//  Copyright © 2019 Angel Olvera. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    let avPlayer = AVPlayerViewController()
    var button: UIButton?

    func addCustomControls() {
        guard let overlayView = avPlayer.contentOverlayView
            else { return }
        // add our button
        let theButton = UIButton()
        theButton.setTitle("Show controls for a few secs", for: .normal)
        theButton.sizeToFit()
        theButton.translatesAutoresizingMaskIntoConstraints = false
        theButton.addTarget(self, action: #selector(self.onShowControlsPressed), for: .touchUpInside)
        theButton.backgroundColor = UIColor(white: 0.25, alpha: 0.55)
        overlayView.addSubview(theButton)
        button = theButton
    }

    @objc func onShowControlsPressed() {
        print("showing playback controls")
        guard let overlayView = avPlayer.contentOverlayView
            else { return }
        overlayView.isHidden = true
        
        // a - showing the playback controls will add a view
        avPlayer.showsPlaybackControls = true
//         UNCOMMENT THE FOLLOWING LINE TO FIX THE PROBLEM 1/2
//        togglePlaybackControlsView(self.avPlayer.view, isHidden: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
            // b - remove playback controls
            self.avPlayer.showsPlaybackControls = false
            overlayView.isHidden = false
            // At this point, our custom controls are visible, but they no longer work!!
            // This is because the view added in point a is not removed by point b.
            // The workaround consists in removing that view, which is of type AVPlaybackControlsView. Uncomment the line below and run the app again to see the difference
            
//         UNCOMMENT THE FOLLOWING LINE TO FIX THE PROBLEM 2/2
//            self.togglePlaybackControlsView(self.avPlayer.view, isHidden: true)
        })
    }
    
    // There's a bug in the controller in iOS 12 (the bug is fixed in iOS 13). It's like this:
    // 1-Before showing the AVPlayerViewController controller, set its showsPlaybackControls property to false, then add your custom controls. Start playback.
    // 2-At this point, your custom controls work
    // 3-While playing, set showsPlaybackControls to true, then set it back to false
    // 4-At this point, your custom controls no longer work!
    // The issue occurs because the playback controls view (AVPlaybackControlsView) is on top of the contentOverlayView view and it's not removed when you set showsPlaybackControls to false.
    // How to fix it: We could remove or hide/disable the AVPlaybackControlsView view. This would allow the contentOverlayView view to receive touches again. If we remove the view, however, it won't be added again when we set showsPlaybackControls to true! So the best fix is to hide/disable the AVPlaybackControlsView view
    
    private func togglePlaybackControlsView(_ baseView: UIView, isHidden: Bool) {
        if #available(iOS 13.0, *) {
            return  // no need for the fix in iOS 13
        }
        
        func toggleView(_ baseView: UIView, isHidden: Bool) {
            let className = String(describing: type(of: baseView))
            if className == "AVPlaybackControlsView" {
                baseView.isHidden = isHidden
                return
            }
            for view in baseView.subviews {
                toggleView(view, isHidden: isHidden)
            }
        }
        toggleView(baseView, isHidden: isHidden)
    }

    
    // MARK: - Actions
    @IBAction func onPlayVideoPressed(_ sender: Any) {
        if let url = Bundle.main.url(forResource: "test-video", withExtension: "mov") {
            avPlayer.showsPlaybackControls = false
            avPlayer.player = AVPlayer(url: url)
            present(avPlayer, animated: true, completion: {
                self.avPlayer.entersFullScreenWhenPlaybackBegins = true
                self.avPlayer.exitsFullScreenWhenPlaybackEnds = true
                self.addCustomControls()
                self.avPlayer.player?.play()
            })
        }
        else {
            print("the url is not valid")
        }

    }
    
}

