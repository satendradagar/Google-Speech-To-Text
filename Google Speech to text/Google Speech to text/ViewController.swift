//
//  ViewController.swift
//  Google Speech to text
//
//  Created by Satendra Singh on 22/12/18.
//  Copyright © 2018 Corebits Software solutions Pvt Ltd. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var audioButton: NSButton!
    @IBOutlet weak var audioPathFiled: NSTextField!
    @IBOutlet weak var languageMenu: NSPopUpButton!
    @IBOutlet weak var punctuationCheck: NSButton!
    @IBOutlet weak var generateCSVButton: NSButton!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var downloadCSVButton: NSButton!
    
    let speechManager = GoogleSpeechToTextManager()
    let langs = GoogleLanguage.supportedLanguages()

    override func viewDidLoad() {
        super.viewDidLoad()
//        print(langs.debugDescription)
        languageMenu.menu?.removeAllItems()
        for lang in langs {
            
            languageMenu.addItem(withTitle: lang.name)
        }
        speechManager.audioLanguage = langs[0]
        configureNormalState()
        // Do any additional setup after loading the view.
    }

    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func configureNormalState() -> Void {
        audioButton.isEnabled = true
        languageMenu.isEnabled = true
        punctuationCheck.isEnabled = true
        generateCSVButton.isEnabled = true
        progressBar.isHidden = true
        downloadCSVButton.isEnabled = false
    }

    func configureProceesingState() -> Void {
        audioButton.isEnabled = false
        languageMenu.isEnabled = true
        punctuationCheck.isEnabled = true
        generateCSVButton.isEnabled = false
        progressBar.isHidden = false
        progressBar.startAnimation(nil)
        downloadCSVButton.isEnabled = false

    }


    func configureResultState() -> Void {
        audioButton.isEnabled = true
        languageMenu.isEnabled = true
        punctuationCheck.isEnabled = true
        generateCSVButton.isEnabled = true
        progressBar.isHidden = true
        downloadCSVButton.isEnabled = true
        progressBar.stopAnimation(nil)


    }
    

    @IBAction func selectAudioAction(_ sender: Any) {
        
        print("openDocument ViewController")
        if let url = NSOpenPanel().selectUrl {
            speechManager.audioPath = url.path
            audioPathFiled.stringValue = speechManager.audioPath
            print("file selected:", url.path)
        } else {
            print("file selection was canceled")
        }
        
    }
    
    @IBAction func languageDidChanged(_ sender: NSPopUpButton) {
     
        speechManager.audioLanguage = langs[languageMenu.indexOfSelectedItem]

    }
    
    @IBAction func punctuationCheckAction(_ sender: Any) {
        speechManager.punctuation = (punctuationCheck.state == .on)
    }
    
    @IBAction func generateCSVAction(_ sender: Any) {
        self.configureProceesingState()
//        speechManager.downloadContent { (results, error) in
//            print(results)
//            DispatchQueue.main.async {
//                self.configureResultState()
//                if let err = error{
//                    NSApp.presentError(err)
//                }
//            }
//            print(error)
//        }
        speechManager.downloadLongContent { (result, error) in
            DispatchQueue.main.async {
                if let err = error{
                    self.configureNormalState()
                    NSApp.presentError(err)
                }
                else{
                    self.speechManager.hitApiForOperationStatus { (progrees, error) in
                        print("Porogress:\(String(describing: self.speechManager.googleProgress?.metadata.progressPercent))")
                        DispatchQueue.main.async {
//                            self.progressBar.doubleValue = self.speechManager.googleProgress?.metadata.progressPercent ?? 0.0
                           if (100 == self.speechManager.googleProgress?.metadata.progressPercent )
                           {
                            self.configureResultState()
                            }
                            
                        }
                    }

                }

            }

        }
    }
    
    func startProgressUpdate() -> Void {
        
        speechManager.hitApiForOperationStatus { (progress, error) in
            
            print("Progress:\(self.speechManager.googleProgress?.metadata.progressPercent)")
            
        }
        
    }
    
    @IBAction func downloadCSVAction(_ sender: Any) {
        // 1
        guard let window = view.window else { return }
        guard let selectedItem = speechManager.googleProgress?.response else { return }
        
        // 2
        let panel = NSSavePanel()
        // 3
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        // 4
        panel.nameFieldStringValue = "results.csv"
        
        // 5
        
        panel.beginSheetModal(for: window) { (result) in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue,
                let url = panel.url {
                // 6
                do {
                    let infoAsText = self.speechManager.googleProgress?.response?.csvResult()
                    try infoAsText?.write(to: url, atomically: true, encoding: .utf8)
                } catch {
                    NSApp.presentError(error)
//                    self.showErrorDialogIn(window: window,
//                                           title: "Unable to save file",
//                                           message: error.localizedDescription)
                }
            }
        }
    }
    

}

extension NSOpenPanel {
    var selectUrl: URL? {
        title = "Select Audio"
        allowsMultipleSelection = false
        canChooseDirectories = false
        canChooseFiles = true
        canCreateDirectories = false
        allowedFileTypes = ["mp3","caf","aiff","wav"]  // to allow only images, just comment out this line to allow any file type to be selected
        return runModal() == .OK ? urls.first : nil
    }
    var selectUrls: [URL]? {
        title = "Select Audio"
        allowsMultipleSelection = true
        canChooseDirectories = false
        canChooseFiles = true
        canCreateDirectories = false
        allowedFileTypes = ["mp3","caf","aiff","wav"]  // to allow only images, just comment out this line to allow any file type to be selected
        return runModal() == .OK ? urls : nil
    }
}
