//
//  editPhotoController.m
//  photoFeature
//
//  Created by Matthew Perez on 8/12/15.
//  Copyright (c) 2015 Matthew Perez. All rights reserved.
//

#import "editPhotoController.h"

@interface editPhotoController (){
    NSString *partyName;
}

@end

@implementation editPhotoController

- (void)viewDidLoad {
    [self takePhoto];
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
    partyName = @"party2";  //Load name of party (PFObject to save picture to)
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Push"
                                                            style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(shouldUploadImage:)];
    [self.navigationItem setRightBarButtonItem:item animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    _image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [_imageView setImage:_image]; //load imageView with image
    
    //save to parse. Call when picture loads
    //[self shouldUploadImage:image];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)shouldUploadImage:(UIImage *)anImage {
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(_image, 0.8f); //conver image to jpeg
    
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
    [party saveInBackground];   //push to parse
    
    NSLog(@"Pushed to Parse");
    
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"uploadPicture"];
        //[self presentViewController:viewController animated:YES completion:nil];
    //[[self navigationController] pushViewController:viewController animated:YES];
    [[self navigationController] showDetailViewController:viewController sender:self];
    
    return YES;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
