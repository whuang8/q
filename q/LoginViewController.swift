//
//  LoginViewController.swift
//  q
//
//  Created by William Huang on 5/29/17.
//  Copyright © 2017 William Huang. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    
    func setup() throws {
        guard let path = Bundle.main.path(forResource: "keys", ofType: "plist") else {
            throw LoginError.ClientKeyError("Unable to find key list")
        }
        let keys = NSDictionary(contentsOfFile: path)
        let clientID = keys?["spotifyClientKey"] as! String
        SPTAuth.defaultInstance().clientID = "\(String(describing: clientID))"
        SPTAuth.defaultInstance().redirectURL = URL(string: "q://returnAfterLogin")
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
        loginUrl = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        try! setup()
        NotificationCenter.default.addObserver(self, selector: #selector(updateAfterFirstLogin), name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
    }
    
    func updateAfterFirstLogin () {
        let userDefaults = UserDefaults.standard
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            self.session = firstTimeSession
            initializePlayer(authSession: session)
        }
    }
    
    func initializePlayer(authSession:SPTSession){
        if self.player == nil {
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self
            self.player!.delegate = self
            try! player!.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
        }
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
        print("logged in")
        self.player?.playSpotifyURI("spotify:track:4bdJHQp90ymjEIkkYhcENB", startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if (error != nil) {
                print("playing!")
            }
        })
        self.loginButton.isHidden = true
        self.textLabel.text = "💵💵 DAT $TICK 💵💵"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        UIApplication.shared.open(loginUrl!, options: [:]) { (success: Bool) in
            if self.auth.canHandle(self.auth.redirectURL) {
                // To do - build in error handling
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
