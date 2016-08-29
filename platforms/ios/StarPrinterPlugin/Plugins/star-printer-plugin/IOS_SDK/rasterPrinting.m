//
//  rasterPrinting.m
//  IOS_SDK
//
//  Created by Tzvi on 8/17/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import "AppDelegate.h"

#import "rasterPrinting.h"
#import <QuartzCore/QuartzCore.h>
#import "StandardHelp.h"

#import "MiniPrinterFunctions.h"
#import "PrinterFunctions.h"

#import "AbstractActionSheetPicker.h"
#import "ActionSheetStringPicker.h"

@interface rasterPrinting (hidden)

- (UIFont *)getSelectedFont:(int)multiple;

@end

@implementation rasterPrinting

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSMutableArray *validFonts = [NSMutableArray array];
        
        NSArray *fontFamilyNames = [UIFont familyNames];
        for (NSString *fontFamily in fontFamilyNames) {
            NSArray *fonts = [UIFont fontNamesForFamilyName:fontFamily];
            if (fonts.count > 0) {
                [validFonts addObject:fontFamily];
            }
        }
        
        array_font = [[NSArray alloc] initWithArray:validFonts];
        array_fontStyle = [[NSArray alloc] initWithArray:[UIFont fontNamesForFamilyName:array_font[0]]];

        NSString *portSettings = [AppDelegate getPortSettings];
        SMPrinterType printerType = [AppDelegate parsePortSettings:portSettings];
        
        if ((printerType == SMPrinterTypePortablePrinterESCPOS) ||
            (printerType == SMPrinterTypePortablePrinterStarLine))
        {
            array_printerSize = [[NSArray alloc] initWithObjects:@"2 inch", @"3 inch", @"4 inch", nil];
        }
        else
        {
            array_printerSize = [[NSArray alloc] initWithObjects:@"3 inch", @"4 inch", nil];
        }
    }
    
    return self;
}

- (void)dealloc
{
    [uiview_main release];
    [uiview_block release];
    [uiscrollview_main release];
    [uitextfield_textsize release];
    [uitextview_texttoprint release];
    [buttonFont release];
    [buttonFontStyle release];
    [buttonPrinterSize release];
    [labelCompression release];
    [switchCompression release];
    [labelPageMode release];
    [switchPageMode release];
    [array_font release];
    [array_fontStyle release];
    [array_printerSize release];
    [singleTap release];

    [buttonBack release];
    [buttonHelp release];
    [buttonPrint release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [uiview_main addSubview:uiscrollview_main];
        uiscrollview_main.contentSize = uiscrollview_main.frame.size;
        uiscrollview_main.scrollEnabled = YES;
        uiscrollview_main.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    uitextview_texttoprint.layer.borderWidth = 1;
    UIFont *font = uitextview_texttoprint.font;
    UIFont *font2 = [UIFont fontWithName:font.familyName size:[UIFont labelFontSize]];
    uitextview_texttoprint.font = font2;
    double f = [UIFont labelFontSize];
    NSString *fontSize = [NSString stringWithFormat:@"%02.2f", f];
    uitextfield_textsize.text = fontSize;

    uitextfield_textsize.delegate = self;
    uitextview_texttoprint.delegate = self;

    selectedFont        = 0;
    selectedFontStyle   = 0;
    selectedPrinterSize = 0;

    [buttonFont        setTitle:array_font       [selectedFont]        forState:UIControlStateNormal];
    [buttonFontStyle   setTitle:array_fontStyle  [selectedFontStyle]   forState:UIControlStateNormal];
    [buttonPrinterSize setTitle:array_printerSize[selectedPrinterSize] forState:UIControlStateNormal];
    
    [AppDelegate setButtonArrayAsOldStyle:@[buttonBack, buttonFont, buttonFontStyle, buttonHelp, buttonPrint, buttonPrinterSize]];
    
    // Gesture Recognizer
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    singleTap.delegate = self;
    singleTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTap];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)selectFont:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedFont = selectedIndex;

        [buttonFont setTitle:selectedValue forState:UIControlStateNormal];

        NSArray *fontSytlesArray = [UIFont fontNamesForFamilyName:array_font[selectedFont]];

        [array_fontStyle release];
        array_fontStyle = [[NSArray alloc] initWithArray:fontSytlesArray];

        uitextview_texttoprint.font = [self getSelectedFont:1];

        selectedFontStyle = 0;
        [buttonFontStyle setTitle:array_fontStyle[selectedFontStyle] forState:UIControlStateNormal];
    };

    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };

    [ActionSheetStringPicker showPickerWithTitle:@"Select Font" rows:array_font initialSelection:selectedFont doneBlock:done cancelBlock:cancel origin:sender];
}

