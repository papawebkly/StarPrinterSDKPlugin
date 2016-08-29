//
//  TextFormattingDotMatrixViewController.m
//  IOS_SDK
//
//  Created by u3237 on 2014/08/22.
//
//

#import "TextFormattingDotMatrixViewController.h"
#import "AppDelegate.h"

#import <QuartzCore/QuartzCore.h>
#import "StandardHelp.h"

#import "DotPrinterFunctions.h"

#import "AbstractActionSheetPicker.h"
#import "ActionSheetStringPicker.h"


@implementation TextFormattingDotMatrixViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        array_alignment = [[NSArray alloc] initWithObjects:@"Left", @"Center", @"Right", nil];
        blocking = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [array_alignment release];
    [buttonAlignment release];
    [uiview_block release];
    [buttonBack release];
    [buttonHelp release];
    [buttonPrint release];
    [singleTap release];
    
    [uilabel_slashedZero release];
    [uilabel_underline release];
    [uilabel_emphasized release];
    [uilabel_upperline release];
    [uilabel_upsideDown release];
    [uilabel_heightExpansion release];
    [uilabel_widthExpansion release];
    [uilabel_twoColor release];
    [uiview_justification release];
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
    
    [uiview_main addSubview:uiscrollview_main];
    uiscrollview_main.contentSize = uiscrollview_main.frame.size;
    uiscrollview_main.scrollEnabled = YES;
    uiscrollview_main.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    uitextview_texttoprint.layer.borderWidth = 1;

    uitextview_texttoprint.delegate = self;
    uitextfield_leftMargin.delegate = self;

    selectedAlignment = 0;
    
    [buttonAlignment setTitle:array_alignment[selectedAlignment] forState:UIControlStateNormal];
    
    [AppDelegate setButtonArrayAsOldStyle:@[buttonAlignment, buttonBack, buttonHelp, buttonPrint]];
    
    [self initializeControls];

    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
}

- (void)initializeControls
{
    uisegment_kanjiMode.hidden = YES;
    
    [self justificateLabel:uilabel_slashedZero switch:uiswitch_slashedZero number:0];
    [self justificateLabel:uilabel_underline switch:uiswitch_underline number:1];
    [self justificateLabel:uilabel_twoColor switch:uiswitch_twoColor number:2];
    [self justificateLabel:uilabel_emphasized switch:uiswitch_emphasized number:3];
    [self justificateLabel:uilabel_upperline switch:uiswitch_upperline number:4];
    [self justificateLabel:uilabel_upsideDown switch:uiswitch_upsideDown number:5];
    [self justificateLabel:uilabel_heightExpansion switch:uiswitch_heightExpansion number:6];
    [self justificateLabel:uilabel_widthExpansion switch:uiswitch_widthExpansion number:7];
    
    CGRect newFrame = uiview_justification.frame;
    newFrame.origin.y -= 44;
    uiview_justification.frame = newFrame;
}

- (void)justificateLabel:(UILabel *)label switch:(UISwitch *)sw number:(NSUInteger)number
{
    const int INITIAL_POS_Y = 42;
    
    label.frame = CGRectMake(label.frame.origin.x, INITIAL_POS_Y + (OFFSET * number), label.frame.size.width, label.frame.size.height);
    sw.frame = CGRectMake(sw.frame.origin.x, INITIAL_POS_Y + (OFFSET * number) - ((sw.frame.size.height - label.frame.size.height) / 2), sw.frame.size.width, sw.frame.size.height);

    number++;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark TextField

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        uiscrollview_main.contentOffset = CGPointMake(0.0, 200.0);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    uiscrollview_main.contentOffset = CGPointZero;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"] == YES) {
        [uitextfield_leftMargin resignFirstResponder];
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

#pragma mark TextView

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        uiscrollview_main.contentOffset = CGPointMake(0.0, 300.0);
        uiscrollview_main.scrollEnabled = NO;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    uiscrollview_main.contentOffset = CGPointZero;
    uiscrollview_main.scrollEnabled = YES;
}

- (IBAction)backTextFormating
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Alignment"
                                            rows:array_alignment
                                initialSelection:selectedAlignment
                                       doneBlock:done
                                     cancelBlock:cancel
                                          origin:sender];
}

- (IBAction)showHelp
{
    NSString *title = @"TEXT FORMATTING";
    NSString *helpText = [AppDelegate HTMLCSS];
    helpText = [helpText stringByAppendingString: @"<UnderlineTitle>Specify / Cancel Slash Zero</UnderlineTitle><br/><br/>\n\
                <Code>ASCII:</Code> <CodeDef>ESC / <StandardItalic>n</StandardItalic></CodeDef><br/>\n\
                <Code>Hex:</Code> <CodeDef>1B 2F <StandardItalic>n</StandardItalic></CodeDef><br/><br/>\n\
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
                <UnderlineTitle>Two Color Mode</UnderlineTitle><br/><br/>\n\
                Start Two Color<br/>\
                <Code>ASCII:</Code> <CodeDef>ESC 4</CodeDef><br/>\n\
                <Code>Hex:</Code> <CodeDef>1B 34</CodeDef><br/><br/>\n\
                Stop Two Color<br/>\n\
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
    
    StandardHelp *helpVar = [[StandardHelp alloc] initWithNibName:@"StandardHelp" bundle:[NSBundle mainBundle]];
    [self presentViewController:helpVar animated:YES completion:nil];
    [helpVar setHelpTitle:title];
    [helpVar setHelpText:helpText];
    
    [helpVar release];
}

- (IBAction)PrintText
{
    NSString *portName = [AppDelegate getPortName];
    NSString *portSettings = [AppDelegate getPortSettings];
    
    BOOL slashedZero = uiswitch_slashedZero.on;
    BOOL underline = uiswitch_underline.on;
    BOOL twoColor = uiswitch_twoColor.on;
    BOOL emphasized = uiswitch_emphasized.on;
    BOOL upperline = uiswitch_upperline.on;
    BOOL upsideDown = uiswitch_upsideDown.on;
    BOOL height = uiswitch_heightExpansion.on;
    BOOL width = uiswitch_widthExpansion.on;
    
    Alignment alignment = (Alignment)selectedAlignment;
    
    int leftMargin = uitextfield_leftMargin.text.intValue;
    
    NSData *textNSData = [uitextview_texttoprint.text dataUsingEncoding:NSWindowsCP1252StringEncoding];
    
    unsigned char *textData = (unsigned char *)malloc(textNSData.length);
    [textNSData getBytes:textData length:textNSData.length];
    
    [DotPrinterFunctions printTextWithPortname:portName
                                  portSettings:portSettings
                                   slashedZero:slashedZero
                                     underline:underline
                                      twoColor:twoColor
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
}

#pragma mark Gesture Recognizer

- (void)onSingleTap:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == singleTap) {
        if ((uitextview_texttoprint.isFirstResponder) ||
            (uitextfield_leftMargin.isFirstResponder)) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

@end
