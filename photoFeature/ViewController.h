//
//  ViewController.h
//  photoFeature
//
//  Created by Matthew Perez on 6/26/15.
//  Copyright (c) 2015 Matthew Perez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FontAwesomeKit/FontAwesomeKit.h>


@interface ViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    
    __weak IBOutlet UIImageView *imageView;
    
    UIImagePickerController *picker;
    UIImage *image;
}
@property (weak, nonatomic) IBOutlet UIButton *takePhoto;
@property (weak, nonatomic) IBOutlet UIButton *galleryPhoto;

- (IBAction)takePhoto:(id)sender;

- (IBAction)usePhotoGallery:(id)sender;
@end

