//
//  QRCodeMini.h
//  IOS_SDK
//
//  Created by Tzvi on 8/23/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRCodeMini : UIViewController <UITextFieldDelegate> {
    IBOutlet UIView *uiview_block;
    
    IBOutlet UITextField *uitextfield_data;

    IBOutlet UIButton *buttonCorrection;
    IBOutlet UIButton *buttonCode;
    IBOutlet UIButton *buttonModule;
    IBOutlet UIButton *buttonBack;
    IBOutlet UIButton *buttonHelp;
    IBOutlet UIButton *buttonPrint;

    NSInteger selectedCorrection;
    NSInteger selectedCode;
    NSInteger selectedModule;

    NSArray *array_correction;
    NSArray *array_codeL;
    NSArray *array_codeM;
    NSArray *array_codeQ;
    NSArray *array_codeH;
    NSArray *array_module;
}

- (IBAction)selectCorrection:(id)sender;
- (IBAction)selectCode:(id)sender;
- (IBAction)selectModule:(id)sender;

- (IBAction)backQRCode;
- (IBAction)showHelp;
- (IBAction)printQRCode;

@end
