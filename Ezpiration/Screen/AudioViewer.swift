//
//  AudioViewer.swift
//  Ezpiration
//
//  Created by ferry sugianto on 24/06/21.
//

import UIKit
import AVFoundation

class AudioViewer: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var recordTtl: UILabel!
    @IBOutlet weak var lyricButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var soundPlayer : AVAudioPlayer!
    var recordTitle = ""
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        lyricButton.layer.cornerRadius = 10
        recordTtl.text = recordTitle
        // Do any additional setup after loading the view.
    }
    
    func getDocumentDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    func setupPlayer(){
        let audioFilename = getDocumentDirectory().appendingPathComponent(recordTitle)
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
        } catch {
            print(error)
        }
    }
    
    @IBAction func playAudio(_ sender: Any) {
        if playButton.titleLabel?.text == "Play"{
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//            print("aku adalah lokasi file : \(path)")
            playButton.setTitle("Stop", for: .normal)
            setupPlayer()
            soundPlayer.play()
        }else{
            soundPlayer.stop()
            playButton.setTitle("Play", for: .normal)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ recorder : AVAudioPlayer, successfully flag : Bool) {
        playButton.setTitle("Play", for: .normal)
    }
    
    @IBAction func lyricPopUp(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is LyricScreen {
            let vc = segue.destination as? LyricScreen
            vc?.lyricTitle = recordTitle
        }
    }

    
}