- (IBAction)selectFontStyle:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedFontStyle = selectedIndex;

        [buttonFontStyle setTitle:selectedValue forState:UIControlStateNormal];

        uitextview_texttoprint.font = [self getSelectedFont:1];
    };

    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };

    [ActionSheetStringPicker showPickerWithTitle:@"Select FontStyle" rows:array_fontStyle initialSelection:selectedFontStyle doneBlock:done cancelBlock:cancel origin:sender];
}

- (IBAction)selectPrinterSize:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedPrinterSize = selectedIndex;

        [buttonPrinterSize setTitle:selectedValue forState:UIControlStateNormal];
    };

    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };

    [ActionSheetStringPicker showPickerWithTitle:@"Select PrinterSize" rows:array_printerSize initialSelection:selectedPrinterSize doneBlock:done cancelBlock:cancel origin:sender];
}



- (IBAction)sizeChanged
{
    uitextview_texttoprint.font = [self getSelectedFont:1];
}

- (void)setOptionSwitch:(BOOL)miniPrinter
{
    if (miniPrinter) {
        labelCompression.text = @"Compression API";
    } else {
        labelPageMode.hidden = YES;
        switchPageMode.hidden = YES;
    }
}

- (UIFont *)getSelectedFont:(int)multiple;
{
    int fontIndex = (int)selectedFontStyle;
    if (fontIndex > array_fontStyle.count - 1) {
        fontIndex = (int)array_fontStyle.count - 1;
    }
    
    NSString *fontName = array_fontStyle[fontIndex];
    
    double fontSize = [uitextfield_textsize.text floatValue];
    fontSize *= multiple;
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    
    return font;
}

#pragma mark TextView

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [uiscrollview_main setContentOffset:CGPointZero animated:YES];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [uiscrollview_main setContentOffset:CGPointZero animated:YES];
    }
}

#pragma mark TextField

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [uiscrollview_main setContentOffset:CGPointMake(0.0, 200.0) animated:YES];
        uiscrollview_main.scrollEnabled = NO;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [uiscrollview_main setContentOffset:CGPointZero animated:YES];
    uiscrollview_main.scrollEnabled = YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"] == YES) {
        [uitextfield_textsize resignFirstResponder];
        return NO;
    }
    
    if (string.length == 0) {
        return YES;
    }
    
    if (([string characterAtIndex:0] >= '0') && ([string characterAtIndex:0] <= '9')) {
        return YES;
    }
    
    return NO;
}

#pragma mark Gesture Recognizer

