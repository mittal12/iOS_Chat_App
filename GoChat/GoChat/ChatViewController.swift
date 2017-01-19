//
//  ChatViewController.swift
//  GoChat
//
//  Created by Ashish Mittal on 10/09/16.
//  Copyright © 2016 Ashish Mittal. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SDWebImage
class ChatViewController: JSQMessagesViewController {

    @IBAction func logOutDidTapped(sender: AnyObject) {
        do{
           try FIRAuth.auth()?.signOut()
        }
        catch let error
        {
            print(error);
        }
        
              print("logout tapeed ")
       
        let  storyBoard = UIStoryboard(name:"Main",
            bundle:nil)
        let loginVc=storyBoard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController;
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController=loginVc;
        
    }
    
    
    var messages=[JSQMessage]();
    var messageRef=FIRDatabase.database().reference().child("messages")
    var avatarDict = [String :JSQMessagesAvatarImage!]()
    let photoCache = NSCache()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       if let currentUser=FIRAuth.auth()?.currentUser{
        self.senderId=currentUser.uid;
       
        if currentUser.anonymous == true
        {
           self.senderDisplayName="ananymous"
        }
        else
        {
            self.senderDisplayName = "\(currentUser.displayName)"
        }
        }
        
        
        
        
      
//        print(messageRef)
//        print(rootRef)
//        messageRef.childByAutoId().setValue("this is the first message")
//        messageRef.childByAutoId().setValue("this is the second message")
//        messageRef.observeEventType(FIRDataEventType.Value) {(snapshot:FIRDataSnapshot )in
//            print(snapshot.value);
//            if let dict = snapshot.value as? NSDictionary
//            {
//                print(dict)
//            }
//        }

