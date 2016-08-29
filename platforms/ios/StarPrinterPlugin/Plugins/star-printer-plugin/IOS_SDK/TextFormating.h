//
//  TextFormating.h
//  IOS_SDK
//
//  Created by Tzvi on 8/16/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFormating : UIViewController  <UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate> {
    IBOutlet UIView *uiview_main;

    IBOutlet UIView *uiview_block;
    IBOutlet UIScrollView *uiscrollview_main;
    
    IBOutlet UILabel *uilabel_ambiguity;
    IBOutlet UISegmentedControl *uisegment_ambiguity;

    IBOutlet UILabel *uilabel_slashedZero;
    IBOutlet UISwitch *uiswitch_slashedZero;
    IBOutlet UILabel *uilabel_underline;
    IBOutlet UISwitch *uiswitch_underline;
    IBOutlet UILabel *uilabel_invertcolor;
    IBOutlet UISwitch *uiswitch_invertcolor;
    IBOutlet UILabel *uilabel_emphasized;
    IBOutlet UISwitch *uiswitch_emphasized;
    IBOutlet UILabel *uilabel_upperline;
    IBOutlet UISwitch *uiswitch_upperline;
    IBOutlet UILabel *uilabel_upsideDown;
    IBOutlet UISwitch *uiswitch_upsizeDown;

    IBOutlet UILabel *uilabel_leftMargin;
    IBOutlet UITextField *uitextfield_leftMargin;
    IBOutlet UILabel * uilabel_texttoprint;
    IBOutlet UITextView *uitextview_texttoprint;

    IBOutlet UILabel * uilabel_Height;
    IBOutlet UIButton *buttonHeight;
    IBOutlet UILabel *uilabel_Width;
    IBOutlet UIButton *buttonWidth;
    IBOutlet UILabel *uilabel_Alignment;
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
- (IBAction)PrintText;

- (void)moveControls:(CGFloat)offset;

@end
