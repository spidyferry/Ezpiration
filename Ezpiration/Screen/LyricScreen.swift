//
//  LyricScreen.swift
//  Ezpiration
//
//  Created by ferry sugianto on 24/06/21.
//

import UIKit
import CoreData

class LyricScreen: UIViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var records:[Records]?
    
    @IBOutlet weak var recordTtl: UILabel!
    @IBOutlet weak var lyricText: UILabel!
    @IBOutlet weak var saveButton: UIButton!

    var lyricTitle = ""
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRecords()
        saveButton.isEnabled = false
        recordTtl?.text = lyricTitle
        lyricText.text = records?[0].stt_result
    }
    
    func fetchRecords(){
        do {
            let request = Records.fetchRequest() as NSFetchRequest<Records>
            let pred = NSPredicate(format: "file_name == %@", lyricTitle)
            request.predicate = pred
            self.records = try context.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
    }
    
//    @IBAction func lyricDidEdited(_ sender: UITextField) {
//        saveButton.isEnabled = sender.text!.count > 0
//    }
}
