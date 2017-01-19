//
//  Helper.swift
//  GoChat
//
//  Created by Ashish Mittal on 11/09/16.
//  Copyright © 2016 Ashish Mittal. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit
import GoogleSignIn
import FirebaseDatabase
class Helper
{
    static let helper=Helper();
    
    func loginAnonymously() {
        
        
        FIRAuth.auth()?.signInAnonymouslyWithCompletion({(anonymousUser :FIRUser? ,error: NSError? ) in
            if error == nil
            {
                print("USERID: \(anonymousUser!.uid)")
                
                
                
                
                
                
                let newUser = FIRDatabase.database().reference().child("users").child((anonymousUser!.uid))
                newUser.setValue(["displayName" : "anonymous", "id" : "\(anonymousUser!.uid)" ,"profileURL" : ""])
                
                
                
                
                
                self.switchToNAvigation()
            }
            else {
                print(error!.localizedDescription);
                return
            }
            
        });

    }
    
    
    func loginWithGoogle(authentication:GIDAuthentication)
    {
    
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken, accessToken: authentication.accessToken)
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (user : FIRUser?,error:NSError?) in
            
            if error != nil
            {
                print(error!.localizedDescription)
                return
            }
              else
            {
                print( user?.email)
                print(user?.displayName)
                print(user?.photoURL);
                
                
                let newUser = FIRDatabase.database().reference().child("users").child((user!.uid))
                newUser.setValue(["displayName" : "\(user!.displayName!)", "id" : "\(user!.uid)" ,"profileURL" : "\(user!.photoURL!)"])
                self.switchToNAvigation()
            }
           
        })
        
    }
     func switchToNAvigation()
    {
        let  storyBoard = UIStoryboard(name:"Main",
            bundle:nil)
        let navVC=storyBoard.instantiateViewControllerWithIdentifier("NavigationviewController"
            ) as! UINavigationController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController=navVC;
    }

}


