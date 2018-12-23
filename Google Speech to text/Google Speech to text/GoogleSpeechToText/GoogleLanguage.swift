//
//  GoogleLanguage.swift
//  Google Speech to text
//
//  Created by Satendra Singh on 22/12/18.
//  Copyright © 2018 Corebits Software solutions Pvt Ltd. All rights reserved.
//

import Foundation

struct GoogleLanguage {
    var name = ""
    var code = ""
    
    init(diction:[String:String]) {
        name = diction["name"]!
        code = diction["code"]!
    }
    
    static func supportedLanguages() ->[GoogleLanguage]{
        
        var langObjects = [GoogleLanguage]()
        
        if let langUrl  = Bundle.main.url(forResource: "GoogleLangCode", withExtension: "JSON"){
            if let data = try? Data.init(contentsOf: langUrl)
            {
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: data as Data, options: []) as! NSDictionary
                    if let langs =  jsonObj.value(forKey: "languageCodes") as? [[String:String]] {
                        // data is not null
                        
                        for lang in langs{
                            let googleLang = GoogleLanguage.init(diction: lang)
                            langObjects.append(googleLang)
                        }
                        
                    }
                } catch let error as NSError {
                    // handle error
                    print(error)
                }
                
            }
            
        }
        return langObjects
    }
    
    
}
