//
//  SimplifiedTextFormattingDotMatrixViewController.m
//  IOS_SDK
//
//  Created by u3237 on 2014/08/22.
//
//

#import "SimplifiedTextFormattingDotMatrixViewController.h"
#import "AppDelegate.h"

#import <QuartzCore/QuartzCore.h>
#import "StandardHelp.h"

#import "DotPrinterFunctions.h"

#import "AbstractActionSheetPicker.h"
#import "ActionSheetStringPicker.h"

@implementation SimplifiedTextFormattingDotMatrixViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)initializeControls
{
    uisegment_kanjiMode.hidden = YES;
    
    uilabel_slashedZero.hidden = YES;
    uiswitch_slashedZero.hidden = YES;
    uilabel_heightExpansion.hidden = YES;
    uiswitch_heightExpansion.hidden = YES;
    
    [self justificateLabel:uilabel_underline switch:uiswitch_underline number:0];
    [self justificateLabel:uilabel_twoColor switch:uiswitch_twoColor number:1];
    [self justificateLabel:uilabel_emphasized switch:uiswitch_emphasized number:2];
    [self justificateLabel:uilabel_upperline switch:uiswitch_upperline number:3];
    [self justificateLabel:uilabel_upsideDown switch:uiswitch_upsideDown number:4];
    [self justificateLabel:uilabel_widthExpansion switch:uiswitch_widthExpansion number:5];
    
    CGRect newFrame = uiview_justification.frame;
    newFrame.origin.y -= (44 + (OFFSET * 2));
    uiview_justification.frame = newFrame;
    
    uitextview_texttoprint.text = @"此功能与上面所定义的打印机装修发送原始文本。\n";
}

- (void)justificateLabel:(UILabel *)label switch:(UISwitch *)sw number:(NSUInteger)number
{
    const int INITIAL_POS_Y = 42;
    
    label.frame = CGRectMake(label.frame.origin.x, INITIAL_POS_Y + (OFFSET * number), label.frame.size.width, label.frame.size.height);
    sw.frame = CGRectMake(sw.frame.origin.x, INITIAL_POS_Y + (OFFSET * number) - ((sw.frame.size.height - label.frame.size.height) / 2), sw.frame.size.width, sw.frame.size.height);
    
    number++;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)PrintText
{
    if (blocking) {
        return;
    }
    blocking = YES;
    
    NSString *portName = [AppDelegate getPortName];
    NSString *portSettings = [AppDelegate getPortSettings];
    
    BOOL underline = uiswitch_underline.on;
    BOOL twoColor = uiswitch_twoColor.on;
    BOOL emphasized = uiswitch_emphasized.on;
    BOOL upperline = uiswitch_upperline.on;
    BOOL upsideDown = uiswitch_upsideDown.on;
    BOOL width  = uiswitch_widthExpansion.on;
    
    Alignment alignment = (Alignment)selectedAlignment;
    
    int leftMargin = uitextfield_leftMargin.text.intValue;
    
	NSData *textNSData = [uitextview_texttoprint.text dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    
    unsigned char *textData = (unsigned char *)malloc(textNSData.length);
    [textNSData getBytes:textData length:textNSData.length];
    
	[DotPrinterFunctions printCHSTextWithPortname:portName
                                     portSettings:portSettings
                                        underline:underline
                                         twoColor:twoColor
                                       emphasized:emphasized
                                        upperline:upperline
                                       upsideDown:upsideDown
                                   widthExpansion:width
                                       leftMargin:leftMargin
                                        alignment:alignment
                                         textData:textData
                                     textDataSize:(unsigned int)textNSData.length];
    
    free(textData);
    
    blocking = NO;
}

- (IBAction)showHelp
{
    NSString *title = @"TEXT FORMATTING";
    NSString *helpText = [AppDelegate HTMLCSS];
    helpText = [helpText stringByAppendingString: @"<UnderlineTitle>Character Expansion Settings</UnderlineTitle><br/><br/>\n\
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

@end
