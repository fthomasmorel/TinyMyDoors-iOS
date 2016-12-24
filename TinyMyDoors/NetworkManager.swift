//
//  NetworkManager.swift
//  TinyMyDoors
//
//  Created by Florent THOMAS-MOREL on 12/22/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager: AnyObject {
    
    func fetchDoorStatus(completion: @escaping (Status) -> ()){
        guard let token = UserDefaults.standard.object(forKey: "authorization") as? String else { completion(.loading) ; return }
        let headers = [ "authorization" : token ]
        let _ = Alamofire.request("https://mydoors.thomasmorel.io/status", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseString { response in
            if let result = String(data: response.data!, encoding: String.Encoding.utf8){
                if result == "open" {
                    completion(.open)
                }else if result == "close" {
                    completion(.close)
                }else{
                    completion(.unkown)
                }
            }else{
                completion(.unkown)
            }
        }
    }
    
    func triggerDoor(completion: @escaping (Status) -> ()){
        guard let token = UserDefaults.standard.object(forKey: "authorization") as? String else { completion(.loading) ; return }
        let headers = [ "authorization" : token ]
        let _ = Alamofire.request("https://mydoors.thomasmorel.io/action", method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseString { response in
            if let result = String(data: response.data!, encoding: String.Encoding.utf8){
                if result == "open" {
                    completion(.open)
                }else if result == "close" {
                    completion(.close)
                }else{
                    completion(.unkown)
                }
            }else{
                completion(.unkown)
            }
        }
    }
    
    func updateNotificationToken(oldToken: String, newToken: String){
        guard let token = UserDefaults.standard.object(forKey: "authorization") as? String else { return }
        let headers = [ "authorization" : token ]
        let parameters = [ "old_token" : oldToken, "new_token" : newToken ]
        Alamofire.request("https://mydoors.thomasmorel.io/notification", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { (_) in }
    }
    
}
