//
//  LoginViewController.swift
//  GoChat
//
//  Created by Ashish Mittal on 10/09/16.
//  Copyright © 2016 Ashish Mittal. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
class LoginViewController: UIViewController,GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet var anonymousButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        anonymousButton.layer.borderWidth=2.0;
        anonymousButton.layer.borderColor=UIColor .whiteColor().CGColor;
        GIDSignIn.sharedInstance().clientID = "859101815756-bmnirqrfh28bvpl9g08a07m538gujkkj.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self;
        GIDSignIn.sharedInstance().uiDelegate=self;
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
         print(FIRAuth.auth()?.currentUser)
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth:FIRAuth,user: FIRUser?) in
            if user != nil
            {
                Helper.helper.switchToNAvigation()
            }
            else
            {
            print("Unauthorised")
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginAnonymouslyDidTapped(sender: AnyObject) {
        Helper.helper.loginAnonymously();
    }
  
    
    @IBAction func googleLoginDidTapped(sender: AnyObject) {
      print("the")
        GIDSignIn.sharedInstance().signIn()
        //Helper.helper.loginWithGoogle()
        
//        
//        let  storyBoard = UIStoryboard(name:"Main",
//            bundle:nil)
//        let navVC=storyBoard.instantiateViewControllerWithIdentifier("NavigationviewController"
//            ) as! UINavigationController
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        appDelegate.window?.rootViewController=navVC;
        
    }
   
    
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        
    }
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if error != nil{
            print(error.localizedDescription)
        }
        print(user.authentication)
        Helper.helper.loginWithGoogle(user.authentication)
    }
//    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
