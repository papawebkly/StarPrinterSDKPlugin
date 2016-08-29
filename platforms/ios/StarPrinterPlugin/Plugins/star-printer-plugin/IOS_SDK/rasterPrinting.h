//
//  rasterPrinting.h
//  IOS_SDK
//
//  Created by Tzvi on 8/17/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface rasterPrinting : UIViewController <UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UIView *uiview_main;
    IBOutlet UIView *uiview_block;

    IBOutlet UIScrollView *uiscrollview_main;

    IBOutlet UITextField *uitextfield_textsize;

    IBOutlet UITextView *uitextview_texttoprint;

    IBOutlet UIButton *buttonFont;
    IBOutlet UIButton *buttonFontStyle;
    IBOutlet UIButton *buttonPrinterSize;
    IBOutlet UILabel  *labelCompression;
    IBOutlet UISwitch *switchCompression;
    IBOutlet UILabel  *labelPageMode;
    IBOutlet UISwitch *switchPageMode;
    IBOutlet UIButton *buttonBack;
    IBOutlet UIButton *buttonHelp;
    IBOutlet UIButton *buttonPrint;

    NSInteger selectedFont;
    NSInteger selectedFontStyle;
    NSInteger selectedPrinterSize;

    NSArray *array_font;
    NSArray *array_fontStyle;
    NSArray *array_printerSize;
    
    UITapGestureRecognizer *singleTap;
    
    BOOL blocking;
}

- (IBAction)selectFont:(id)sender;
- (IBAction)selectFontStyle:(id)sender;
- (IBAction)selectPrinterSize:(id)sender;

- (IBAction)backRasterPrinting;
- (IBAction)printRasterText;
- (IBAction)sizeChanged;

- (void)setOptionSwitch:(BOOL)miniPrinter;

@end
