//
//  ViewController.swift
//  TinyMyDoors
//
//  Created by Florent THOMAS-MOREL on 12/22/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import UIKit
import BSQRCodeReader
import UserNotifications
import WatchConnectivity

let kOrangeColor = UIColor(colorLiteralRed: 251/255, green: 140/255, blue: 0, alpha: 1)
let kGreenColor = UIColor(colorLiteralRed: 158/255, green: 202/255, blue: 87/255, alpha: 1)
let kGrayColor = UIColor(colorLiteralRed: 235/255, green: 235/255, blue: 241/255, alpha: 1)


enum Status {
    case open
    case close
    case unkown
    case loading
}

class ViewController: UIViewController, CAAnimationDelegate, WCSessionDelegate, BSQRCodeReaderDelegate {
    
    @IBOutlet weak var contentTopView: UIView!
    @IBOutlet weak var contentStatusView: UIView!
    @IBOutlet weak var contentTriggerView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var portailLabel: UILabel!
    @IBOutlet weak var statusLoader: UIActivityIndicatorView!
    @IBOutlet weak var actionLoader: UIActivityIndicatorView!
    @IBOutlet weak var reader: BSQRCodeReader!
    
    var drawAnimation:CABasicAnimation!
    var circle:CAShapeLayer!
    var status: Status = .loading
    var networkManager = NetworkManager()
    var timer = Timer()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.contentStatusView.layer.cornerRadius = 10
        self.contentStatusView.layer.masksToBounds = true
        self.contentTriggerView.layer.cornerRadius = 10
        self.contentTriggerView.layer.masksToBounds = true
        
        self.button.addTarget(self, action: #selector(ViewController.startCircleAnimation), for: UIControlEvents.touchDown)
        self.button.addTarget(self, action: #selector(ViewController.endCircleAnimation), for: UIControlEvents.touchUpInside)
        self.initView()
        self.updateView(status: .loading)
        self.reader.delegate = self
    }

    
    override func viewWillAppear(_ animated: Bool) {
        if let _ = UserDefaults.standard.object(forKey: "authorization") as? String {
            self.initContext()
        }else{
            self.reader.isHidden = false
            self.reader.startScanning()
        }
    }
    
    func initContext(){
        self.reader.isHidden = true
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in }
        UIApplication.shared.registerForRemoteNotifications()
        
        if WCSession.isSupported() {
            let watchSession = WCSession.default()
            watchSession.delegate = self
            watchSession.activate()
        }
        self.timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(ViewController.fetchStatus), userInfo: nil, repeats: true)

    }
    
    func fetchStatus(){
        self.networkManager.fetchDoorStatus { (status) in
            self.updateView(status: status)
        }
    }
    
    func triggerDoor(){
        self.networkManager.triggerDoor { (status) in
            self.updateView(status: status)
        }
    }
    
    func initView(){
        let radius = CGFloat(self.button.frame.width/2-13)
        self.circle = CAShapeLayer()
        let bezier:UIBezierPath = (UIBezierPath(roundedRect: (rect: CGRect(x: 0, y: 0, width: 2*radius, height: 2*radius)), cornerRadius: radius))
        self.circle.path = bezier.cgPath
        let x = (self.button.frame.midX-radius)
        let y = (self.button.frame.midY-radius)
        self.circle.position = CGPoint(x: x,y: y)
        self.circle.fillColor = UIColor.clear.cgColor;
        self.circle.lineWidth = 27;
        self.circle.strokeEnd = 0.0;
        self.circle.strokeColor = self.button.titleLabel?.textColor.cgColor;
        self.contentTriggerView.layer.addSublayer(self.circle);
    }
    
    func updateView(status: Status){
        switch status {
        case .open:
            self.statusLabel.text = "Ouvert"
            self.statusLabel.textColor = kGreenColor
            self.contentTopView.backgroundColor = kGreenColor
            self.button.setTitle("Fermer", for: .normal)
            self.button.setTitleColor(kOrangeColor, for: .normal)
            self.statusLoader.isHidden = true
            self.actionLoader.isHidden = true
            self.statusLabel.isHidden = false
            self.portailLabel.isHidden = false
            self.button.isHidden = false
            break
        case .close:
            self.statusLabel.text = "Fermé"
            self.statusLabel.textColor = kOrangeColor
            self.contentTopView.backgroundColor = kOrangeColor
            self.button.setTitle("Ouvrir", for: .normal)
            self.button.setTitleColor(kGreenColor, for: .normal)
            self.statusLoader.isHidden = true
            self.actionLoader.isHidden = true
            self.button.isHidden = false
            self.statusLabel.isHidden = false
            self.portailLabel.isHidden = false
            break
        case .loading:
            self.statusLabel.text = "..."
            self.statusLabel.textColor = kGreenColor
            self.contentTopView.backgroundColor = kGrayColor
            self.button.setTitle("Ouvrir", for: .normal)
            self.button.setTitleColor(kGreenColor, for: .normal)
            self.statusLoader.isHidden = false
            self.actionLoader.isHidden = false
            self.button.isHidden = true
            self.statusLabel.isHidden = true
            self.portailLabel.isHidden = true
            break
        default:
            
            break
        }
        self.circle.strokeColor = self.button.titleLabel?.textColor.cgColor;
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.triggerDoor()
        }
    }

    func circleAnimation(){
        self.drawAnimation = CABasicAnimation(keyPath:"strokeEnd")
        self.drawAnimation.duration            = 1.0;
        self.drawAnimation.repeatCount         = 1.0;
        self.drawAnimation.fromValue = NSNumber(value: 0 as Float)
        self.drawAnimation.toValue   = NSNumber(value: 1 as Float)
        self.drawAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.drawAnimation.delegate = self
        self.circle.add(self.drawAnimation, forKey:"draw")
    }
    
    func startCircleAnimation(){
        self.circleAnimation()
    }
    
    func endCircleAnimation(){
        self.circle.removeAllAnimations()
        self.circle.removeFromSuperlayer()
        self.initView()
    }
    
    func didCaptureQRCodeWithContent(_ content: String) -> Bool{
        let contents = content.components(separatedBy: ";")
        if contents.count == 2, contents[0] == "mydoors.thomasmorel.io" {
            UserDefaults.standard.set(contents[1], forKey: "authorization")
            self.initContext()
            return true
        }
        return false
    }
    

    func sendAuthorizationTokenToWatch(session: WCSession){
        guard let token = UserDefaults.standard.object(forKey: "authorization") as? String else { return }
        do {
            try session.updateApplicationContext(["authorization": token])
        } catch let error as NSError {
            print(error.description)
        }
    }

    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if session.isPaired && session.isWatchAppInstalled {
            self.sendAuthorizationTokenToWatch(session: session)
        }
    }
    
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession){
        
    }
    
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession){
        
    }
    
}

