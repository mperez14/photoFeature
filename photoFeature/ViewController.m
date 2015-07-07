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
    NSArray *loadimageArray;    //store UIObjects from Parse, use to get image
    PFFile *imageFile;
    NSMutableArray *pictureArray;   //store UIImages from parse
    int nextNum;
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
    
    [takePhoto setImage:takePhotoImage forState:normal];
    [galleryPhoto setImage:galleryPhotoImage forState:normal];
    
    

    
    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
    [singleTap setNumberOfTapsRequired:1];
    [imageView addGestureRecognizer:singleTap];
    [self.view addSubview:imageView];
}

-(void)singleTapping:(UIGestureRecognizer *)recognizer
{
    nextNum++;
    NSLog(@"picArray count:%d", [pictureArray count]);
    NSLog(@"nextNum: %d", nextNum);
    if(nextNum >= [pictureArray count]){    //reset index if out of bounds of imageArray
        nextNum = 0;
        NSLog(@"count reset");
    }
    UIImage *nextImage = pictureArray[nextNum];
    NSLog(@"nextPic: %@", pictureArray[nextNum]);
    [imageView setImage:nextImage];
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
    pictureArray = [[NSMutableArray alloc] init];   //init pictureArray
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
                //NSLog(@"iamgeObject: %@", imageObject);
                imageFile = [imageObject objectForKey:@"picture"];
                NSLog(@"imagefile: %@",imageFile);
                NSLog(@"# of pics: %d", [loadimageArray count]);
                
                
                
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        UIImage *imageConverted = [UIImage imageWithData:data];
                        //NSLog(@"%@", data);
                        //NSLog(@"%@", imageFile);
                        [pictureArray addObject:imageConverted];    //add iamge to pictureArray
                        nextNum = 0;    //set index to beginning of array.
                        UIImage *firstImage = pictureArray[nextNum];
                        [imageView setImage:firstImage];
                        NSLog(@"pcitureArray1: %@", firstImage);
                        //loading second image and not first
                    }
                }];
            }
        }
    }];
}

@end
