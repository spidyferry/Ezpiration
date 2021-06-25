//
//  ViewController.swift
//  Ezpiration
//
//  Created by ferry sugianto on 22/06/21.
//

import UIKit
import CoreData
import Speech
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, SFSpeechRecognizerDelegate {
    
    var soundRecorder : AVAudioRecorder!
    var fileName : String = "temp.mp4"
    var audio : [URL] = []
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "id_ID"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var records:[Records]?
    var newRecordName = ""
    var newRecordDate = Date()
    var newRecordStt = ""

    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var borderBtn: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableInspirations: UITableView!
    
    var alert : UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.systemOrange
        
        setupRecorder()
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
    
    func getDocumentDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    func setupRecorder(){
        let audioFileName = getDocumentDirectory().appendingPathComponent(fileName)
        let recordingSetting = [AVFormatIDKey : kAudioFormatAppleLossless, AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue, AVEncoderBitRateKey : 320000, AVNumberOfChannelsKey : 2, AVSampleRateKey : 44100.2] as [String : Any]
        do {
            soundRecorder = try AVAudioRecorder(url: audioFileName, settings: recordingSetting)
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
        } catch {
            print(error)
        }
    }
    
    private func startRecording() throws {
        
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                isFinal = result.isFinal
//                print("Text \(result.bestTranscription.formattedString)")
                self.newRecordStt = result.bestTranscription.formattedString
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }

        // setup mic untuk record
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
            
            soundRecorder.record()
            
            let date = Date()
            let format = DateFormatter()
            format.dateFormat = "ddMMyy-HHmmss"
            let formattedDate = format.string(from: date)
            newRecordName = "Inspiration_\(formattedDate)"
            newRecordDate = date
            
            recordBtn.layer.cornerRadius = 10
            recordBtn.setTitle("Stop", for: .normal)
        } else {
            soundRecorder.stop()
            
            recordBtn.layer.cornerRadius = 40
            self.recordBtn.setTitle("Record", for: .normal)
            
            //ini yang dimasukin ke core data
            let newRecords = Records(context: self.context)
            newRecords.file_name = newRecordName
            newRecords.date = newRecordDate
            newRecords.stt_result = newRecordStt
            do{
                try self.context.save()
            }catch{
                print("sapi \(error.localizedDescription)")
            }
            self.fetchRecords()

            var url = getDocumentDirectory().appendingPathComponent(fileName)
            var rv = URLResourceValues()
            rv.name = newRecordName
            do{
                try url.setResourceValues(rv)
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder : AVAudioRecorder, successfully flag : Bool) {
        return
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
        let files = self.records![indexPath.row]
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AudioViewer") as! AudioViewer
        self.navigationController?.pushViewController(vc, animated: true)
        vc.recordTitle = "\(files.file_name!)"
    }
    
}

