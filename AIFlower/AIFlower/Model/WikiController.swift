//
//  WikiController.swift
//  AIFlower
//
//  Created by Matias Martinelli on 29/08/2023.
//

import Foundation

protocol WikiManagerDelegate {
    func didUpdateWiki(_ wikiManager: WikiManager, wiki: WikiModel)
    func didFailWithError(_ error: Error)
}

struct WikiManager {
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    
    var delegate: WikiManagerDelegate?
    
    
    let parameters : [String:String] = [
        "format" : "json",
        "action" : "query",
        "prop" : "extracts|pageimages",
        "exintro" : "",
        "explaintext" : "",
        "titles" : "flowerName",
        "“indexpageids”" : "",
        "redirects" : "1",
        "pithumbsize" : "500"
    ]
    
    func fetchWiki(flower: String){
        
        let urlString = "\(wikipediaURl)?format=\(parameters["format"]!)&action=\(parameters["action"]!)&prop=\(parameters["prop"]!)&pithumbsize=\(parameters["pithumbsize"]!)&exintro&explaintext&redirects=\(parameters["redirects"]!)&titles=\(flower)&indexpageids"
        
        print(urlString)
        
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String) {
        //1. create the URL
        
        if let fixedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            
            if let url = URL(string: fixedURLString) {
                
                //2. create a URLSession
                let session = URLSession(configuration: .default)
                
                //3. Give the session a task
                
                let task = session.dataTask(with: url) { data, response, error in
                    if error != nil {
                        self.delegate?.didFailWithError(error!)
                        return
                    }
                    //We cast the data as a String
                    if let safeData = data {
                        if let wiki = self.parseJSON(wikiData: safeData) {
                            self.delegate?.didUpdateWiki(self, wiki: wiki)
                        }
                    }
                }
                
                //4 Start the task
                task.resume()
            }
        }
    }
    
    func parseJSON(wikiData: Data) -> WikiModel? {
        
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WikiData.self, from: wikiData)
            let id = decodedData.query.pageids[0]
            let desc = (decodedData.query.pages[id]?.extract)!
            let flowerImageURL = (decodedData.query.pages[id]?.thumbnail.source)!
            let wiki = WikiModel(extract: desc, flowerURl: flowerImageURL)
            return wiki
            
        } catch {
            self.delegate?.didFailWithError(error)
            return nil
        }
    }
}

