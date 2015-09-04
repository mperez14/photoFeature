//
//  editPhotoController.m
//  photoFeature
//
//  Created by Matthew Perez on 8/12/15.
//  Copyright (c) 2015 Matthew Perez. All rights reserved.
// Shows ViewController briefly before going to editorController

#import "editPhotoController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface editPhotoController (){
    NSString *partyName;
    bool *firstTouch;
    UITextField* textField;
}

@end

@implementation editPhotoController

- (void)viewDidLoad {
    [_imageView setImage:_theImage];
    firstTouch = true;
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
    partyName = @"party4";  //Load name of party (PFObject to save picture to)
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Push"
                                                            style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(shouldUploadImage:)];
    [self.navigationItem setRightBarButtonItem:item animated:YES];
    [self.navigationItem setTitle:@"Preview Photo"];
    
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
    [singleTap setNumberOfTapsRequired:1];
    [_imageView addGestureRecognizer:singleTap];
    
    [self.view addSubview:_imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)singleTapping:(UIGestureRecognizer *)recognizer
{
    if(firstTouch == true){
//        CGPoint touchPoint = [recognizer locationInView: _imageView];
//        //if imageView is tapped => add uitext
//        UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(touchPoint.x, touchPoint.y, 300, 40)];
        textField = [[UITextField alloc] initWithFrame:CGRectMake(_imageView.frame.origin.x/2, _imageView.frame.size.height/2, 300, 40)];
        textField.delegate = self;
        [textField becomeFirstResponder];   //show keyboard
        textField.font = [UIFont systemFontOfSize:15];
        textField.placeholder = @" ";
        textField.textAlignment = NSTextAlignmentCenter;
        textField.autocorrectionType = UITextAutocorrectionTypeYes;
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.returnKeyType = UIReturnKeyDone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.delegate = (id)self;
        [_imageView addSubview:textField];
        firstTouch = false;
    }
    else{
        //drag
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textfield {    //dismiss keyboard when done
    [textfield resignFirstResponder];
    return NO;
}

- (void)shouldUploadImage:(UIImage *)anImage {
    [textField endEditing:YES];
    
    // Screenshot UIImageView
    UIGraphicsBeginImageContextWithOptions(_imageView.bounds.size, NO, 0.0);
    [_imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screengrab = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(screengrab, 0.8f); //conver image to jpeg
    
    if (!imageData) {
        NSLog(@"Image Data not converted");
        return;
    }
    self.photoFile = [PFFile fileWithData:imageData];   //convert jpeg to PFFile
    
    //PFObject *photo = [PFObject objectWithClassName:@"photos"]; //PFObject = class name = photos
    //[photo setObject:self.photoFile forKey:@"picture"]; //type (aka column name)
    
    
    //How to save to parse and separate parties (USE Groups/PFObjects)
    // Create a Photo object
    PFObject *party = [PFObject objectWithClassName:@"App"]; //if partyName object is not created, then make it
    [party setObject:self.photoFile forKey:@"picture"]; //set picture for object
    [party setObject:partyName forKey:@"partyName"];    //save name of Party as a string
    //[party saveInBackground];   //push to parse
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Pushing Picture...";
    [party saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            //reload data to show new photo
            NSLog(@"Pushed to Parse");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"uploadPicture"];
            [[self navigationController] showDetailViewController:viewController sender:self];
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"error: %@",error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Could not upload photo, please try again!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