        messageRef.observeEventType(FIRDataEventType.ChildAdded) {(snapshot:FIRDataSnapshot )in
            if let dict = snapshot.value as? NSString
            {
                print(dict)
                
            }
        }
        //observerUsers()
        observeMessage()
        // Do any additional setup after loading the view.
    }
    
    func observerUsers(id: String)
    {
        //childadded will take all users one by one
        //.value will take only particlular user informataion corresponding to the sender id sent in the arguments
        // users will collect all the information
        //child(id) will catch values to only one particular users.
        FIRDatabase.database().reference().child("users").child(id).observeEventType(.Value
            , withBlock: { snapshot in
                print("the value is \(snapshot.value)")
                if let dict = snapshot.value as? [String :AnyObject]
                {
                    let avatarURL = dict["profileURL"] as! String
                    self.setAvatar(avatarURL,messageId: id)
                }
                
        })
        collectionView.reloadData()
        
    }
    
    func setAvatar(url :String ,messageId :String)
    {
        
        if url != ""
        {
            
            let fileUrl = NSURL(string: url)
          let  data = NSData(contentsOfURL: fileUrl!)
           let image = UIImage(data :data!)
           let userImg = JSQMessagesAvatarImageFactory.avatarImageWithImage(image, diameter: 30)
            avatarDict[messageId] = userImg;
        }
        else
        {
          avatarDict[messageId] = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "profileImage"), diameter: 30)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func observeMessage()
    {
        messageRef.observeEventType( FIRDataEventType.ChildAdded , withBlock: { snapshot in
                print(snapshot.value);
            if let dict = snapshot.value as? [String :AnyObject]
            {
                let mediaType = dict["mediaType"] as! String
                let senderName = dict["senderName"] as! String
                let senderId = dict["senderId"] as! String
                self.observerUsers(senderId)
                
                let startTime=CFAbsoluteTimeGetCurrent()
                
                if mediaType == "TEXT"
                {
                    let text = dict["text"] as? String
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                    print("TEXT MESSAGE :\(CFAbsoluteTimeGetCurrent()-startTime )")
                }
                else if mediaType == "PHOTO"
                {
                // var photo = JSQPhotoMediaItem(image: nil)
//                    let fileUrl = dict["fileUrl"] as! String
//                    if let cachedPhoto = self.photoCache.objectForKey(fileUrl)as? JSQPhotoMediaItem {
//                        photo = cachedPhoto
//                        self.collectionView.reloadData()
//                    }
//                    else{
//                        
//                        
//                        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), {
//                            let imageData = NSData(contentsOfURL: NSURL(string: fileUrl)!)
//                            
//                            dispatch_async(dispatch_get_main_queue(), {
//                                let picture = UIImage(data: imageData!)
//                                
//                                photo.image=picture
//                                self.photoCache.setObject(photo, forKey: fileUrl)
//                                self.collectionView.reloadData()
//                                
//                                
//                            })
//                        })
                    
                    
                    
                    
                    
                    
                        
                   // }

                    
                    let photo = JSQPhotoMediaItem(image: nil)
                    let fileUrl = dict["fileUrl"] as! String
                    
                    let downloader = SDWebImageDownloader.sharedDownloader();

                        downloader.downloadImageWithURL(NSURL(string : fileUrl)!,options:[],progress :nil,completed: {(image,data,error,finished) in
                            
                            print(NSThread.currentThread());
                            dispatch_async(dispatch_get_main_queue(),{
                                photo.image=image;
                                self.collectionView.reloadData()
                            })
                            
                            
                        })
                    
                    
                    
                    self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media:photo))


                    if senderId == self.senderId
                    {
                        photo.appliesMediaViewMaskAsOutgoing = true;
            }
            else
                    {
                        photo.appliesMediaViewMaskAsOutgoing = false;
            }

            print("PHOTO MESSAGE :\(CFAbsoluteTimeGetCurrent()-startTime )")
            }
                else if mediaType == "VIDEO"
                {
                   let fileUrl = dict["fileUrl"] as! String
                    let video = NSURL(string : fileUrl);
                    let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true);
                    self.messages.append(JSQMessage(senderId:senderId, displayName: senderName, media:videoItem))
                    
                    if senderId == self.senderId
                    {
                        videoItem.appliesMediaViewMaskAsOutgoing = true;
                    }
                    else
                    {
                        videoItem.appliesMediaViewMaskAsOutgoing = false;
                    }

                    print("VIDEO MESSAGE :\(CFAbsoluteTimeGetCurrent()-startTime )")
                    
                }
                    self.collectionView?.reloadData()
            }
                
            } );
    }
    
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
//        print("didpressbutton clicked");
//        print("\(text)");
//        print(senderDisplayName);
//        print(senderId);
        let message = messageRef.childByAutoId();
        let messageData = ["text":text , "senderId":senderId , "senderName":senderDisplayName , "mediaType":"TEXT"];
        
    // this function is used to put the information to the database
        message.setValue(messageData)
        // for clearing the message in the text box
        self.finishSendingMessage()
        self.collectionView.reloadData()
        
//        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
//        collectionView?.reloadData()
//        print(messages);
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell=super.collectionView(collectionView , cellForItemAtIndexPath:indexPath ) as! JSQMessagesCollectionViewCell;
        return cell
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item];
         let bubbleFactory=JSQMessagesBubbleImageFactory();
        if message.senderId == self.senderId
        {
            return bubbleFactory.outgoingMessagesBubbleImageWithColor(.blackColor())
        }
        else{
            return bubbleFactory.incomingMessagesBubbleImageWithColor(.blueColor())
        }
        }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item];
        return avatarDict[message.senderId]
        //return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "profileImage"), diameter: 30)
    }
    
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item];
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("number of items \(messages.count)");
        return messages.count;
    }
    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
