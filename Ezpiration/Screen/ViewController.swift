//
//  ViewController.swift
//  Ezpiration
//
//  Created by ferry sugianto on 22/06/21.
//

import UIKit
import CoreData
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var records:[Records]?
    var newRecordName = ""
    var newRecordDate = Date()

    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var borderBtn: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableInspirations: UITableView!
    
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
    
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode

        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                // Update the text view with the results.
                isFinal = result.isFinal
                print("Text \(result.bestTranscription.formattedString)")
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }

        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
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
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }else {
            do {
                try startRecording()
            } catch {
                print(error.localizedDescription)
            }
        }
        
        if (recordBtn.title(for: .normal) == "Record"){
            let date = Date()
            let format = DateFormatter()
            format.dateFormat = "ddMMyy-HHmmss"
            let formattedDate = format.string(from: date)
            newRecordName = "Inspiration \(formattedDate)"
            newRecordDate = date
            recordBtn.layer.cornerRadius = 10
            recordBtn.setTitle("Stop", for: .normal)
        } else {
            recordBtn.layer.cornerRadius = 40
            self.recordBtn.setTitle("Record", for: .normal)
            
            //ini yang dimasukin ke core data
            let newRecords = Records(context: self.context)
            newRecords.file_name = newRecordName
            newRecords.date = newRecordDate
            do{
                try self.context.save()
            }catch{
                print("sapi \(error.localizedDescription)")
            }
            self.fetchRecords()
        }
    }
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordBtn.isEnabled = true
        } else {
            recordBtn.isEnabled = false
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
            let date = Date()
            let format = DateFormatter()
            format.dateFormat = "dd-MM-yyyy"
            let formattedDate = format.string(from: date)
            cell.dateRecord.text = formattedDate
//            cell.dateRecord.text = ("\(String(describing: files?.date))")
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "") { (action, view, completionHandler) in
            let recordToRemove = self.records![indexPath.row]
            self.context.delete(recordToRemove)
            do{
                try self.context.save()
            }catch{
                print(error.localizedDescription)
            }
            self.fetchRecords()
        }
        delete.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //buat segue aja untuk open view controller sebelah
    }
    
    
}

