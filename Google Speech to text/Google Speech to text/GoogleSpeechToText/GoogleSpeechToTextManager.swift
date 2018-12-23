//
//  GoogleSpeechToTextManager.swift
//  Google Speech to text
//
//  Created by Satendra Singh on 22/12/18.
//  Copyright © 2018 Corebits Software solutions Pvt Ltd. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation

enum GoogleError: Error {
    case unknownError
    case audioFileNotExist
//    case invalidCredentials
//    case invalidRequest
//    case notFound
//    case invalidResponse
//    case serverError
//    case serverUnavailable
//    case timeOut
//    case unsuppotedURL
}

let maxAlternative = 30
let sampleRate = 16000
let recognize = "recognize"
let longrunningrecognize = "longrunningrecognize"
let serverURL = "https://speech.googleapis.com/v1/speech:"

let apiKey = "AIzaSyDYaPsebwsymReg3wy3f12Uk7BXC_4Q-t8"

class GoogleSpeechToTextManager: NSObject {

    var audioLanguage: GoogleLanguage!
    
    var punctuation:Bool = true
    var audioPath:String = ""
    var isValidPath:Bool = true
    var currentOperationName = ""
    var result:SpeechRecognitionResult?
    var googleProgress:GoogleLongProgress?
    var updateBlock: (([String:Any]?, Error?) -> Void)?
    
    func downloadContent(completionHandler: @escaping ([String:Any]?, Error?) -> Void) -> Void {
        downloadContentWithApiMethod(method: recognize) { (result, error) in
            
            let res = SpeechRecognitionResult.init(result: result ?? ["":""])
            self.result = res
            print(res.csvResult())

        }
    }

    func downloadLongContent(completionHandler: @escaping ([String:Any]?, Error?) -> Void) -> Void {
        downloadContentWithApiMethod(method: longrunningrecognize) { (result, error) in
            
            completionHandler(result,error)
            let name = result?["name"] as? String ?? ""
            self.currentOperationName = name
        }
    }

    
    func downloadContentWithApiMethod(method:String,  completionHandler: @escaping ([String:Any]?, Error?) -> Void) -> Void {
        
        let filemanager = FileManager.default
        let exist =  filemanager.fileExists(atPath: audioPath)
        if (exist == false){
            completionHandler(nil, GoogleError.audioFileNotExist)
        }
        
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        
        let audioURL = URL.init(fileURLWithPath: audioPath)
        let player = try! AVAudioPlayer(contentsOf: audioURL)
        
        let sampleRate = player.format.sampleRate
        let encoding = player.format.settings
        print("settings\(encoding)")
        print("sample:\(sampleRate)")
        
        let urlString = serverURL + "\(method)" + "?key=\(apiKey)";
        print("url string is \(urlString)")
        let url = URL(string: urlString)!
        
        var request =  URLRequest(url: url)
        //        request.url = url
        
        let audioData = try? Data.init(contentsOf:audioURL)
        let configRequest = ["encoding": "LINEAR16", "sampleRateHertz": sampleRate, "languageCode": audioLanguage.code, "maxAlternatives": 1, "enableWordTimeOffsets": true] as [String : Any]
        let audioRequest = ["content": audioData?.base64EncodedString(options: []) ?? ""]
        let requestDictionary = ["config": configRequest, "audio": audioRequest]
        let requestData = try? JSONSerialization.data(withJSONObject: requestDictionary, options: [])
        
        request.httpMethod = "POST"
        request.timeoutInterval = 120
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        let contentType = "application/json"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        request.httpBody  = requestData
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                completionHandler(json,nil)
            } catch {
                completionHandler(nil,error)
                
                print("error")
            }
        })
        
        task.resume()
        
    }
    
    
    func hitApiForOperationStatus(progress: (([String:Any]?, Error?) -> Void)?) -> Void {
        if let block = progress {
            
            updateBlock = block

        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            
            // Put your code which should be executed with a delay here
            let urlString = "https://speech.googleapis.com/v1/operations/\(self.currentOperationName)" + "?key=\(apiKey)";
            
            var request = URLRequest(url: URL(string: urlString)!)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    print(json)
                    let res = GoogleLongProgress.init(result: json)
                    self.googleProgress = res
                    self.updateBlock?(json,error)
                } catch {
                    self.updateBlock?(nil,error)
                    print("error")
                }
                
                if(self.googleProgress?.metadata.progressPercent != 100.0){ //Recursive executing
                    
                    self.hitApiForOperationStatus(progress: nil)
                    
                }
            }).resume()
            
        })
        
    }
    
}

