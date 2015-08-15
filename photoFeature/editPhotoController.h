//
//  editPhotoController.h
//  photoFeature
//
//  Created by Matthew Perez on 8/12/15.
//  Copyright (c) 2015 Matthew Perez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import <Parse/Parse.h>

@interface editPhotoController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    UIImagePickerController *picker;
}


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (nonatomic, strong) PFFile *photoFile;

@end
