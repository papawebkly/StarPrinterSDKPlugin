//
//  JpKnjFormating.m
//  IOS_SDK
//
//  Created by Koji on 12/08/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import "AppDelegate.h"

#import "JpKnjFormating.h"
#import <QuartzCore/QuartzCore.h>
#import "StandardHelp.h"

#import "PrinterFunctions.h"

#import "AbstractActionSheetPicker.h"
#import "ActionSheetStringPicker.h"

@implementation JpKnjFormating

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        array_height = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", nil];
        array_width = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", nil];
        array_alignment = [[NSArray alloc] initWithObjects:@"Left", @"Center", @"Right", nil];
        blocking = NO;
        
        NSString *portSettings = [AppDelegate getPortSettings];
        p_printerType = [AppDelegate parsePortSettings:portSettings];
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
    [singleTap release];
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

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [uiview_main addSubview:uiscrollview_main];
        uiscrollview_main.contentSize = uiscrollview_main.frame.size;
        uiscrollview_main.scrollEnabled = YES;
        uiscrollview_main.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }

    if (p_printerType == SMPrinterTypePortablePrinterStarLine) {
        uisegment_kanjiMode.hidden = YES;
    }

    uitextview_texttoprint.layer.borderWidth = 1;

    uitextview_texttoprint.delegate = self;
    uitextfield_leftMargin.delegate = self;

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

#pragma mark TextView

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [uiscrollview_main setContentOffset:CGPointMake(0.0, 400.0) animated:YES];
        uiscrollview_main.scrollEnabled = NO;
    }
}

- (void)textViewDidEndEditing:(UITextField *)textField
{
    [uiscrollview_main setContentOffset:CGPointZero animated:YES];
    uiscrollview_main.scrollEnabled = YES;
}

#pragma mark TextField

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

#pragma mark Gesture Recognizer

