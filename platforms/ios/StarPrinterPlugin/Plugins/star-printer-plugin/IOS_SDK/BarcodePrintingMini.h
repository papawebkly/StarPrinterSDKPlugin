//
//  BarcodePrintingMini.h
//  IOS_SDK
//
//  Created by Tzvi on 8/23/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarcodePrintingMini : UIViewController <UITextFieldDelegate> {
    IBOutlet UIView *uiview_block;
    
    IBOutlet UITextField *uitextfield_height;
    IBOutlet UITextField *uitextfield_data;

    IBOutlet UIButton *buttonWidth;
    IBOutlet UIButton *buttonType;
    IBOutlet UIButton *buttonBack;
    IBOutlet UIButton *buttonHelp;
    IBOutlet UIButton *buttonPrint;

    NSInteger selectedWidth;
    NSInteger selectedType;

    NSArray *array_width;
    NSArray *array_type;
}

- (IBAction)selectWidth:(id)sender;
- (IBAction)selectType:(id)sender;

- (IBAction)backBarcodeMini;
- (IBAction)showHelp;
- (IBAction)printBarcode;

@end
