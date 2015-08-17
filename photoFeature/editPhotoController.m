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
}

@end

@implementation editPhotoController

- (void)viewDidLoad {
    //[self takePhoto];
    //NSLog(@"image3: %@", _theImage);
    [_imageView setImage:_theImage];
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
    partyName = @"party3";  //Load name of party (PFObject to save picture to)
    
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
    NSLog(@"Tap detected");
    //if imageView is tapped => add uitext
    UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(200, 200, 300, 40)];
    textField.font = [UIFont systemFontOfSize:15];
    textField.placeholder = @"enter text";
    textField.autocorrectionType = UITextAutocorrectionTypeYes;
    textField.keyboardType = UIKeyboardTypeDefault;
    textField.returnKeyType = UIReturnKeyDone;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.delegate = (id)self;
    [_imageView addSubview:textField];
    //[textField release];
    
    
}


-(void)takePhoto{
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:picker animated:YES completion:NULL];
    
}

- (IBAction)usePhotoGallery:(id)sender {
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:picker animated:YES completion:NULL];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    _theImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [_imageView setImage:_theImage]; //load imageView with image
    
    //save to parse. Call when picture loads
    //[self shouldUploadImage:image];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)shouldUploadImage:(UIImage *)anImage {
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(_theImage, 0.8f); //conver image to jpeg
    
    if (!imageData) {
        NSLog(@"Image Data not converted");
        return NO;
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
    hud.labelText = @"Loading";
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
    
    
    
    return YES;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
