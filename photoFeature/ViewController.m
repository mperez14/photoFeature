//
//  ViewController.m
//  photoFeature
//
//  Created by Matthew Perez on 6/26/15.
//  Copyright (c) 2015 Matthew Perez. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    NSString *partyName;
    NSArray *loadimageArray;
    PFFile *imageFile;
}
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;

@end

@implementation ViewController
@synthesize takePhoto, galleryPhoto;
- (void)viewDidLoad {
    [self loadImageParse];
    [super viewDidLoad];
    partyName = @"party1";  //Load name of party (PFObject to save picture to)
    
    FAKFontAwesome *sendIcon = [FAKFontAwesome sendIconWithSize:20];
    [sendIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    
    FAKFontAwesome *sendIcon2 = [FAKFontAwesome sendOIconWithSize:20];

    UIImage *takePhotoImage = [sendIcon imageWithSize:CGSizeMake(20, 20)];
    UIImage *galleryPhotoImage = [sendIcon2 imageWithSize:CGSizeMake(20, 20)];
    //sendIcon.iconFontSize = 15;
    
    [takePhoto setImage:takePhotoImage forState:normal];
    [galleryPhoto setImage:galleryPhotoImage forState:normal];
    
    

    
    /*
    UIImage *leftLandscapeImage = [sendIcon imageWithSize:CGSizeMake(15, 15)];
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:leftImage
                       landscapeImagePhone:leftLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    */
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)takePhoto:(id)sender {
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
    image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [imageView setImage:image]; //load imageView with image
    
    //save to parse. Call when picture loads
    [self shouldUploadImage:image];
    
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (BOOL)shouldUploadImage:(UIImage *)anImage {
    
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8f); //conver image to jpeg
    
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
    
    return YES;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (PFQuery *)queryForTable {
    //pull from parse
    PFQuery *partyPics = [PFQuery queryWithClassName:@"App"];
    [partyPics whereKey:partyName equalTo:partyName];    //constrain images to same party
    
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:partyPics, nil]];
    //[query includeKey:kPAPPhotoUserKey];
    [query orderByDescending:@"createdAt"];
    
    return query;
}


-(void)loadImageParse{
    NSLog(@"Here");
    PFQuery *partyPics = [PFQuery queryWithClassName:@"App"];
    
    //[partyPics whereKey:@"partyName" equalTo:partyName];    //constrain images to same party
    [partyPics findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error loading");
        }else{
            loadimageArray = [[NSArray alloc] initWithArray:objects];
            NSLog(@"successful");
            NSLog(@"imageArray: %@", loadimageArray);   //successful
            
            for(int i=0; i<[loadimageArray count]; i++){
                PFObject *imageObject = [loadimageArray objectAtIndex:0];
                NSLog(@"iamgeObject: %@", imageObject);
                imageFile = [imageObject objectForKey:@"picture"];
                NSLog(@"imagefile: %@",imageFile);
                
                
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        UIImage *imageConverted = [UIImage imageWithData:data];
                        NSLog(@"%@", data);
                        NSLog(@"%@", imageFile);
                        [imageView setImage:imageConverted];
                        // image can now be set on a UIImageView
                    }
                    else{
                        NSLog(@"Error");
                    }
                }];
            }
        }
    }];
    
    //PFObject *imageObject =
    
    
    
    /*
    NSLog(@"party Pics: %@", partyPics);
    
    for(int i=0; i<3; i++){
        PFObject *partyObjectPics = [partyPics getFirstObject];
        PFFile *imageFile = [partyObjectPics objectForKey:@"picture"];
        NSLog(@"%@", imageFile);
        
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *imageConverted = [UIImage imageWithData:data];
                NSLog(@"%@", data);
                NSLog(@"%@", imageFile);
                [imageView setImage:imageConverted];
                // image can now be set on a UIImageView
            }
            else{
                NSLog(@"Error");
            }
        }];
        
        //image = partyPics;
    }*/
}

@end
