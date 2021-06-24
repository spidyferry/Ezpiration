//
//  LyricScreen.swift
//  Ezpiration
//
//  Created by ferry sugianto on 24/06/21.
//

import UIKit
import CoreData

class LyricScreen: UIViewController {
    
    @IBOutlet weak var recordTtl: UILabel!
    var lyricTitle = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        print(lyricTitle)
        recordTtl?.text = lyricTitle
    }
}
