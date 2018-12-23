//
//  GoogleSpeechResult.swift
//  Google Speech to text
//
//  Created by Satendra Singh on 22/12/18.
//  Copyright © 2018 Corebits Software solutions Pvt Ltd. All rights reserved.
//

import Foundation

struct SpeechRecognitionResult{
    
    var alternatives :[SpeechRecognitionAlternative]?
    
    
    init(result:[String:Any]) {
        let res = result["results"] as? [Any]
        let firstRes = res?.first as? [String:Any]
        let alts = firstRes?["alternatives"] as? [[String:Any]] ?? [["":""]]
        var alternavs = [SpeechRecognitionAlternative]()
        for alt in alts{
            let parsed = SpeechRecognitionAlternative.init(result: alt)
            alternavs.append(parsed)
        }
        alternatives = alternavs
    }

    func csvResult() -> String {
        
//        var csvRes = "\("Transscript"),\("Confidence")\n"
//        if let alts = alternatives {
//            for alt in alts {
//                csvRes = csvRes + alt.csvResult()
//            }
//        }
        return alternatives?.first?.csvResult() ?? ""
        
    }

}

struct SpeechRecognitionAlternative {
    
    var transcript = ""
    var confidence = 0.0
    var words = [SpeechWord]()
    
    init(result:[String:Any]) {
        transcript = result["transcript"] as? String ?? ""
        confidence = result["confidence"] as? Double ?? 0.0
        
        let apiWords = result["words"] as? [[String:Any]] ?? [["":""]]
        for wor in apiWords{
            let word = SpeechWord.init(result: wor)
            words.append(word)
        }

        
    }
    
    func csvResult() -> String {
        
//        return "\(transcript),\(confidence)\n"
        var csvRes = "\("Transscript"),\("Start"),\("End")\n"
            for word in words {
                csvRes = csvRes + word.csvResult()
            }
        return csvRes
    }
}



struct SpeechWord {
    
    var startTime = "0.0"
    var endTime = "0.0"
    var transcript = ""
    
    init(result:[String:Any]) {
        startTime = result["startTime"] as? String ?? "0.0"
        endTime = result["endTime"] as? String ?? "0.0"
        transcript = result["word"] as? String ?? ""
    }
    
    func csvResult() -> String {
        
        return "\(transcript),\(startTime.dropLast()),\(endTime.dropLast())\n"
        
    }
}