- (void)onSingleTap:(UIGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == singleTap) {
        if ((uitextview_texttoprint.isFirstResponder) ||
            (uitextfield_textsize.isFirstResponder)) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

#pragma mark Common

- (IBAction)backRasterPrinting
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)printRasterText
{
    if (blocking) {
        return;
    }
    blocking = YES;
    
    NSString *textToPrint = uitextview_texttoprint.text;
    
    NSString *portName = [AppDelegate getPortName];
    NSString *portSettings = [AppDelegate getPortSettings];
    
    int width = 576;
    
    SMPrinterType printerType = [AppDelegate parsePortSettings:portSettings];
    if ((printerType == SMPrinterTypePortablePrinterESCPOS) ||
        (printerType == SMPrinterTypePortablePrinterStarLine))
    {
        switch (selectedPrinterSize)
        {
            default : width = 384; break;
            case 1  : width = 576; break;
            case 2  : width = 832; break;
        }
    }
    else // Star Line Mode
    {
        switch (selectedPrinterSize)
        {
            default : width = 576; break;
            case 1  : width = 832; break;
        }
    }
    
    UIFont *font = [self getSelectedFont:2];
    
    UIImage *imageToPrint = [PrinterFunctions imageWithString:textToPrint
                                                         font:font
                                                        width:width];
    
    if (printerType == SMPrinterTypePortablePrinterESCPOS)
    {
        [MiniPrinterFunctions PrintBitmapWithPortName:portName portSettings:portSettings imageSource:imageToPrint printerWidth:width compressionEnable:switchCompression.on pageModeEnable:switchPageMode.on];
    }
    else // Star Line Mode, Star Raster Mode
    {
        [PrinterFunctions PrintImageWithPortname:portName portSettings:portSettings imageToPrint:imageToPrint maxWidth:width compressionEnable:switchCompression.on withDrawerKick:NO];
    }
    
    blocking = NO;
}

