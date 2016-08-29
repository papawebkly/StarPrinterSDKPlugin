//
//  JpKnjFormatingMini.m
//  IOS_SDK
//
//  Created by Koji on 12/09/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import "AppDelegate.h"

#import "JpKnjFormatingMini.h"
#import <QuartzCore/QuartzCore.h>
#import "StandardHelp.h"
#import "MiniPrinterFunctions.h"

#import "PrinterFunctions.h"

#import "AbstractActionSheetPicker.h"

#import "ActionSheetStringPicker.h"

@implementation JpKnjFormatingMini

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        array_height = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", nil];
        array_width = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", nil];
        array_alignment = [[NSArray alloc]initWithObjects:@"Left", @"Center", @"Right", nil];
        blocking = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [array_height release];
    [array_width release];
    [array_alignment release];
    [buttonHeight release];
    [buttonWidth release];
    [buttonAlignment release];
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

    uitextfield_leftMargin.delegate = self;
    uitextview_texttoprint.delegate = self;

    selectedHeight    = 0;
    selectedWidth     = 0;
    selectedAlignment = 0;

    [buttonHeight    setTitle:array_height   [selectedHeight]    forState:UIControlStateNormal];
    [buttonWidth     setTitle:array_width    [selectedWidth]     forState:UIControlStateNormal];
    [buttonAlignment setTitle:array_alignment[selectedAlignment] forState:UIControlStateNormal];
    
    [AppDelegate setButtonArrayAsOldStyle:@[buttonAlignment, buttonBack, buttonHeight, buttonHelp, buttonPrint, buttonWidth]];
    
    // Gesture Recognizer
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark Gesture Recognizer

- (void)onSingleTap:(UIGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == singleTap) {
        if ((uitextfield_leftMargin.isFirstResponder) ||
            (uitextview_texttoprint.isFirstResponder)) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

#pragma mark UITextField

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [uiscrollview_main setContentOffset:CGPointMake(0.0, 200.0) animated:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [uiscrollview_main setContentOffset:CGPointZero animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"] == YES)
    {
        [uitextfield_leftMargin resignFirstResponder];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [uiscrollview_main setContentOffset:CGPointZero animated:YES];
        }
        
        return NO;
    }
    
    if ([string length] == 0)
    {
        return YES;
    }
    
    if (([string characterAtIndex:0] >= '0') && ([string characterAtIndex:0] <= '9'))
    {
        return YES;
    }
    
    return NO;
}

#pragma mark UITextView

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [uiscrollview_main setContentOffset:CGPointMake(0.0, 200.0) animated:YES];
        uiscrollview_main.scrollEnabled = NO;
    }
}

- (void)textViewDidEndEditing:(UITextField *)textField
{
    [uiscrollview_main setContentOffset:CGPointZero animated:YES];
    uiscrollview_main.scrollEnabled = YES;
}

#pragma mark Common

- (IBAction)backTextFormating
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectHeight:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedHeight = selectedIndex;

        [buttonHeight setTitle:selectedValue forState:UIControlStateNormal];
    };

    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };

    [ActionSheetStringPicker showPickerWithTitle:@"Select Height" rows:array_height initialSelection:selectedHeight doneBlock:done cancelBlock:cancel origin:sender];
}

- (IBAction)selectWidth:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedWidth = selectedIndex;

        [buttonWidth setTitle:selectedValue forState:UIControlStateNormal];
    };

    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };

    [ActionSheetStringPicker showPickerWithTitle:@"Select Width" rows:array_width initialSelection:selectedWidth doneBlock:done cancelBlock:cancel origin:sender];
}

- (IBAction)selectAlignment:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedAlignment = selectedIndex;

        [buttonAlignment setTitle:selectedValue forState:UIControlStateNormal];
    };

    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };

    [ActionSheetStringPicker showPickerWithTitle:@"Select Alignment" rows:array_alignment initialSelection:selectedAlignment doneBlock:done cancelBlock:cancel origin:sender];
}

