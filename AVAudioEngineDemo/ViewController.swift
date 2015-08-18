//
//  ViewController.swift
//  AVAudioEngineDemo
//
//  Created by John Pitchko on 2015-Jan-27.
//  Copyright (c) 2015 Pitchko Technology. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
  
  let audioEngine = AVAudioEngine()
  let audioPlayerNode = AVAudioPlayerNode()
  let audioTimePitch = AVAudioUnitTimePitch()
  var audioFile: AVAudioFile!
  var audioBuffer: AVAudioPCMBuffer!

  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var stopButton: UIButton!
  @IBOutlet weak var pitchSlider: UISlider!
  @IBOutlet weak var pitchValueLabel: UILabel!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    pitchValueLabel.text = "0.0"
    
    NSLog("Initializing engine & connecting player node...")
    audioEngine.attachNode(audioPlayerNode)
    
    NSLog("Finding & loading audio file...")
    var fileError: NSError?
    let audioFileUrl = NSBundle.mainBundle().URLForResource("db9_onlow", withExtension: "wav")
    NSLog("Bundle URL: %@", audioFileUrl!.path!)
    var audioFile = AVAudioFile(forReading: audioFileUrl, error: &fileError)
    
    

    NSLog("Reading audio file data into buffer...")
    audioBuffer = AVAudioPCMBuffer(PCMFormat: audioFile.processingFormat, frameCapacity: 2400)
    var bufferError: NSError?
    audioFile.readIntoBuffer(audioBuffer, error: &bufferError)
    
   
    
//    Set up the main mixer node, and connect it to the Audio Player Node
//    NSLog("Initializing & connecting main mixer node...")
//    let mainMixerNode = audioEngine.mainMixerNode
//    audioEngine.connect(audioPlayerNode, to: mainMixerNode, format: audioFile.processingFormat)
    
    NSLog("Connecting time pitch effect to player node and engine...")
    audioEngine.attachNode(audioTimePitch)
    audioEngine.connect(audioPlayerNode, to: audioTimePitch, format: audioFile.processingFormat)
    audioEngine.connect(audioTimePitch, to: audioEngine.outputNode, format: audioFile.processingFormat)
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func play(sender: AnyObject) {
    
    //    Scheduling the sound to loop
    NSLog("Scheduling audio buffer...")
//    audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
    audioPlayerNode.scheduleBuffer(audioBuffer, atTime: nil, options: AVAudioPlayerNodeBufferOptions.Loops, completionHandler: nil)
    
    //    Start engine and play the sound
    NSLog("Starting engine and playing sound...")
    var engineError:NSError?
    audioEngine.startAndReturnError(&engineError)
    audioPlayerNode.play()
    
//    Hide the play button, show the stop button
    playButton.hidden = true
    stopButton.hidden = false
    
    pitchValueLabel.text = audioTimePitch.pitch.description
    
  }
  
  @IBAction func stop(sender: AnyObject) {
    audioPlayerNode.stop()
    
//    Hide the stop button, show the play button
    playButton.hidden = false
    stopButton.hidden = true
  }
  
  @IBAction func shiftPitch(sender: AnyObject) {
    audioTimePitch.pitch = pitchSlider.value
    pitchValueLabel.text = audioTimePitch.pitch.description
    NSLog("Pitch value is now %f", audioTimePitch.pitch)
  }

}

