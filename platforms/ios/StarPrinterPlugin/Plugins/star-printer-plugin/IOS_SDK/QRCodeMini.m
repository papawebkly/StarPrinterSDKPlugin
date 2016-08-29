//
//  QRCodeMini.m
//  IOS_SDK
//
//  Created by Tzvi on 8/23/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import "AppDelegate.h"

#import "QRCodeMini.h"
#import <QuartzCore/QuartzCore.h>
#import "StandardHelp.h"

#import "MiniPrinterFunctions.h"

#import "PrinterFunctions.h"

#import "AbstractActionSheetPicker.h"
#import "ActionSheetStringPicker.h"

@implementation QRCodeMini

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        array_correction = [[NSArray alloc] initWithObjects:@"L 7%", @"M 15%", @"Q 25%", @"H 30%", nil];
        array_codeL = [[NSArray alloc] initWithObjects:@"Auto Size", @"19", @"34", @"55", @"80", @"108", @"136",
                       @"156", @"194", @"232", @"274", @"324", @"370", @"428", @"461", @"523", @"589", @"647", @"721",
                       @"795", @"861", @"932", @"1006", @"1094", @"1174", @"1276", @"1370", @"1468", @"1531", @"1631",
                       @"1735", @"1843", @"1955", @"2071", @"2191", @"2306", @"2434", @"2566", @"2702", @"2812", @"2956", nil];
        array_codeM = [[NSArray alloc] initWithObjects:@"Auto Size", @"16", @"28", @"44", @"64", @"86", @"108", @"124",
                       @"154", @"182", @"216", @"254", @"290", @"334", @"365", @"415", @"453", @"507", @"563", @"627", @"669",
                       @"714", @"782", @"860", @"914", @"1000", @"1062", @"1128", @"1193", @"1267", @"1373", @"1455", @"1541",
                       @"1631", @"1725", @"1812", @"1914", @"1992", @"2102", @"2216", @"2334", nil];
        array_codeQ = [[NSArray alloc] initWithObjects:@"Auto Size", @"13", @"22", @"34", @"48", @"62", @"76", @"88", @"110",
                       @"132", @"154", @"180", @"206", @"244", @"261", @"295", @"325", @"367", @"397", @"445", @"485", @"512", @"568",
                       @"614", @"664", @"718", @"754", @"808", @"871", @"911", @"985", @"1033", @"1115", @"1171", @"1231", @"1286", @"1354",
                       @"1426", @"1502", @"1582", @"1666", nil];
        array_codeH = [[NSArray alloc] initWithObjects:@"Auto Size", @"9", @"16", @"26", @"36", @"46", @"60", @"66", @"86", @"100",
                       @"122", @"140", @"158", @"180", @"197", @"223", @"253", @"283", @"313", @"341", @"385", @"406", @"442", @"464", @"514",
                       @"538", @"596", @"628", @"661", @"701", @"745", @"793", @"845", @"901", @"961", @"986", @"1054", @"1096", @"1142",
                       @"1222", @"1276", nil];
        array_module = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", nil];
    }
    
    return self;
}

- (void)dealloc
{
    [uiview_block release];
    [uitextfield_data release];
    [buttonCorrection release];
    [buttonCode release];
    [buttonModule release];
    [array_correction release];
    [array_codeL release];
    [array_codeM release];
    [array_codeQ release];
    [array_codeH release];
    [array_module release];
    
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

    selectedCorrection = 0;
    selectedCode       = 0;
    selectedModule     = 4;

    [buttonCorrection setTitle:array_correction[selectedCorrection] forState:UIControlStateNormal];
    [buttonCode       setTitle:array_codeL     [selectedCode]       forState:UIControlStateNormal];
//  [buttonCode       setTitle:array_codeM     [selectedCode]       forState:UIControlStateNormal];    // just same.
//  [buttonCode       setTitle:array_codeQ     [selectedCode]       forState:UIControlStateNormal];
//  [buttonCode       setTitle:array_codeH     [selectedCode]       forState:UIControlStateNormal];
    [buttonModule     setTitle:array_module    [selectedModule]     forState:UIControlStateNormal];
    
    [AppDelegate setButtonArrayAsOldStyle:@[buttonBack, buttonCode, buttonCorrection, buttonHelp, buttonModule, buttonPrint]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)backQRCode
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectCorrection:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedCorrection = selectedIndex;

        [buttonCorrection setTitle:selectedValue forState:UIControlStateNormal];
    };

    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };

    [ActionSheetStringPicker showPickerWithTitle:@"Select Correction" rows:array_correction initialSelection:selectedCorrection doneBlock:done cancelBlock:cancel origin:sender];
}

