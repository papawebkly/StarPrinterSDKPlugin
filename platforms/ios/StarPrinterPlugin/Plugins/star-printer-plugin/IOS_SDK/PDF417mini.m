//
//  PDF417mini.m
//  IOS_SDK
//
//  Created by Tzvi on 8/24/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import "AppDelegate.h"

#import "PDF417mini.h"
#import <QuartzCore/QuartzCore.h>
#import "StandardHelp.h"

#import "MiniPrinterFunctions.h"

#import "PrinterFunctions.h"

#import "AbstractActionSheetPicker.h"
#import "ActionSheetStringPicker.h"

@implementation PDF417mini

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        array_width = [[NSArray alloc] initWithObjects:@"0.125", @"0.25", @"0.375", @"0.5", @"0.625", @"0.75", @"0.875", @"1.0", nil];
        
        array_column = [[NSMutableArray alloc] init];
        for (int x = 1; x <= 30; x++)
        {
            NSString *value = [NSString stringWithFormat:@"%i", x];
            [array_column addObject:value];
        }
        
        array_security = [[NSArray alloc] initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", nil];
        array_ratio = [[NSArray alloc] initWithObjects:@"2", @"3", @"4", @"5", nil];
    }
    return self;
}

- (void)dealloc
{
    [uiview_block release];
    [uitextfield_data release];
    [buttonWidth release];
    [buttonColumn release];
    [buttonSecurity release];
    [buttonRatio release];
    [array_width release];
    [array_column release];
    [array_security release];
    [array_ratio release];

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

    uitextfield_data.delegate = self;

    selectedWidth    = 0;
    selectedColumn   = 0;
    selectedSecurity = 0;
    selectedRatio    = 0;

    [buttonWidth    setTitle:array_width   [selectedWidth]    forState:UIControlStateNormal];
    [buttonColumn   setTitle:array_column  [selectedColumn]   forState:UIControlStateNormal];
    [buttonSecurity setTitle:array_security[selectedSecurity] forState:UIControlStateNormal];
    [buttonRatio    setTitle:array_ratio   [selectedRatio]    forState:UIControlStateNormal];
    
    [AppDelegate setButtonArrayAsOldStyle:@[buttonBack, buttonColumn, buttonHelp, buttonPrint, buttonRatio, buttonSecurity, buttonWidth]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)backPDF417
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (IBAction)selectColumn:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedColumn = selectedIndex;

        [buttonColumn setTitle:selectedValue forState:UIControlStateNormal];
    };

    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };

    [ActionSheetStringPicker showPickerWithTitle:@"Select Column" rows:array_column initialSelection:selectedColumn doneBlock:done cancelBlock:cancel origin:sender];
}

- (IBAction)selectSecurity:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedSecurity = selectedIndex;

        [buttonSecurity setTitle:selectedValue forState:UIControlStateNormal];
    };

    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };

    [ActionSheetStringPicker showPickerWithTitle:@"Select Security" rows:array_security initialSelection:selectedSecurity doneBlock:done cancelBlock:cancel origin:sender];
}

- (IBAction)selectRatio:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedRatio = selectedIndex;

        [buttonRatio setTitle:selectedValue forState:UIControlStateNormal];
    };

    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };

    [ActionSheetStringPicker showPickerWithTitle:@"Select Ratio" rows:array_ratio initialSelection:selectedRatio doneBlock:done cancelBlock:cancel origin:sender];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"] == YES)
    {
        [uitextfield_data resignFirstResponder];
        return NO;
    }

    return YES;
}