//    {
//        print("did pick")
//    }
    
 ////////////////   use to check what is the location of the tapped message.
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        print("didmessagetapped :\(indexPath.item)")
        let message = messages[indexPath.item]
        if message.isMediaMessage
        {
            
            if let mediaItem = message.media as? JSQVideoMediaItem{
                let player = AVPlayer(URL: mediaItem.fileURL)
                let playerViewController = AVPlayerViewController()
                playerViewController.player=player;//this line shows what file is to play.
                self.presentViewController(playerViewController, animated: true, completion: nil)
            }
        }
    }
    
    
    func getMediaFrom(type :CFString)
    {
        print(type)
        let imagePicker=UIImagePickerController()
                imagePicker.delegate=self
        imagePicker.mediaTypes=[type as String];
                self.presentViewController(imagePicker,animated:true,completion:nil)

    }

    override func didPressAccessoryButton(sender: UIButton!) {
        print("Accesory tapped")
        let sheet=UIAlertController(title: "Media Message", message: "Please select the media", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let cancel=UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {(alert:UIAlertAction) in
        }
        
        let photoLibrary=UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default){(alert:UIAlertAction) in
            self.getMediaFrom(kUTTypeImage);
        }
        
        let videoLibrary=UIAlertAction(title: "video Library", style: UIAlertActionStyle.Default){(alert:UIAlertAction) in
            self.getMediaFrom(kUTTypeMovie)
        }
        
        
        sheet.addAction(cancel)
        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        self.presentViewController(sheet,animated:true,completion:nil)
        //        let imagePicker=UIImagePickerController()
//        imagePicker.delegate=self
//        self.presentViewController(imagePicker,animated:true,completion:nil)
    }
    
    func sendMessage(picture:UIImage? ,video: NSURL?)
    {
        print(picture);
        print(FIRStorage.storage().reference())
        
        if let picture = picture
        {
            let filePath = "\(FIRAuth.auth()!.currentUser!)/\(NSDate.timeIntervalSinceReferenceDate())"
            print(filePath)
            let data = UIImageJPEGRepresentation(picture,0.1);
            let metaData = FIRStorageMetadata();
            metaData.contentType="image/jpg"
            FIRStorage.storage().reference().child(filePath).putData(data!, metadata: metaData) {
                (metaData,error ) in
                if error != nil
                {
                    print(error?.localizedDescription)
                }
                print(metaData)
                let fileUrl = metaData!.downloadURLs![0].absoluteString;
                let message = self.messageRef.childByAutoId();
                let messageData = ["fileUrl":fileUrl , "senderId":self.senderId , "senderName":self.senderDisplayName ,"mediaType":"PHOTO"];
                message.setValue(messageData)
            }
        }
        else if let video = video
        {
            let filePath = "\(FIRAuth.auth()!.currentUser!)/\(NSDate.timeIntervalSinceReferenceDate())"
            print(filePath)
            let data = NSData(contentsOfURL: video);
            let metaData = FIRStorageMetadata();
            metaData.contentType="video/mp4"
            FIRStorage.storage().reference().child(filePath).putData(data!, metadata: metaData) {
                (metaData,error ) in
                if error != nil
                {
                    print(error?.localizedDescription)
                }
                print(metaData)
                let fileUrl = metaData!.downloadURLs![0].absoluteString;
                let message = self.messageRef.childByAutoId();
                let messageData = ["fileUrl":fileUrl , "senderId":self.senderId , "senderName":self.senderDisplayName ,"mediaType":"VIDEO"];
                message.setValue(messageData)
            }
        }

        }
 
}

extension ChatViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        print("did pick")
        print(info)
       if let picture=info[UIImagePickerControllerOriginalImage] as? UIImage {
     //   let photo = JSQPhotoMediaItem(image: picture)
       // messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media:photo))
        sendMessage(picture,video: nil);
        
        }
     else if let video=info[UIImagePickerControllerMediaURL] as? NSURL{
        
       // let videoItem=JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
       // messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: videoItem))
        sendMessage(nil,video:video);
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        collectionView?.reloadData()
    }
}
