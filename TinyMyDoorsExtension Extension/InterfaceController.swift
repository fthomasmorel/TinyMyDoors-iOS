//
//  InterfaceController.swift
//  TinyMyDoorsExtension Extension
//
//  Created by Florent THOMAS-MOREL on 12/22/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire
import WatchConnectivity

enum Status {
    case open
    case close
    case unkown
    case loading
}

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var imageView: WKInterfaceImage!
    @IBOutlet var actionLabel: WKInterfaceLabel!
    
    var status: Status = .loading
    var timer = Timer()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let watchSession = WCSession.default()
        watchSession.delegate = self
        watchSession.activate()
    }
    
    override func willActivate() {
        super.willActivate()
        self.updateUI()
        self.fetchDoorStatus()
        timer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(InterfaceController.fetchDoorStatus), userInfo: nil, repeats: true)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func fetchDoorStatus(){
        guard let token = UserDefaults.standard.object(forKey: "authorization") as? String else { return }
        let headers = [ "authorization" : token]
        let _ = Alamofire.request("https://mydoors.thomasmorel.io/status", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseString { response in
            if let result = String(data: response.data!, encoding: String.Encoding.utf8){
                self.updateStatus(status: result)
            }else{
                self.updateStatus(status: "")
            }
            self.updateUI()
        }
    }
    
    func updateStatus(status: String){
        switch status {
        case "close":
            self.status = .close
        case "open":
            self.status = .open
        default:
            self.status = .loading
        }
    }
    
    func updateUI(){
        switch self.status {
        case .close:
            self.actionLabel.setText("Force Touch\nto Open")
            self.imageView.setImage(#imageLiteral(resourceName: "close"))
            self.imageView.setHidden(false)
        case .open:
            self.actionLabel.setText("Force Touch\nto Close")
            self.imageView.setImage(#imageLiteral(resourceName: "open"))
            self.imageView.setHidden(false)
        case .unkown:
            self.imageView.setHidden(true)
            self.actionLabel.setText("Cannot connect 😩")
        default:
            self.imageView.setHidden(true)
            self.actionLabel.setText("Loading...")
        }
    }
    
    @IBAction func sendCommandAction() {
        guard let token = UserDefaults.standard.object(forKey: "authorization") as? String else { return }
        self.status = .loading
        self.updateUI()
        let headers = [ "authorization" : token ]
        let _ = Alamofire.request("https://mydoors.thomasmorel.io/action", method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseString { response in
            self.fetchDoorStatus()
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let token = applicationContext["authorization"] as? String {
            UserDefaults.standard.set(token, forKey: "authorization")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?){
        
    }

}