- (IBAction)showHelp
{
    NSString *title = @"PDF417 PRINTING";
    NSString *helpText = [AppDelegate HTMLCSS];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        helpText = [helpText stringByAppendingString:@"<UnderlineTitle>Set PDF417</UnderlineTitle><br/><br/>\n\
                    <Code>ASCII:</Code> <CodeDef>GS Z NUL</CodeDef><br/>\
                    <Code>Hex:</Code> <CodeDef>1D 5A 00</CodeDef><br/><br/>\
                    * Note: This code must be used before the other PDF417 command.  It sets the printer to use PDF417 code<br/><br/>\
                    <UnderlineTitle>Print PDF417 codes</UnderlineTitle><br/><br/>\
                    <Code>ASCII:</Code> <CodeDef>ESC Z <StandardItalic>m n k dL dH d1 ... dk</StandardItalic></CodeDef><br/>\
                    <Code>Hex:</Code> <CodeDef>1B 5A <StandardItalic>m n k dL dH d1 ... dk</StandardItalic></CodeDef><br/><br/>\
                    <rightMov>m</rightMov> <rightMov_NOI>specifies column number (1&#8804;m&#8804;30) see manual for more information</rightMov_NOI><br/><br/>\
                    <rightMov>n</rightMov> <rightMov_NOI>specifies the security level (0&#8804;n&#8804;8)</rightMov_NOI><br/><br/>\
                    <rightMov>k</rightMov> <rightMov_NOI>defines the horizontal and vertical ratio (2&#8804;k&#8804;5)</rightMov_NOI><br/><br/>\
                    <rightMov>dL</rightMov> <rightMov_NOI>Represents the lower byte describing the number of bytes in the PDF417 code.  Mathematically: dL = PDF417 Length % 256</rightMov_NOI><br/><br/><br/><br/>\
                    <rightMov>dH</rightMov> <rightMov_NOI>Represents the higher byte describing the number of bytes in the PDF417 code.  Mathematically: dH = PDF417 Length / 256</rightMov_NOI><br/><br/><br/><br/>\
                    <rightMov>d1 ... dk</rightMov> <rightMov_NOI2>This is the text that will be placed in the PDF417 code.</rightMov_NOI2>\
                    </body></html>"];
    } else {
        helpText = [helpText stringByAppendingString:@"<UnderlineTitle>Set PDF417</UnderlineTitle><br/><br/>\n\
                    <Code>ASCII:</Code> <CodeDef>GS Z NUL</CodeDef><br/>\
                    <Code>Hex:</Code> <CodeDef>1D 5A 00</CodeDef><br/><br/>\
                    * Note: This code must be used before the other PDF417 command.  It sets the printer to use PDF417 code<br/><br/>\
                    <UnderlineTitle>Print PDF417 codes</UnderlineTitle><br/><br/>\
                    <Code>ASCII:</Code> <CodeDef>ESC Z <StandardItalic>m n k dL dH d1 ... dk</StandardItalic></CodeDef><br/>\
                    <Code>Hex:</Code> <CodeDef>1B 5A <StandardItalic>m n k dL dH d1 ... dk</StandardItalic></CodeDef><br/><br/>\
                    <rightMov>m</rightMov> <rightMov_NOI>specifies column number (1&#8804;m&#8804;30) see manual for more information</rightMov_NOI><br/><br/>\
                    <rightMov>n</rightMov> <rightMov_NOI>specifies the security level (0&#8804;n&#8804;8)</rightMov_NOI><br/><br/>\
                    <rightMov>k</rightMov> <rightMov_NOI>defines the horizontal and vertical ratio (2&#8804;k&#8804;5)</rightMov_NOI><br/><br/>\
                    <rightMov>dL</rightMov> <rightMov_NOI>Represents the lower byte describing the number of bytes in the PDF417 code.  Mathematically: dL = PDF417 Length % 256</rightMov_NOI><br/><br/><br/>\
                    <rightMov>dH</rightMov> <rightMov_NOI>Represents the higher byte describing the number of bytes in the PDF417 code.  Mathematically: dH = PDF417 Length / 256</rightMov_NOI><br/><br/><br/>\
                    <rightMov>d1 ... dk</rightMov> <rightMov_NOI2>This is the text that will be placed in the PDF417 code.</rightMov_NOI2>\
                    </body></html>"];
    }
    
    StandardHelp *helpVar = [[StandardHelp alloc]initWithNibName:@"StandardHelp" bundle:[NSBundle mainBundle]];
    [self presentViewController:helpVar animated:YES completion:nil];
    [helpVar release];
    
    [helpVar setHelpTitle:title];
    [helpVar setHelpText:helpText];
}

- (IBAction)printPDF417
{
    [self.view bringSubviewToFront:uiview_block];
    
    NSString *portName = [AppDelegate getPortName];
    NSString *portSettings = [AppDelegate getPortSettings];

    NSData *barcodeData = [uitextfield_data.text dataUsingEncoding:NSWindowsCP1252StringEncoding];

    unsigned char *barcodeBytes = (unsigned char *)malloc(barcodeData.length);
    [barcodeData getBytes:barcodeBytes length:barcodeData.length];

    BarcodeWidth  width    = (BarcodeWidth)selectedWidth;
    int           column   = (int)(selectedColumn + 1);
    unsigned char security = (unsigned char)selectedSecurity;
    unsigned char ratio    = (unsigned char)(selectedRatio + 2);

    [MiniPrinterFunctions PrintPDF417WithPortname:portName
                                     portSettings:portSettings
                                            width:width
                                     columnNumber:column
                                    securityLevel:security
                                            ratio:ratio
                                      barcodeData:barcodeBytes
                                  barcodeDataSize:barcodeData.length];

    free(barcodeBytes);
    
    [self.view sendSubviewToBack:uiview_block];
}

@end
