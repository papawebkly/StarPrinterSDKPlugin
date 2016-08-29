//
//  PDF417mini.h
//  IOS_SDK
//
//  Created by Tzvi on 8/24/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDF417mini : UIViewController <UITextFieldDelegate> {
    IBOutlet UIView *uiview_block;
    
    IBOutlet UITextField *uitextfield_data;

    IBOutlet UIButton *buttonWidth;
    IBOutlet UIButton *buttonColumn;
    IBOutlet UIButton *buttonSecurity;
    IBOutlet UIButton *buttonRatio;
    IBOutlet UIButton *buttonBack;
    IBOutlet UIButton *buttonHelp;
    IBOutlet UIButton *buttonPrint;

    NSInteger selectedWidth;
    NSInteger selectedColumn;
    NSInteger selectedSecurity;
    NSInteger selectedRatio;

    NSArray *array_width;
    NSMutableArray *array_column;
    NSArray *array_security;
    NSArray *array_ratio;
}

- (IBAction)selectWidth:(id)sender;
- (IBAction)selectColumn:(id)sender;
- (IBAction)selectSecurity:(id)sender;
- (IBAction)selectRatio:(id)sender;

- (IBAction)backPDF417;
- (IBAction)showHelp;
- (IBAction)printPDF417;

@end