- (IBAction)selectCode:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedCode = selectedIndex;

        [buttonCode setTitle:selectedValue forState:UIControlStateNormal];
    };

    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };

    switch (selectedCorrection)
    {
        default : [ActionSheetStringPicker showPickerWithTitle:@"Select Code" rows:array_codeL initialSelection:selectedCode doneBlock:done cancelBlock:cancel origin:sender]; break;
        case 1  : [ActionSheetStringPicker showPickerWithTitle:@"Select Code" rows:array_codeM initialSelection:selectedCode doneBlock:done cancelBlock:cancel origin:sender]; break;
        case 2  : [ActionSheetStringPicker showPickerWithTitle:@"Select Code" rows:array_codeQ initialSelection:selectedCode doneBlock:done cancelBlock:cancel origin:sender]; break;
        case 3  : [ActionSheetStringPicker showPickerWithTitle:@"Select Code" rows:array_codeH initialSelection:selectedCode doneBlock:done cancelBlock:cancel origin:sender]; break;
    }
}

- (IBAction)selectModule:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedModule = selectedIndex;

        [buttonModule setTitle:selectedValue forState:UIControlStateNormal];
    };

    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };

    [ActionSheetStringPicker showPickerWithTitle:@"Select Module" rows:array_module initialSelection:selectedModule doneBlock:done cancelBlock:cancel origin:sender];
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
    NSString *title = @"QR CODE PRINTING";
    NSString *helpText = [AppDelegate HTMLCSS];
    helpText = [helpText stringByAppendingString: @"<UnderlineTitle>Set QR Code</UnderlineTitle><br/><br/>\n\
                <Code>ASCII:</Code> <CodeDef>GS Z STX</CodeDef><br/>\
                <Code>Hex:</Code> <CodeDef>1D 5A 02</CodeDef><br/><br/>\
                * Note: This code must be used before the other QR Code command.  It sets the printer to QR Code<br/><br/>\
                <UnderlineTitle>Print QR Code</UnderlineTitle><br/><br/>\
                <Code>ASCII:</Code> <CodeDef>ESC Z <StandardItalic>m n k dL dH d1 ... dk</StandardItalic></CodeDef><br/>\
                <Code>Hex:</Code> <CodeDef>1B 5A <StandardItalic>m n k dL dH d1 ... dk</StandardItalic></CodeDef><br/><br/>\
                <rightMov>m</rightMov> <rightMov_NOI>specifies verion symbol (1&#8804;m&#8804;40 or 0 is autosize) see manual for more information</rightMov_NOI><br/><br/><br/>\
                <rightMov>n</rightMov> <rightMov_NOI>specifies EC Level.  This value can be 4C, 4D, 51, or 48 in Hex.  It stands for L, M, Q, H respectively</rightMov_NOI><br/><br/><br/>\
                <rightMov>k</rightMov> <rightMov_NOI>specifies module size (1&#8804;k&#8804;8)</rightMov_NOI><br/><br/><br/>\
                <rightMov>dL</rightMov> <rightMov_NOI>Represents the lower byte describing the number of bytes in the QR Code.  Mathematically: dL = QR Code Length % 256</rightMov_NOI><br/><br/><br/><br/>\
                <rightMov>dH</rightMov> <rightMov_NOI>Represents the higher byte describing the number of bytes in the QR Code.  Mathematically: dH = QR Code Length / 256</rightMov_NOI><br/><br/><br/><br/>\
                <rightMov>d1 ... dk</rightMov> <rightMov_NOI2>This is the text that will be placed in the QR Code.</rightMov_NOI2>\
                </body></html>"];
    
    StandardHelp *helpVar = [[StandardHelp alloc]initWithNibName:@"StandardHelp" bundle:[NSBundle mainBundle]];
    [self presentViewController:helpVar animated:YES completion:nil];
    [helpVar release];
    
    [helpVar setHelpTitle:title];
    [helpVar setHelpText:helpText];
}

- (IBAction)printQRCode
{
    [self.view bringSubviewToFront:uiview_block];
    
    NSString *portName = [AppDelegate getPortName];
    NSString *portSettings = [AppDelegate getPortSettings];

    NSData *barcodeData = [uitextfield_data.text dataUsingEncoding:NSWindowsCP1252StringEncoding];

    unsigned char *barcodeBytes = (unsigned char *)malloc(barcodeData.length);
    [barcodeData getBytes:barcodeBytes length:barcodeData.length];

    CorrectionLevelOption correction = (CorrectionLevelOption)selectedCorrection;
    unsigned char         code       = selectedCode;
    unsigned char         module     = selectedModule + 1;

    [MiniPrinterFunctions PrintQrcodePortname:portName
                                 portSettings:portSettings
                        correctionLevelOption:correction
                                      ECLevel:code
                                   moduleSize:module
                                  barcodeData:barcodeBytes
                              barcodeDataSize:(unsigned int)barcodeData.length];

    free(barcodeBytes);
    
    [self.view sendSubviewToBack:uiview_block];
}

@end
