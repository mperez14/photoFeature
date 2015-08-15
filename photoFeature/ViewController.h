//
//  ViewController.h
//  photoFeature
//
//  Created by Matthew Perez on 6/26/15.
//  Copyright (c) 2015 Matthew Perez. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <FontAwesomeKit/FontAwesomeKit.h>
#import <Parse/Parse.h>

@class editPhotoController;
@interface ViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    
    __weak IBOutlet UIImageView *imageView;
    UIImagePickerController *picker;
    UIImage *image;
}
@property (weak, nonatomic) IBOutlet UIButton *takePhoto;
@property (weak, nonatomic) IBOutlet UIButton *galleryPhoto;
//@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *refresh;
@property (weak, nonatomic) UIImage *image;
@property (nonatomic, retain) editPhotoController *editPhoto;

- (IBAction)takePhoto:(id)sender;

- (IBAction)usePhotoGallery:(id)sender;
- (IBAction)refresh:(id)sender;
@end