- (IBAction)showHelp
{
    NSString *title = @"JP KANJI FORMATING";
    NSString *helpText = [AppDelegate HTMLCSS];
    helpText = [helpText stringByAppendingString: @"<UnderlineTitle>Specify / Cancel Shift JIS Kanji character mode</UnderlineTitle><br/><br/>\n\
                <Code>ASCII:</Code> <CodeDef>FS C $ <StandardItalic>n</StandardItalic></CodeDef><br/>\n\
                <Code>Hex:</Code> <CodeDef>1B 24 </CodeDef><br/><br/>\n\
                <rightMov>n = 1 or 0 (on or off)</rightMov><br/><br/>\n\
				<UnderlineTitle>Underline Command</UnderlineTitle><br/><br/>\n\
                <Code>ASCII:</Code> <CodeDef>ESC - <StandardItalic>n</StandardItalic></CodeDef><br/>\
                <Code>Hex:</Code> <CodeDef>1B 2D <StandardItalic>n</StandardItalic></CodeDef><br/><br/>\
                <rightMov>n</rightMov> <rightMov_NOI>= 0,1, or 2</rightMov_NOI><br/>\
                <rightMov>0</rightMov> <rightMov_NOI>= Turns off underline mode</rightMov_NOI><br/>\
                <rightMov>1</rightMov> <rightMov_NOI>= Turns on underline mode (1 dot thick)</rightMov_NOI><br/>\
                <rightMov>2</rightMov> <rightMov_NOI>= Turns on underline mode (2 dots thick)</rightMov_NOI><br/><br/><br/>\
                <UnderlineTitle>Emphasized Mode</UnderlineTitle><br/><br/>\
                <Code>ASCII:</Code> <CodeDef>ESC E <StandardItalic>n</StandardItalic></CodeDef><br/>\
                <Code>Hex:</Code> <CodeDef>1B 45 <StandardItalic>n</StandardItalic></CodeDef><br/><br/>\
                <rightMov>n</rightMov> <rightMov_NOI>= 1 or 0 (on or off)</rightMov_NOI><br/><br/>\
                <UnderlineTitle>Upside Down</UnderlineTitle><br/><br/>\
                <Code>ASCII:</Code> <CodeDef>ESC { <StandardItalic>n</StandardItalic></CodeDef><br/>\
                <Code>Hex:</Code> <CodeDef>1B 7B <StandardItalic>n</StandardItalic></CodeDef></br/><br/>\
                <rightMov>n</rightMov><rightMov_NOI>= 1 or 0 (on or off)</rightMov_NOI><br/><br/>\
                <UnderlineTitle>Invert Color</UnderlineTitle><br/><br/>\
                <Code>ASCII:</Code> <CodeDef>GS B <StandardItalic>n</StandardItalic></CodeDef><br/>\
                <Code>Hex:</Code> <CodeDef>1D 42 <StandardItalic>n</StandardItalic></CodeDef><br/><br/>\
                <rightMov>n</rightMov> <rightMov_NOI>= 1 or 0 (on or off)</rightMov_NOI><br/><br/>\
                <UnderlineTitle>Set character size</UnderlineTitle><br/><br/>\
                <Code>ASCII:</Code> <CodeDef>GS ! <StandardItalic>n</StandardItalic></CodeDef><br/>\
                <Code>Hex:</Code> <CodeDef>1D 21 <StandardItalic>n</StandardItalic></CodeDef><br/><br/>\
                <rightMov>1&#8804;height multiple times normal font size&#8804;8</rightMov><br/>\
                <rightMov>1&#8804;width  multiple times normal font size&#8804;8</rightMov><br/>\
                <rightMov>n represents both height and width expansions.  Bit 0 to 2 sets the character width. Bit 4 to 6 sets the character height</rightMov><br/><br/<br/><br/>\
                <UnderlineTitle>Left Margin</UnderlineTitle><br/><br/>\
                <Code>ACSII:</Code> <CodeDef>GS L <StandardItalic>nL nH</StandardItalic></CodeDef><br/>\
                <Code>Hex:</Code> <CodeDef>1D 4C <StandardItalic>nL nH</StandardItalic></CodeDef><br/><br/>\
                <rightMov>nL</rightMov> <rightMov_NOI>Lower order number for left margin.  Mathematically: margin % 256</rightMov_NOI><br/><br/>\
                <rightMov>nH</rightMov> <rightMov_NOI>Higher order number for left margin.  Mathematically: margin / 256</rightMov_NOI><br/><br/>\
                </body></html>"];
    
    StandardHelp *helpVar = [[StandardHelp alloc]initWithNibName:@"StandardHelp" bundle:[NSBundle mainBundle]];
    [self presentViewController:helpVar animated:YES completion:nil];
    [helpVar release];
    
    [helpVar setHelpTitle:title];
    [helpVar setHelpText:helpText];
}

- (IBAction)printTextFormating
{
    if (blocking) {
        return;
    }
    blocking = YES;
    
    NSString *portName = [AppDelegate getPortName];
    NSString *portSettings = [AppDelegate getPortSettings];

    bool underline = [uiswitch_underline isOn];
    bool emphasized = [uiswitch_emphasized isOn];
    bool upsidedown = [uiswitch_upsizeddown isOn];
    bool inverColor = [uiswitch_invertcolor isOn];

    int height = (int)selectedHeight;
    int width  = (int)selectedWidth;

    Alignment alignment = (Alignment)selectedAlignment;

    int leftMargin = uitextfield_leftMargin.text.intValue;

    NSData *textData = [uitextview_texttoprint.text dataUsingEncoding:NSShiftJISStringEncoding];

    unsigned char *textBytes = (unsigned char *)malloc(textData.length);
    [textData getBytes:textBytes length:textData.length];

    [MiniPrinterFunctions PrintJpKanji:portName 
                          PortSettings:portSettings
                             Underline:underline
                            Emphasized:emphasized
                           Upsideddown:upsidedown
                           InvertColor:inverColor
                       HeightExpansion:height
                        WidthExpansion:width
                            LeftMargin:leftMargin
                             Alignment:alignment
                           TextToPrint:textBytes
                       TextToPrintSize:(unsigned int)textData.length];
    
    free(textBytes);
    
    blocking = NO;
}

@end
