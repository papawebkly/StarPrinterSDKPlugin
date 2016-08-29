//
//  PDF417.h
//  IOS_SDK
//
//  Created by Tzvi on 8/15/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDF417 : UIViewController <UITextFieldDelegate> {
    IBOutlet UIView *uiview_block;
    
    IBOutlet UIImageView *uiimageview_barcode;

    IBOutlet UITextField *uitextfield_height;
    IBOutlet UITextField *uitextfield_width;
    IBOutlet UITextField *uitextfield_data;

    IBOutlet UILabel *uilabel_height;
    IBOutlet UILabel *uilabel_width;

    IBOutlet UIButton *buttonLimit;
    IBOutlet UIButton *buttonRatio;
    IBOutlet UIButton *buttonDirection;
    IBOutlet UIButton *buttonSecurity;
    IBOutlet UIButton *buttonBack;
    IBOutlet UIButton *buttonHelp;
    IBOutlet UIButton *buttonPrint;

    NSInteger selectedLimit;
    NSInteger selectedRatio;
    NSInteger selectedDirection;
    NSInteger selectedSecurity;

    NSArray *array_limit;
    NSArray *array_ratio;
    NSArray *array_direction;
    NSArray *array_security;
}

- (IBAction)selectLimit:(id)sender;
- (IBAction)selectRatio:(id)sender;
- (IBAction)selectDirection:(id)sender;
- (IBAction)selectSecurity:(id)sender;

- (IBAction)backPDF417;
- (IBAction)showHelp;
- (IBAction)printBarcode;

@end
