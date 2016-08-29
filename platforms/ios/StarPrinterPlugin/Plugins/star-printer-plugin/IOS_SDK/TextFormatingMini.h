//
//  TextFormatingMini.h
//  IOS_SDK
//
//  Created by Tzvi on 8/25/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFormatingMini : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate> {
    IBOutlet UIView *uiview_main;
    IBOutlet UIView *uiview_block;

    IBOutlet UIScrollView *uiscrollview_main;

    IBOutlet UISwitch *uiswitch_underline;
    IBOutlet UISwitch *uiswitch_emphasized;
    IBOutlet UISwitch *uiswitch_upsizeddown;
    IBOutlet UISwitch *uiswitch_invertcolor;

    IBOutlet UITextField *uitextfield_leftMargin;
    IBOutlet UITextView *uitextview_texttoprint;

    IBOutlet UIButton *buttonHeight;
    IBOutlet UIButton *buttonWidth;
    IBOutlet UIButton *buttonAlignment;
    IBOutlet UIButton *buttonBack;
    IBOutlet UIButton *buttonHelp;
    IBOutlet UIButton *buttonPrint;

    NSInteger selectedHeight;
    NSInteger selectedWidth;
    NSInteger selectedAlignment;

    NSArray *array_height;
    NSArray *array_width;
    NSArray *array_alignment;
    
    UITapGestureRecognizer *singleTap;
    
    BOOL blocking;
}

- (IBAction)selectHeight:(id)sender;
- (IBAction)selectWidth:(id)sender;
- (IBAction)selectAlignment:(id)sender;

- (IBAction)backTextFormating;
- (IBAction)showHelp;
- (IBAction)printTextFormating;

@end