- (IBAction)showHelp
{
    NSString *title = @"PRINTING RASTER IMAGES";
    NSString *portSettings = [AppDelegate getPortSettings];
    NSString *helpText = [AppDelegate HTMLCSS];

    SMPrinterType printerType = [AppDelegate parsePortSettings:portSettings];
    if (printerType == SMPrinterTypePortablePrinterESCPOS)
    {
        helpText = [helpText stringByAppendingFormat:@"<UnderlineTitle>Define Bit Image</UnderlineTitle><br/><br/>\
                    <Code>ASCII:</Code> <CodeDef>ESC X 4 <StandardItalic>x y d1...dk</StandardItalic></CodeDef><br/>\
                    <Code>Hex:</Code> <CodeDef>1B 58 34 <StandardItalic>x y d1...dk</StandardItalic></CodeDef><br/><br/>\
                    <rightMov>x</rightMov> <rightMov_NOI>Width of the image divided by 8</rightMov_NOI><br/>\
                    <rightMov>y</rightMov> <rightMov_NOI>Vertical number of dots to be printed.  This value shouldn't exceed 24.  If you need to print an image taller than 24 then you should use this command multiple times</rightMov_NOI><br/><br/><br/><br/><br/>\
                    <rightMov>d1...dk</rightMov> <rightMov_NOI2>The dots that should be printed.  When all vertical dots are printed the head moves horizonaly to the next vertical set of dots</rightMov_NOI2><br/><br/><br/><br/>\
                    <UnderlineTitle>Print Bit Image</UnderlineTitle><br/><br/>\
                    <Code>ASCII:</Code> <CodeDef>ESC X 2 <StandardItalic>y</StandardItalic></CodeDef><br/>\
                    <Code>Hex:</Code> <CodeDef>1B 58 32<StandardItalics> y</StandardItalics></CodeDef><br/><br/>\
                    <rightMov> y</rightMov> <rightMov_NOI>The value y must be the same value that was used in ESC X 4 command for define a bit image</rightMov_NOI><br/><br/><br/><br/>\
                    Note: The command ESC X 2 must be used after each usage of ESC X 4 inorder to print images"];
    }
    else if (printerType == SMPrinterTypePortablePrinterStarLine) {
        helpText = [helpText stringByAppendingString:@"<UnderlineTitle>Print Raster Graphics data</UnderlineTitle><br/><br/>\
                    <Code>ASCII:</Code><CodeDef>ESC GS S <StandardItalic>m xL xH yL yH n1 [d11 d12 ... d1k] n2 [d21 d22 ... d2k]</StandardItalic></CodeDef><br/>\
                    <Code>Hex:</Code><CodeDef>1B 1D 53 <StandardItalic>m xL xH yL yH n1 [d11 d12 ... d1k] n2 [d21 d22 ... d2k]</StandardItalic></CodeDef><br/><br/>\
                    <div style=\"margin-left:15px; margin-bottom:15px\">\
                    <table>\
                    <tr><td width=\"50\" valign=\"top\">m</td><td>'m' specifies the number of transfer blocks and the tone.</td></tr>\
                    <tr><td valign=\"top\">xL, xH</td><td>(xL + xH * 256) specifies the number of horizontal data bytes. </td></tr>\
                    <tr><td valign=\"top\">yL, yH</td><td>(yL + yX x 256) specifies the number of dots in the vertical direction.</td></tr>\
                    <tr><td valign=\"top\">k</td><td>(yL + yX x 256) specifies the number of dots in the vertical direction.</td>\
                    </tr><tr><td valign=\"top\">d</td><td>(d1, d2, ... dk) specifies the image data to define.</td></tr>\
                    </table>\
                    </div>\
                    <UnderlineTitle>n/8mm line feed</UnderlineTitle><br/>\
                    <Code>ASCII:</Code><CodeDef>ESC I <StandardItalic>n</StandardItalic></CodeDef><br/>\
                    <Code>Hex:</Code><CodeDef>1B 49 <StandardItalic>n</StandardItalic></CodeDef><br/>\
                    <rightMov>1 &le; n &le; 255</rightMov> <br/>\
                    <rightMov_NOI>\
                    Executes a n/8mm paper feed.<br/>\
                    If print data exists in the line buffer, it prints that data.\
                    Using this command will intermittently feed paper, therefore, it is normally recommended that this command not be used.\
                    </rightMov_NOI><br/><br/><br/><br/><br/><br/><br/>\
                    "];
    } else {
        helpText = [helpText stringByAppendingString: @"<UnderlineTitle>Enter Raster Mode</UnderlineTitle><br/><br/>\
                <Code>ASCII:</Code> <CodeDef>ESC * r A</CodeDef><br/>\
                <Code>Hex:</Code> <CodeDef>1B 2A 72 41</CodeDef><br/><br/>\
                <UnderlineTitle>Initialize raster mode</UnderlineTitle><br/>\
                <Code>ASCII:</Code> <CodeDef>ESC * r R</CodeDef><br/>\
                <Code>Hex:</Code> <CodeDef>1B 2A 72 52</CodeDef><br/><br/>\
                <UnderlineTitle>Set Raster EOT mode</UnderlineTitle><br/><br/>\
                <Code>ASCII:</Code> <CodeDef>ESC * r E <StandardItalic>n</StandardItalic> NUL</CodeDef><br/>\
                <Code>Hex:</Code> <CodeDef>1B 2A 72 45 <StandardItalic>n</StandardItalic> 00</CodeDef><br/>\
                <div class=\"div-tableCut\">\
                    <div class=\"div-table-rowCut\">\
                        <div class=\"div-table-colRaster\"><center>n</center></div>\
                        <div class=\"div-table-colRaster\"><center>FormFeed</center></div>\
                        <div class=\"div-table-colRaster\"><center>Cut Feed</center></div>\
                        <div class=\"div-table-colRaster\"><center>Cutter</center></div>\
                        <div class=\"div-table-colRaster\"><center>Presenter</center></div>\
                    </div>\
                    <div class=\"div-table-rowCut\">\
                        <div class=\"div-table-colRaster\"><center>0</center></div>\
                        <div class=\"div-table-colRaster\"><center>Default</center></div>\
                        <div class=\"div-table-colRaster\"><center>Default</center></div>\
                        <div class=\"div-table-colRaster\"><center>Default</center></div>\
                        <div class=\"div-table-colRaster\"><center>Default</center></div>\
                    </div>\
                    <div class=\"div-table-rowCut\">\
                        <div class=\"div-table-colRaster\"><center>1</center></div>\
                        <div class=\"div-table-colRaster\"><center>○</center></div>\
                        <div class=\"div-table-colRaster\"><center>-</center></div>\
                        <div class=\"div-table-colRaster\"><center>-</center></div>\
                        <div class=\"div-table-colRaster\"><center>-</center></div>\
                    </div>\
                    <div class=\"div-table-rowCut\">\
                        <div class=\"div-table-colRaster\"><center>2</center></div>\
                        <div class=\"div-table-colRaster\"><center>○</center></div>\
                        <div class=\"div-table-colRaster\"><center>○</center></div>\
                        <div class=\"div-table-colRaster\"><center>-</center></div>\
                        <div class=\"div-table-colRaster\"><center>-</center></div>\
                    </div>\
                    <div class=\"div-table-rowCut\">\
                        <div class=\"div-table-colRaster\"><center>3</center></div>\
                        <div class=\"div-table-colRaster\"><center>○</center></div>\
                        <div class=\"div-table-colRaster\"><center>TearBar</center></div>\
                        <div class=\"div-table-colRaster\"><center>-</center></div>\
                        <div class=\"div-table-colRaster\"><center>-</center></div>\
                    </div>\
                    <div class=\"div-table-rowCut\">\
                        <div class=\"div-table-colRaster\"><center>8</center></div>\
                        <div class=\"div-table-colRaster\"><center>○</center></div>\
                        <div class=\"div-table-colRaster\"><center>-</center></div>\
                        <div class=\"div-table-colRaster\"><center>Full Cut</center></div>\
                        <div class=\"div-table-colRaster\"><center>-</center></div>\
                    </div>\
                    <div class=\"div-table-rowCut\">\
                        <div class=\"div-table-colRaster\"><center>9</center></div>\
                        <div class=\"div-table-colRaster\"><center>○</center></div>\
                        <div class=\"div-table-colRaster\"><center>○</center></div>\
                        <div class=\"div-table-colRaster\"><center>Full Cut</center></div>\
                        <div class=\"div-table-colRaster\"><center>-</center></div>\
                    </div>\
                    <div class=\"div-table-rowCut\">\
                        <div class=\"div-table-colRaster\"><center>12</center></div>\
                        <div class=\"div-table-colRaster\"><center>○</center></div>\
                        <div class=\"div-table-colRaster\"><center>-</center></div>\
                        <div class=\"div-table-colRaster\"><center>Partial Cut</center></div>\
                        <div class=\"div-table-colRaster\"><center>-</center></div>\
                    </div>\
                    <div class=\"div-table-rowCut\">\
                        <div class=\"div-table-colRaster\"><center>13</center></div>\
                        <div class=\"div-table-colRaster\"><center>○</center></div>\
                        <div class=\"div-table-colRaster\"><center>○</center></div>\
                        <div class=\"div-table-colRaster\"><center>Partial Cut</center></div>\
                        <div class=\"div-table-colRaster\"><center>-</center></div>\
                    </div>\
                    <div class=\"div-table-rowCut\">\
                        <div class=\"div-table-colRaster\"><center>36</center></div>\
                        <div class=\"div-table-colRaster\"><center>○</center></div>\
                        <div class=\"div-table-colRaster\"><center>-</center></div>\
                        <div class=\"div-table-colRaster\"><center>Full Cut</center></div>\
                        <div class=\"div-table-colRaster\"><center>Eject</center></div>\
                    </div>\
                    <div class=\"div-table-rowCut\">\
                        <div class=\"div-table-colRaster\"><center>37</center></div>\
                        <div class=\"div-table-colRaster\"><center>○</center></div>\
                        <div class=\"div-table-colRaster\"><center>○</center></div>\
                        <div class=\"div-table-colRaster\"><center>Full Cut</center></div>\
                        <div class=\"div-table-colRaster\"><center>Eject</center></div>\
                    </div>\
                </div><br/><br/>\
                <UnderlineTitle>Set Raster FF mode</UnderlineTitle><br/><br/>\
                <Code>ASCII:</Code> <CodeDef>ESC * r F <StandardItalic>n</StandardItalic> NUL</CodeDef><br/>\
                <Code>Hex:</Code> <CodeDef>1B 2A 72 46 <StandardItalic>n</StandardItalic> 00</CodeDef><br/>\
                <div class=\"div-tableCut\">\
                <div class=\"div-table-rowCut\">\
                <div class=\"div-table-colRaster\"><center>n</center></div>\
                <div class=\"div-table-colRaster\"><center>FormFeed</center></div>\
                <div class=\"div-table-colRaster\"><center>Cut Feed</center></div>\
                <div class=\"div-table-colRaster\"><center>Cutter</center></div>\
                <div class=\"div-table-colRaster\"><center>Presenter</center></div>\
                </div>\
                <div class=\"div-table-rowCut\">\
                <div class=\"div-table-colRaster\"><center>0</center></div>\
                <div class=\"div-table-colRaster\"><center>Default</center></div>\
                <div class=\"div-table-colRaster\"><center>Default</center></div>\
                <div class=\"div-table-colRaster\"><center>Default</center></div>\
                <div class=\"div-table-colRaster\"><center>Default</center></div>\
                </div>\
                <div class=\"div-table-rowCut\">\
                <div class=\"div-table-colRaster\"><center>1</center></div>\
                <div class=\"div-table-colRaster\"><center>○</center></div>\
                <div class=\"div-table-colRaster\"><center>-</center></div>\
                <div class=\"div-table-colRaster\"><center>-</center></div>\
                <div class=\"div-table-colRaster\"><center>-</center></div>\
                </div>\
                <div class=\"div-table-rowCut\">\
                <div class=\"div-table-colRaster\"><center>2</center></div>\
                <div class=\"div-table-colRaster\"><center>○</center></div>\
                <div class=\"div-table-colRaster\"><center>○</center></div>\
                <div class=\"div-table-colRaster\"><center>-</center></div>\
                <div class=\"div-table-colRaster\"><center>-</center></div>\
                </div>\
                <div class=\"div-table-rowCut\">\
                <div class=\"div-table-colRaster\"><center>3</center></div>\
                <div class=\"div-table-colRaster\"><center>○</center></div>\
                <div class=\"div-table-colRaster\"><center>TearBar</center></div>\
                <div class=\"div-table-colRaster\"><center>-</center></div>\
                <div class=\"div-table-colRaster\"><center>-</center></div>\
                </div>\
                <div class=\"div-table-rowCut\">\
                <div class=\"div-table-colRaster\"><center>8</center></div>\
                <div class=\"div-table-colRaster\"><center>○</center></div>\
                <div class=\"div-table-colRaster\"><center>-</center></div>\
                <div class=\"div-table-colRaster\"><center>Full Cut</center></div>\
                <div class=\"div-table-colRaster\"><center>-</center></div>\
                </div>\
                <div class=\"div-table-rowCut\">\
                <div class=\"div-table-colRaster\"><center>9</center></div>\
                <div class=\"div-table-colRaster\"><center>○</center></div>\
                <div class=\"div-table-colRaster\"><center>○</center></div>\
                <div class=\"div-table-colRaster\"><center>Full Cut</center></div>\
                <div class=\"div-table-colRaster\"><center>-</center></div>\
                </div>\
                <div class=\"div-table-rowCut\">\
                <div class=\"div-table-colRaster\"><center>12</center></div>\
                <div class=\"div-table-colRaster\"><center>○</center></div>\
                <div class=\"div-table-colRaster\"><center>-</center></div>\
                <div class=\"div-table-colRaster\"><center>Partial Cut</center></div>\
                <div class=\"div-table-colRaster\"><center>-</center></div>\
                </div>\
                <div class=\"div-table-rowCut\">\
                <div class=\"div-table-colRaster\"><center>13</center></div>\
                <div class=\"div-table-colRaster\"><center>○</center></div>\
                <div class=\"div-table-colRaster\"><center>○</center></div>\
                <div class=\"div-table-colRaster\"><center>Partial Cut</center></div>\
                <div class=\"div-table-colRaster\"><center>-</center></div>\
                </div>\
                <div class=\"div-table-rowCut\">\
                <div class=\"div-table-colRaster\"><center>36</center></div>\
                <div class=\"div-table-colRaster\"><center>○</center></div>\
                <div class=\"div-table-colRaster\"><center>-</center></div>\
                <div class=\"div-table-colRaster\"><center>Full Cut</center></div>\
                <div class=\"div-table-colRaster\"><center>Eject</center></div>\
                </div>\
                <div class=\"div-table-rowCut\">\
                <div class=\"div-table-colRaster\"><center>37</center></div>\
                <div class=\"div-table-colRaster\"><center>○</center></div>\
                <div class=\"div-table-colRaster\"><center>○</center></div>\
                <div class=\"div-table-colRaster\"><center>Full Cut</center></div>\
                <div class=\"div-table-colRaster\"><center>Eject</center></div>\
                </div>\
                </div><br/><br/>\
                <UnderlineTitle>Set raster page length</UnderlineTitle><br/>\
                <Code>ASCII:</Code> <CodeDef>ESC * r P <StandardItalic>n</StandardItalic> NUL</CodeDef><br/>\
                <Code>Hex:</Code> <CodeDef>1B 2A 72 50 <StandardItalic>n</StandardItalic> 00</CodeDef><br/><br/>\
                <rightMov>0 = Continuous print mode (no page length setting)</rightMov><br/><br/>\
                <rightMov>1&#60;n = Specify page length</rightMov><br/><br/>\
                <UnderlineTitle>Set raster print quality</UnderlineTitle><br/>\
                <Code>ASCII:</Code> <CodeDef>ESC * r Q <StandardItalic>n</StandardItalic> NUL</CodeDef><br/>\
                <Code>Hex:</Code> <CodeDef>1B 2A 72 51 <StandardItalic>n</StandardItalic> 00</CodeDef><br/><br/>\
                <rightMov>0 = Specify high speed printing</rightMov><br/>\
                <rightMov>1 = Normal print quality</rightMov><br/>\
                <rightMov>2 = High print quality</rightMov><br/><br/>\
                <UnderlineTitle>Set raster left margin</UnderlineTitle><br/><br/>\
                <Code>ASCII:</Code> <CodeDef>ESC * r m l <StandardItalic>n</StandardItalic> NUL</CodeDef><br/>\
                <Code>Hex:</Code> <CodeDef>1B 2A 72 6D 6C <StandardItalic>n</StandardItalic> 00</CodeDef><br/><br/>\
                <UnderlineTitle>Send raster data (auto line feed)</UnderlineTitle><br/><br/>\
                <Code>ASCII:</Code> <CodeDef>b <StandardItalic>n1 n2 d1 d2 ... dk</StandardItalic></CodeDef><br/>\
                <Code>Hex:</Code> <CodeDef>62 <StandardItalic>n1 n2 d1 d2 ... dk</StandardItalic></CodeDef><br/><br/>\
                <rightMov>n1 = (image width / 8) Mod 256</rightMov><br/>\
                <rightMov>n2 = image width / 256</rightMov><br/>\
                <rightMov>k = n1 + n2 * 256</rightMov><br/>\
                * Each byte send in d1 ... dk represents 8 horizontal bits.  The values n1 and n2 tell the printer how many byte are sent with d1 ... dk.  The printer automatically feeds when the last value for d1 ... dk is sent<br/><br/>\
                <UnderlineTitle>Quit raster mode</UnderlineTitle><br/></br>\
                <Code>ASCII:</Code> <CodeDef>ESC * r B</CodeDef><br/>\
                <Code>Hex:</Code> <CodeDef>1B 2A 72 42</CodeDef><br/><br/>\
                * This command automatically executes a EOT(cut) command before quiting.  Use the set EOT command to change the action of this command.\
                "];
    }
    
    StandardHelp *helpVar = [[StandardHelp alloc]initWithNibName:@"StandardHelp" bundle:[NSBundle mainBundle]];
    [self presentViewController:helpVar animated:YES completion:nil];
    [helpVar release];
    
    [helpVar setHelpTitle:title];
    [helpVar setHelpText:helpText];
}

@end
