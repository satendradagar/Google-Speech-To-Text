//
//  GoogleLongSpeechManager.swift
//  Google Speech to text
//
//  Created by Satendra Singh on 23/12/18.
//  Copyright © 2018 Corebits Software solutions Pvt Ltd. All rights reserved.
//


import Foundation
import Cocoa
import AVFoundation

class GoogleLongSpeechManager: NSObject {
    
    var audioLanguage: GoogleLanguage!
    
    var punctuation:Bool = true
    var audioPath:String = ""
    var isValidPath:Bool = true
    
    var result:SpeechRecognitionResult?
    
    func downloadContent(completionHandler: @escaping ([String]?, Error?) -> Void) -> Void {
        
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
        
        //
        //         let params = ["username":"username", "provider":"walkingcoin", "securityQuestion":"securityQuestionField.text!", "securityAnswer":"securityAnswerField.text!"] as Dictionary<String, AnyObject>
        
        let urlString = serverURL + "?key=\(apiKey)";
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
        
        //         request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody  = requestData
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response)
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
                let res = SpeechRecognitionResult.init(result: json)
                self.result = res
                print(res.csvResult())
                completionHandler(nil,nil)
            } catch {
                completionHandler(nil,error)
                
                print("error")
            }
        })
        
        task.resume()
        
        //        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
        /*
         let data: NSData?, let response: NSURLResponse?, let error: NSError?) -> Void in
         // 1: Check HTTP Response for successful GET request
         guard let httpResponse = response as? NSHTTPURLResponse, receivedData = data
         else {
         print("error: not a valid http response")
         return
         }
         
         switch (httpResponse.statusCode)
         {
         case 200:
         
         let response = NSString (data: receivedData, encoding: NSUTF8StringEncoding)
         
         
         if response == "SUCCESS"
         {
         
         }
         
         default:
         print("save profile POST request got response \(httpResponse.statusCode)")
         }
         }
         */
        //        })
        
    }
    
}

