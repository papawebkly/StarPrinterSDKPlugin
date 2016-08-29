//
//  TextFormattingDotMatrixViewController.h
//  IOS_SDK
//
//  Created by u3237 on 2014/08/22.
//
//

#import <UIKit/UIKit.h>

static const int OFFSET = 36;

@interface TextFormattingDotMatrixViewController : UIViewController  <UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate> {
    IBOutlet UIView *uiview_main;
    IBOutlet UIScrollView *uiscrollview_main;
    IBOutlet UIView *uiview_block;
    IBOutlet UIView *uiview_justification;
    
  	IBOutlet UISegmentedControl *uisegment_kanjiMode;
    
    IBOutlet UILabel *uilabel_slashedZero;
    IBOutlet UISwitch *uiswitch_slashedZero;
    IBOutlet UILabel *uilabel_underline;
    IBOutlet UISwitch *uiswitch_underline;
    IBOutlet UILabel *uilabel_twoColor;
    IBOutlet UISwitch *uiswitch_twoColor;
    IBOutlet UILabel *uilabel_emphasized;
    IBOutlet UISwitch *uiswitch_emphasized;
    IBOutlet UILabel *uilabel_upperline;
    IBOutlet UISwitch *uiswitch_upperline;
    IBOutlet UILabel *uilabel_upsideDown;
    IBOutlet UISwitch *uiswitch_upsideDown;
    IBOutlet UILabel *uilabel_heightExpansion;
    IBOutlet UISwitch *uiswitch_heightExpansion;
    IBOutlet UILabel *uilabel_widthExpansion;
    IBOutlet UISwitch *uiswitch_widthExpansion;
    
    IBOutlet UITextField *uitextfield_leftMargin;
    IBOutlet UIButton *buttonAlignment;
    IBOutlet UITextView *uitextview_texttoprint;

    IBOutlet UIButton *buttonBack;
    IBOutlet UIButton *buttonHelp;
    IBOutlet UIButton *buttonPrint;

    NSInteger selectedAlignment;

    NSArray *array_alignment;
    
    UITapGestureRecognizer *singleTap;
    
    BOOL blocking;
}

- (IBAction)selectAlignment:(id)sender;

- (IBAction)backTextFormating;
- (IBAction)showHelp;
- (IBAction)PrintText;

@end
