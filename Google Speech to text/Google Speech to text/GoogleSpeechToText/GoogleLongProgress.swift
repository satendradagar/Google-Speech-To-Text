//
//  GoogleLongProgress.swift
//  Google Speech to text
//
//  Created by Satendra Singh on 23/12/18.
//  Copyright © 2018 Corebits Software solutions Pvt Ltd. All rights reserved.
//
/*
 ["response": {
 "@type" = "type.googleapis.com/google.cloud.speech.v1.LongRunningRecognizeResponse";
 results =     (
 {
 alternatives =             (
 {
 confidence = "0.9352997";
 transcript = "Once Upon a Time nestled deep in a woodland forest layer beautiful quaint Cottage that was painted the most British eighth of rent and was home until a young girl named Ruby";
 words =                     (
 {
 endTime = "0.800s";
 startTime = "0.100s";
 word = Once;
 },
 {
 endTime = "1.100s";
 startTime = "0.800s";
 word = Upon;
 },
 {
 endTime = "1.200s";
 startTime = "1.100s";
 word = a;
 },
 {
 endTime = "1.300s";
 startTime = "1.200s";
 word = Time;
 },
 {
 endTime = "2.500s";
 startTime = "1.300s";
 word = nestled;
 },
 {
 endTime = "2.700s";
 startTime = "2.500s";
 word = deep;
 },
 {
 endTime = 3s;
 startTime = "2.700s";
 word = in;
 },
 {
 endTime = "3.100s";
 startTime = 3s;
 word = a;
 },
 {
 endTime = "3.500s";
 startTime = "3.100s";
 word = woodland;
 },
 {
 endTime = "3.600s";
 startTime = "3.500s";
 word = forest;
 },
 {
 endTime = "4.900s";
 startTime = "3.600s";
 word = layer;
 },
 {
 endTime = "5.500s";
 startTime = "4.900s";
 word = beautiful;
 },
 {
 endTime = "5.900s";
 startTime = "5.500s";
 word = quaint;
 },
 {
 endTime = "6.300s";
 startTime = "5.900s";
 word = Cottage;
 },
 {
 endTime = "6.800s";
 startTime = "6.300s";
 word = that;
 },
 {
 endTime = 7s;
 startTime = "6.800s";
 word = was;
 },
 {
 endTime = "7.400s";
 startTime = 7s;
 word = painted;
 },
 {
 endTime = "7.600s";
 startTime = "7.400s";
 word = the;
 },
 {
 endTime = "7.800s";
 startTime = "7.600s";
 word = most;
 },
 {
 endTime = "8.400s";
 startTime = "7.800s";
 word = British;
 },
 {
 endTime = "8.800s";
 startTime = "8.400s";
 word = eighth;
 },
 {
 endTime = "8.900s";
 startTime = "8.800s";
 word = of;
 },
 {
 endTime = "9.400s";
 startTime = "8.900s";
 word = rent;
 },
 {
 endTime = "10.100s";
 startTime = "9.400s";
 word = and;
 },
 {
 endTime = "10.300s";
 startTime = "10.100s";
 word = was;
 },
 {
 endTime = "10.800s";
 startTime = "10.300s";
 word = home;
 },
 {
 endTime = "11.100s";
 startTime = "10.800s";
 word = until;
 },
 {
 endTime = "11.200s";
 startTime = "11.100s";
 word = a;
 },
 {
 endTime = "11.300s";
 startTime = "11.200s";
 word = young;
 },
 {
 endTime = "11.900s";
 startTime = "11.300s";
 word = girl;
 },
 {
 endTime = "12.900s";
 startTime = "11.900s";
 word = named;
 },
 {
 endTime = "13.200s";
 startTime = "12.900s";
 word = Ruby;
 }
 );
 }
 );
 }
 );
 }, "metadata": {
 "@type" = "type.googleapis.com/google.cloud.speech.v1.LongRunningRecognizeMetadata";
 lastUpdateTime = "2018-12-23T10:18:14.551308Z";
 progressPercent = 100;
 startTime = "2018-12-23T10:18:08.669645Z";
 }, "name": 3321915102923759674, "done": 1]
 */
import Foundation


struct GoogleLongProgress {
    
    var metadata: GoogleLongProgressMeta
    var response: SpeechRecognitionResult?
    
    init(result:[String:Any]) {
          let metaJSON = result["metadata"] as? [String:Any] ?? ["":""]
        let meta = GoogleLongProgressMeta.init(result: metaJSON)
        metadata = meta
        if metadata.progressPercent == 100.0 {
            let responseJSON = result["response"] as? [String:Any] ?? ["":""]
           response = SpeechRecognitionResult.init(result: responseJSON)
        }
    }
}


struct GoogleLongProgressMeta {
    
    var name = ""
    var progressPercent = 0.0
    var transcript = ""
    var done = false
    
    init(result:[String:Any]) {
        name = result["name"] as? String ?? "0.0"
        progressPercent = result["progressPercent"] as? Double ?? 0.0
        done = result["done"] as? Bool ?? false
    }
}
