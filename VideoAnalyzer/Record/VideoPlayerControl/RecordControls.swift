//
//  RecordControls.swift
//  VideoAnalyzer
//
//  Created by Nguyễn Đức Thọ on 11/7/18.
//  Copyright © 2018 Nguyễn Đức Thọ. All rights reserved.
//

import UIKit

class RecordControls: NibView {
    
    var startRecording: (() -> ()) = { }
    var stopRecording: (() -> ()) = { }
    var startPlayer: (() -> ()) = { }
    var pausePlayer: (() -> ()) = { }
    var close: (() -> ()) = { }
    
    enum RecordingState {
        case ready
        case recording
    }
    
    enum PlayingState {
        case playing
        case pause
    }
    
    private var recordingState = RecordingState.ready
    private var playingState = PlayingState.pause
    
    @IBOutlet private weak var btnRecord: UIButton!
    @IBOutlet private weak var btnPlay: UIButton!
    @IBOutlet private weak var sliderVideoProgress: UISlider!

    //MARK: - Button action
    @IBAction func tapRecord(_ sender: Any) {
        switch recordingState {
        case .ready:
            self.btnRecord.setBackgroundImage(UIImage(named: "recording"), for: .normal)
            recordingState = .recording
            startRecording()
            break
        case .recording:
            self.btnRecord.setBackgroundImage(UIImage(named: "record"), for: .normal)
            recordingState = .ready
            stopRecording()
            break
        }
    }
    
    @IBAction func tapPlay(_ sender: Any) {
        switch playingState {
        case .pause:
            self.btnPlay.setBackgroundImage(UIImage(named: "playing"), for: .normal)
            playingState = .playing
            startPlayer()
            break
        case .playing:
            self.btnPlay.setBackgroundImage(UIImage(named: "pause"), for: .normal)
            playingState = .pause
            pausePlayer()
            break
        }

    }
    
    @IBAction func tapClose(_ sender: Any) {
        close()
    }
    
}
