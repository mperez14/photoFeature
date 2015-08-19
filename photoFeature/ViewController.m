//
//  ViewController.m
//  photoFeature
//
//  Created by Matthew Perez on 6/26/15.
//  Copyright (c) 2015 Matthew Perez. All rights reserved.
//

//TODO: Make selection restricted to party string. Check by changing name

#import "ViewController.h"
#import "editPhotoController.h"

@interface ViewController (){
    NSString *partyName;
    NSArray *loadObjectArray;    //store UIObjects from Parse, use to get image
    PFFile *imageFile;
    NSMutableArray *pictureArray;   //store UIImages from parse
    int nextNum;
    
}
@property (nonatomic, strong) PFFile *photoFile;
//@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
//@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;

@end

@implementation ViewController
@synthesize galleryPhoto, refresh;
- (void)viewDidLoad {
    [self loadImageParse];
    [super viewDidLoad];
    
    
    partyName = @"party4";  //Load name of party (PFObject to save picture to)

    UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
    [singleTap setNumberOfTapsRequired:1];
    [imageView addGestureRecognizer:singleTap];
    [self.view addSubview:imageView];
}

-(void)singleTapping:(UIGestureRecognizer *)recognizer
{
    if([pictureArray count] != 0){
    NSLog(@"picture ar: %d", [pictureArray count]);
    nextNum++;
    if(nextNum >= [pictureArray count]){    //reset index if out of bounds of imageArray
        nextNum = 0;
        NSLog(@"count reset");
    }
    NSLog(@"nextNum: %d", nextNum);
    UIImage *nextImage = pictureArray[nextNum];
    NSLog(@"nextPic: %@", pictureArray[nextNum]);
    [imageView setImage:nextImage];
    }
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
    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"edit"];
//    [self presentViewController:viewController animated:YES completion:nil];

    
}

- (IBAction)refresh:(id)sender {
    [self loadImageParse]; //re-pull. fix, make a button to re-pull (HERE)
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    _image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    //image = [self drawFront:image text:@"Hello World" atPoint:CGPointMake(100, 100)];
    //image = [self burnTextIntoImage:@"HI" image:image];
    //image = [self drawTextOnImage:@"Hi World" img:image];
    //[imageView setImage:_image]; //load imageView with image
    
    //save to parse. Call when picture loads
    //[self shouldUploadImage:image];
    //NSLog(@"image1: %@", _image);
    //[self dismissViewControllerAnimated:YES completion:NULL];
    
    //Go to edit screen
    
//    SecondView *secView = [[SecondView alloc] initWithNibName:@"SecondView" bundle:[NSBundle mainBundle]];
//    
//    self.secondView = secView;
//    
//    secView.theImage = selectedImage.image;
    
    NSLog(@"Go to editviewController");
    //call segue
    [self performSegueWithIdentifier:@"edit" sender:self];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    [partyPics findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error loading");
        }else{
            loadObjectArray = [[NSArray alloc] initWithArray:objects];
            NSLog(@"successful");
            NSLog(@"imageArray: %@", loadObjectArray);   //successful
            
            for(int i=0; i<[loadObjectArray count]; i++){
                PFObject *imageObject = [loadObjectArray objectAtIndex:i];   //imageObject loads objects from imageArray
                
                //check if PFObject has same party as you
                if([[imageObject objectForKey:@"partyName"] isEqualToString:partyName]){
                    //if so, load image with value of photo from parse
                    imageFile = [imageObject objectForKey:@"picture"];
                }
                
                
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error) {
                        //convert PFFile => Data => UIImage
                        UIImage *imageConverted = [UIImage imageWithData:data];
                        
                        //add image to pictureArray
                        [pictureArray addObject:imageConverted];
                        
                        
                        //set index to beginning of array
                        nextNum = 0;
                        UIImage *firstImage = pictureArray[nextNum];
                        [imageView setImage:firstImage];    //load
                    }
                }];
            }
        }
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"edit"]){
        
        editPhotoController *controller = (editPhotoController *)segue.destinationViewController;
        controller.theImage = _image;   //pass image object to other view controller
        //NSLog(@"image2: %@", controller.theImage);
        
    }
}

@end
