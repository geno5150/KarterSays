//
//  RecorderViewController.swift
//  KarterSays
//
//  Created by Geno Erickson on 12/19/15.
//  Copyright © 2015 SuctionPeach. All rights reserved.
//

import UIKit
import AVFoundation

class RecorderViewController: UIViewController, AVAudioRecorderDelegate {
    var speed = 1000.0
    var audioRecorder: AVAudioRecorder!
    var listenerRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    var audioPlayer: AVAudioPlayer!
    var receivedAudio: RecordedAudio!
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    var audioPlayerNode: AVAudioPlayerNode!
    var timer: NSTimer!
    let img1 = UIImage(named: "happy Karter.jpg")
    let img2 = UIImage(named: "happy Karter Open.jpg")
    let img3 = UIImage(named: "happy Karter Listening.jpg")
    var playerFlag = false
    var inPlaybackLoop = false
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up animation image array
        var ImgArray: [UIImage] = []
        
        ImgArray.append(img1!)
        ImgArray.append(img2!)
        
        animImage.animationImages = ImgArray
        animImage.animationDuration = 0.25
       
        
        //init audioPlayerNode and create a timer to check for input audio
        audioPlayerNode = AVAudioPlayerNode()
        //audioRecorder = AVAudioRecorder()
       
          }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    @IBAction func goBack(sender: AnyObject) {
        //kill the listener and timer when we go back to the main
        timer.invalidate()
        listenerRecorder.stop()
        
        
    }
    func setupPlayer(){
        //setup the audioNode player
        if playerFlag == false{
        audioPlayer = try? AVAudioPlayer(contentsOfURL: audioRecorder.url)
        audioPlayer.enableRate = true
        audioEngine = AVAudioEngine()
        audioFile = try? AVAudioFile(forReading: audioRecorder.url)
        
        // play on speaker, not thru any external device
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
            } catch _ {
                print("Error")
            }
        }else{
                playerFlag = true
            }
    }
    
    
    @IBOutlet weak var startButton: UIButton!
    @IBAction func startKarter(sender: AnyObject) {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.1, target: self, selector: "startListener", userInfo: nil, repeats: true)
        timer.fire()
        startButton.enabled = false
        //startButton.hidden = true
        
    }
    func startListener(){
         //run an audio listener in a concurrent thread
        if inPlaybackLoop == false{
            
        if audioRecorder == nil{
            print("audio recorder is nil")
            animImage.image = img3
                self.runRecordAudio()
            
        }else if (isRecording == false) {
            isRecording = true
            
            self.runRecordAudio()
            
        }else{
            print("either we are playing audio or listening (or boht)")
        }
        
        setupPlayer()
        playAudioWithVariablePitch(Float(speed))
        }else{
            print("in playback loop")
        }
    }
    
    func runRecordAudio(){
        
        
        print("Timer fired")
        
        // do this while there is no audio playing
        
        if audioPlayerNode.playing == false{
            
            animImage.image = img3
            
          
            var loopCt = 0
            
            //set up two inputs, one to check if there is audio, one to record it
            //listener = listening
            //audioRecorded actually records the audio for playabck
            
            audioRecorder = setupRecorder("my_audio.wav")
            listenerRecorder = setupRecorder("temp.wav")
            
            listenerRecorder.delegate = self
            listenerRecorder.meteringEnabled = true
            listenerRecorder.prepareToRecord()
            listenerRecorder.record()
            
            
            while(listenerRecorder.recording == true){
                
                //get the average input power and start recording if it hits -20 
                //I think this is decibels, but I am bad at science
                loopCt += 1
                listenerRecorder.updateMeters()
                let peak = listenerRecorder.averagePowerForChannel(0)
                // print("peak: \(peak)")
                // print("loop: \(loopCt)")
                
                
                
                if (loopCt > 20 && peak > -20 ){
                    print("Start Recording")
                    listenerRecorder.stop()
                }
                
            }
            
            print("listener stopped")
            loopCt=0
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            audioRecorder.prepareToRecord()
            
            //this records for 10 seconds. 
            //it doesn't stop automatically, so I need to fix that.
            audioRecorder.recordForDuration(10.0)
            print(" audiorecorder started")
            
            //start recirding here
            while(audioRecorder.recording == true){
                loopCt += 1
                audioRecorder.updateMeters()
                let peak = audioRecorder.averagePowerForChannel(0)
                
                //if we hit -45 dbs, then there is enough silence to to stop recording
                if (loopCt > 20 && peak < -45 ){
                    print("silence threshold met for audio Recording")
                    audioRecorder.stop()
                }
                
            }
            
            print("audio recording stopped")
            recordedAudio = RecordedAudio(filePathUrl: audioRecorder.url, title: audioRecorder.url.lastPathComponent)
           // setupPlayer()
           // playAudioWithVariablePitch(Float(speed))
            isRecording = false
            
            
        }
    }
    
    //set up the audio recorders here
    func setupRecorder( recName: String) -> AVAudioRecorder{
        var funcAudioRecorder: AVAudioRecorder!
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let recordingName = "my_audio.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        //println(filePath)
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try funcAudioRecorder = AVAudioRecorder(URL: filePath!, settings: [AVSampleRateKey: 8000.0])
        } catch _ {
            print("Error")
        }
        return funcAudioRecorder
    }
    
    
    @IBOutlet weak var animImage: UIImageView!
    
    //adjust audio as appropriate, start animation, and create concurrent thread for audio- it won't sync with the UI animation if both are on the main thread.
    func playAudioWithVariablePitch(pitch: Float){
        inPlaybackLoop = true
        animImage.stopAnimating()
        animImage.userInteractionEnabled = true
        print("stop anim 1")
        let asset = AVURLAsset(URL: audioFile.url)
        
        let secs = asset.duration.seconds
        animImage.animationRepeatCount=Int(secs*3.8)
        animImage.startAnimating()
        print("start anim 1")
        
        let priority = DISPATCH_QUEUE_PRIORITY_HIGH
        
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            self.audioPlayerNode = AVAudioPlayerNode()
            self.audioEngine.attachNode(self.audioPlayerNode)
            let changePitchEffect = AVAudioUnitTimePitch()
            changePitchEffect.pitch = pitch
            self.audioEngine.attachNode(changePitchEffect)
            if pitch == -200{
               let dist = AVAudioUnitDistortion()
                let dist2 = AVAudioUnitDistortion()
                let reverb = AVAudioUnitReverb()
                let delay = AVAudioUnitDelay()
                    
                reverb.loadFactoryPreset(AVAudioUnitReverbPreset.Plate)
                delay.feedback = 5.0
                delay.delayTime = 0.02
                delay.wetDryMix = 15.0
                reverb.wetDryMix = 90.00
                dist2.wetDryMix = 1.00
                dist2.preGain = 15
                dist.wetDryMix = 25.0
                dist.loadFactoryPreset(AVAudioUnitDistortionPreset.SpeechWaves)
                dist2.loadFactoryPreset((AVAudioUnitDistortionPreset.SpeechAlienChatter))
                changePitchEffect.pitch = -130
               
               
               self.audioEngine.attachNode(delay)
              //  self.audioEngine.connect(self.audioPlayerNode, to: delay, format: nil)
              //  self.audioEngine.connect(delay, to: self.audioEngine.outputNode, format: nil)
                
               self.audioEngine.attachNode((dist2))
               // self.audioEngine.connect(self.audioPlayerNode, to: dist2, format: nil)
               // self.audioEngine.connect(dist2, to: self.audioEngine.outputNode, format: nil)
                
                
                 //self.audioEngine.attachNode((reverb))
               //self.audioEngine.connect(self.audioPlayerNode, to: reverb, format: nil)
               //self.audioEngine.connect(reverb, to: self.audioEngine.outputNode, format: nil)
                
               self.audioEngine.attachNode(dist)
                self.audioEngine.connect(self.audioPlayerNode, to: dist, format: nil)
                self.audioEngine.connect(dist, to: delay, format:nil)
                self.audioEngine.connect(delay, to: changePitchEffect, format: nil)
            
                self.audioEngine.connect(changePitchEffect, to: self.audioEngine.outputNode, format: nil)

            }else{
            
            self.audioEngine.connect(self.audioPlayerNode, to: changePitchEffect, format: nil)
            self.audioEngine.connect(changePitchEffect, to: self.audioEngine.outputNode, format: nil)
            }
            self.audioPlayerNode.scheduleFile(self.audioFile, atTime: nil, completionHandler: nil)
            do {
                try self.audioEngine.start()
            } catch _ {
                print("Error")
            }
          
            self.audioPlayerNode.play()
                
           
            
            
            
            self.playAudio(secs)
            
        }
        
        print("duration: \(secs)")
        
        animImage.image = img3
        
        
    }
    
    //This plays the audio
    func playAudio(secs: Double){
        
        
        while(self.audioPlayerNode.playing == true ){
            var time: AVAudioTime!
            var playTime: AVAudioTime!
            time = self.audioPlayerNode.lastRenderTime
            playTime = self.audioPlayerNode.playerTimeForNodeTime(time)
            let dur = Double(playTime.sampleTime)/playTime.sampleRate
            
            
            if (dur > secs){
                self.audioPlayerNode.stop()
                self.audioPlayerNode.reset()
                self.audioEngine.stop()
                self.audioEngine.reset()
                inPlaybackLoop = false
            }
            
        }
        
    }
    
    //this will reset the audio- for future use
    func resetAudioEngineAndPlayer() {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
}

