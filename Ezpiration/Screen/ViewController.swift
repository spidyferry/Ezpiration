//
//  ViewController.swift
//  Ezpiration
//
//  Created by ferry sugianto on 22/06/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var records:[Records]?
    var newRecordName = ""

    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var borderBtn: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableInspirations: UITableView!
    
//    let filename = ["All by Myself" /*, "aku", "suka", "Tahu", "Mamih", ""*/]
//    let date = ["21 April 2021"/*, "29 February 2021", "01 January 2021", "", "", ""*/]
//    let tag = ["love"/*, "hate", "friendship", "", "", ""*/]
    
    var alert : UIAlertController?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRecords()
        
        recordBtn.layer.cornerRadius = 40
        borderBtn.layer.cornerRadius = 60
        borderBtn.layer.borderColor = UIColor.systemGray.cgColor
        borderBtn.layer.borderWidth = 0.5
        
        navigationBar.standardAppearance.configureWithTransparentBackground()
        
        self.tableInspirations.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableInspirations.rowHeight = 92
        self.tableInspirations.delegate = self
        self.tableInspirations.dataSource = self
        self.tableInspirations.separatorStyle = .none
        
    }
    
    func fetchRecords(){
        do {
            self.records = try context.fetch(Records.fetchRequest())
            DispatchQueue.main.async {
                self.tableInspirations.reloadData()
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        alert?.actions[1].isEnabled = sender.text!.count > 0
    }
    
    @IBAction func alertRecordingName(_ sender: Any) {
        if (recordBtn.title(for: .normal) == "Record"){
            alert = UIAlertController(title: "Ezpiration Title", message: "Please type your inspiration title here.", preferredStyle: .alert)
            alert?.addTextField(configurationHandler: { (textField) -> Void in
                textField.placeholder = "Title"
                textField.keyboardType = UIKeyboardType.emailAddress // Just to select one
                textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
            })

            let yesAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                let textField = self.alert?.textFields![0]
                let date = Date()
                let format = DateFormatter()
                format.dateFormat = "dd-MM-yyyy"
                let formattedDate = format.string(from: date)
                self.newRecordName = (textField?.text)!
                print(formattedDate)
                print(textField?.text)
                self.recordBtn.layer.cornerRadius = 10
                self.recordBtn.setTitle("Stop", for: .normal)
                // disini panggil function speech to text
            })

            alert?.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

            yesAction.isEnabled = false
            alert?.addAction(yesAction)

            self.present(alert!, animated: true, completion: nil)
        }else{
            recordBtn.layer.cornerRadius = 40
            self.recordBtn.setTitle("Record", for: .normal)
            
            //ini yang dimasukin ke core data
            let newRecords = Records(context: self.context)
            newRecords.file_name = newRecordName
            do{
                try self.context.save()
            }catch{
                print(error.localizedDescription)
            }
            self.fetchRecords()
        }
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.records?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell{
            let files = self.records?[indexPath.row]
            // ambil data dari tabel records
            cell.labelTest.text = files?.file_name
//            cell.dateRecord.text = files?.date
            
//            cell.labelTest.text = self.filename[indexPath.row]
//            cell.dateRecord.text = self.date[indexPath.row]
//            cell.recordingTag.setTitle(self.tag[indexPath.row], for: .normal)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            let recordToRemove = self.records![indexPath.row]
            self.context.delete(recordToRemove)
            do{
                try self.context.save()
            }catch{
                print(error.localizedDescription)
            }
            self.fetchRecords()
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = self.records![indexPath.row]
        
        alert = UIAlertController(title: "Edit Title", message: "Do you want to edit your title?", preferredStyle: .alert)
        alert?.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Title"
            textField.keyboardType = UIKeyboardType.emailAddress // Just to select one
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        })
        
        let textField = self.alert?.textFields![0]
        textField?.text = record.file_name

        let yesAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            let textField = self.alert?.textFields![0]
            record.file_name = textField?.text
            do{
                try self.context.save()
            }catch{
                print(error.localizedDescription)
            }
            self.fetchRecords()
        })

        alert?.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

        yesAction.isEnabled = false
        alert?.addAction(yesAction)

        self.present(alert!, animated: true, completion: nil)
    }
    
}