- (void)onSingleTap:(UIGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
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

#pragma mark Common

- (IBAction)backTextFormating
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showHelp
{
    NSString *title = @"JP KANJI FORMATTING";
    NSString *helpText = [AppDelegate HTMLCSS];
    
    if (p_printerType == SMPrinterTypeDesktopPrinterStarLine) {
        helpText = [helpText stringByAppendingString:@"<UnderlineTitle>Specify JIS Kanji character mode</UnderlineTitle><br/><br/>\n\
                    <Code>ASCII:</Code> <CodeDef>ESC p </CodeDef><br/>\n\
                    <Code>Hex:</Code> <CodeDef>1B 70 </CodeDef><br/><br/>\n\
                    <UnderlineTitle>Cancel JIS Kanji character mode</UnderlineTitle><br/><br/>\n\
                    <Code>ASCII:</Code> <CodeDef>ESC q </CodeDef><br/>\n\
                    <Code>Hex:</Code> <CodeDef>1B 71 </CodeDef><br/><br/>\n"];
    }
    
    helpText = [helpText stringByAppendingString:@"\
                <UnderlineTitle>Specify / Cancel Shift JIS Kanji character mode</UnderlineTitle><br/><br/>\n\
                <Code>ASCII:</Code> <CodeDef>ESC $ <StandardItalic>n</StandardItalic></CodeDef><br/>\n\
                <Code>Hex:</Code> <CodeDef>1B 24 </CodeDef><br/><br/>\n\
                <rightMov>n = 1 or 0 (on or off)</rightMov><br/><br/>\n\
                <UnderlineTitle>Character Expansion Settings</UnderlineTitle><br/><br/>\n\
                Width Expansion<br/>\n\
                <Code>ASCII:</Code> <CodeDef>ESC W <StandardItalic>n</StandardItalic></CodeDef><br/>\n\
                <Code>Hex:</Code> <CodeDef>1B 57 <StandardItalic>n</StandardItalic></CodeDef><br/><br/>\n\
                Height Expansion<br/>\n\
                <Code>ASCII:</Code> <CodeDef>ESC h <StandardItalic>n</StandardItalic></CodeDef><br/>\n\
                <Code>Hex:</Code> <CodeDef>1B 68 <StandardItalic>n</StandardItalic></CodeDef><br/><br/>\n\
                <rightMov>n = 0 through 5 (Multiplier)</rightMov><br/><br/>\n\
                <UnderlineTitle>Emphasized Printing (Bold)</UnderlineTitle><br/><br/>\n\
                Start Bold Text<br/>\n\
                <Code>ASCII:</Code> <CodeDef>ESC E\n</CodeDef><br/>\n\
                <Code>Hex:</Code> <CodeDef>1B 45\n</CodeDef><br/><br/>\n\
                Stop Bold Text<br/>\n\
                <Code>ASCII:</Code> <CodeDef>ESC F</CodeDef><br/>\n\
                <Code>Hex:</Code> <CodeDef>1B 46</CodeDef><br/><br/>\n\
                <UnderlineTitle>Underline Mode</UnderlineTitle><br/><br/>\n\
                <Code>ASCII:</Code> <CodeDef>ESC - <StandardItalic>n</StandardItalic></CodeDef><br/>\n\
                <Code>Hex:</Code> <CodeDef>1B 2D <StandardItalic>n</StandardItalic></CodeDef><br/><br/>\n\
                <rightMov>n = 1 or 0 (on or off)</rightMov><br/><br/>\n\
                <UnderlineTitle>Upperline Mode</UnderlineTitle><br/><br/>\n\
                <Code>ASCII:</Code> <CodeDef>ESC _ <StandardItalic>n</StandardItalic></CodeDef><br/>\n\
                <Code>Hex:</Code> <CodeDef>1B 5F <StandardItalic>n</StandardItalic></CodeDef><br/><br/>\n\
                <rightMov>n = 1 or 0 (on or off)</rightMov><br/><br/>\n\
                <UnderlineTitle>White/Black Inverted Color Mode</UnderlineTitle><br/><br/>\n\
                Start B/W Invert<br/>\
                <Code>ASCII:</Code> <CodeDef>ESC 4</CodeDef><br/>\n\
                <Code>Hex:</Code> <CodeDef>1B 34</CodeDef><br/><br/>\n\
                Stop B/W Invert<br/>\n\
                <Code>ASCII:</Code> <CodeDef>ESC 5</CodeDef><br/>\n\
                <Code>Hex:</Code> <CodeDef>1b 35</CodeDef><br/><br/>\n\
                <UnderlineTitle>Upside-Down Printing</UnderlineTitle><br/><br/>\n\
                Start Upside-Down<br/>\n\
                <Code>ASCII:</Code> <CodeDef>SI</CodeDef><br/>\n\
                <Code>Hex:</Code> <CodeDef>0F</CodeDef><br/><br/>\n\
                Stop Upside-Down<br/>\n\
                <Code>ASCII:</Code> <CodeDef>DC2</CodeDef><br/>\n\
                <Code>Hex:</Code> <CodeDef>12</CodeDef><br/><br/>\n\
                Note: When using the command, only use it at the start of a new line. Rightside-up and Upside-Down text cannot be on the same line.<br/><br/>\
                <UnderlineTitle>Set Left Margin</UnderlineTitle><br/><br/>\n\
                <Code>ASCII:</Code> <CodeDef>ESC l <StandardItalic>n</StandardItalic></CodeDef><br/>\n\
                <Code>Hex:</Code> <CodeDef>1B 6C <StandardItalic>n</StandardItalic></CodeDef><br/><br/>\n\
                <rightMov>n = 0 through 255</rightMov><br/><br/>\n\
                <UnderlineTitle>Set Text Alignment</UnderlineTitle><br/><br/>\n\
                <Code>ASCII:</Code> <CodeDef>ESC GS a <StandardItalic>n</StandardItalic></CodeDef><br/>\
                <Code>Hex:</Code> <CodeDef>1B 1D 61 <StandardItalic>n</StandardItalic></CodeDef><br/><br/>\
                <rightMov>n = 0 (left) or 1 (center) or 2 (right)</rightMov>\
                </body></html>\
                "];
    
    StandardHelp *helpVar = [[StandardHelp alloc]initWithNibName:@"StandardHelp" bundle:[NSBundle mainBundle]];
    [self presentViewController:helpVar animated:YES completion:nil];
    [helpVar release];
    
    [helpVar setHelpTitle:title];
    [helpVar setHelpText:helpText];
}

- (IBAction)PrintText
{
    if (blocking) {
        return;
    }
    blocking = YES;
    
    NSString *portName = [AppDelegate getPortName];
    NSString *portSettings = [AppDelegate getPortSettings];

	int  kanjiMode = (int)[uisegment_kanjiMode selectedSegmentIndex];

    bool underline   = [uiswitch_underline   isOn];
    bool invertColor = [uiswitch_invertcolor isOn];
    bool emphasized  = [uiswitch_emphasized  isOn];
    bool upperline   = [uiswitch_upperline   isOn];
    bool upsideDown  = [uiswitch_upsizeDown  isOn];

    int height = (int)selectedHeight;
    int width  = (int)selectedWidth;

    Alignment alignment = (Alignment)selectedAlignment;

    int leftMargin = [uitextfield_leftMargin.text intValue];

	NSData *textNSData;
	if (kanjiMode == 0) // Shift-JIS
	{
		textNSData = [uitextview_texttoprint.text dataUsingEncoding:NSShiftJISStringEncoding];
	}
	else // JIS
	{
        NSMutableData *buffer = [NSMutableData new];
        u_int8_t LF[1] = {0x0a};
        
        NSArray *splitText = [uitextview_texttoprint.text componentsSeparatedByString:@"\n"];
        for (int i = 0; i < splitText.count; i++) {
            NSString *string = splitText[i];
            if (string.length > 0)
            {
                NSData *tempData = [string dataUsingEncoding:NSISO2022JPStringEncoding];
                Byte tempDataBytes[tempData.length];
                [tempData getBytes:tempDataBytes length:tempData.length];
                
                Byte specifyJISkanjiCharacterModeCommand[] = {0x1b, 0x70};
                Byte cancelJISkanjiCharacterModeCommand[] = {0x1b, 0x71};
                
                for (int i = 0; i < sizeof(tempDataBytes); i++) {
                    if (tempDataBytes[i] == 0x1b) {
                        if (tempDataBytes[i+1] == 0x24) { // Replace [0x1b 0x24 0x42] to "Specify JIS Kanji Character Mode" command
                            [buffer appendBytes:specifyJISkanjiCharacterModeCommand length:sizeof(specifyJISkanjiCharacterModeCommand)];
                        }
                        else if (tempDataBytes[i+1] == 0x28) { // Replace [0x1b 0x28 0x42] to "Cancel JIS Kanji Character Mode" command
                            [buffer appendBytes:cancelJISkanjiCharacterModeCommand length:sizeof(cancelJISkanjiCharacterModeCommand)];
                        }
                        
                        i += 2;
                    }
                    else {
                        [buffer appendBytes:&(tempDataBytes[i]) length:1];
                    }
                }
            }

            if (i < splitText.count - 1) {
                [buffer appendBytes:LF length:1];
            }
        }
        
        textNSData = [NSData dataWithData:buffer];
        [buffer release];
	}

    unsigned char *textData = (unsigned char *)malloc(textNSData.length);
    [textNSData getBytes:textData length:textNSData.length];

	[PrinterFunctions PrintKanjiTextWithPortname:portName
                                    portSettings:portSettings
                                       kanjiMode:kanjiMode
                                       underline:underline
                                     invertColor:invertColor
                                      emphasized:emphasized
                                       upperline:upperline
                                      upsideDown:upsideDown
                                 heightExpansion:height
                                  widthExpansion:width
                                      leftMargin:leftMargin
                                       alignment:alignment
                                        textData:textData
                                    textDataSize:(unsigned int)textNSData.length];

    free(textData);
    
    blocking = NO;
}

@end
