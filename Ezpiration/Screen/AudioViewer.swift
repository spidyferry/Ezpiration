//
//  AudioViewer.swift
//  Ezpiration
//
//  Created by ferry sugianto on 24/06/21.
//

import UIKit

class AudioViewer: UIViewController {
    
    @IBOutlet weak var recordTtl: UILabel!
    @IBOutlet weak var lyricButton: UIButton!
    
    var recordTitle = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        lyricButton.layer.cornerRadius = 10
        recordTtl.text = recordTitle
        // Do any additional setup after loading the view.
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
