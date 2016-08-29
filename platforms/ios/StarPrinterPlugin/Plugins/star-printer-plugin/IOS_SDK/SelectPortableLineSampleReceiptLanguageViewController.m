//
//  SelectPortableLineSampleReceiptLanguageViewController.m
//  IOS_SDK
//
//  Created by u3237 on 2014/10/29.
//
//

#import "SelectPortableLineSampleReceiptLanguageViewController.h"
#import "PrinterFunctions.h"
#import "AppDelegate.h"


@implementation SelectPortableLineSampleReceiptLanguageViewController

#pragma mark button action

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.traditionalChineseButton.hidden = YES;
    
    self.descriptionLabel.text = @"These samples will require the correct DBCS character set to be loaded.";
}

- (IBAction)printInEnglish:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Printer Width"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"2 inch", @"3 inch", @"4 inch", nil];
    p_selectedLanguage = SMLanguageEnglish;
    [alertView show];
    [alertView release];
}

- (IBAction)printInFrench:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Printer Width"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"2 inch", @"3 inch", @"4 inch", nil];
    p_selectedLanguage = SMLanguageFrench;
    [alertView show];
    [alertView release];
}

- (IBAction)printInPortuguese:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Printer Width"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"2 inch", @"3 inch", @"4 inch", nil];
    p_selectedLanguage = SMLanguagePortuguese;
    [alertView show];
    [alertView release];
}

- (IBAction)printInSpanish:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Printer Width"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"2 inch", @"3 inch", @"4 inch", nil];
    p_selectedLanguage = SMLanguageSpanish;
    [alertView show];
    [alertView release];
}

- (IBAction)printInRussian:(id)sender
{
    [self blockView];
    
    p_portName = [AppDelegate getPortName];
    p_portSettings = [AppDelegate getPortSettings];

    NSData *commands = [[PrinterFunctions sampleReceiptWithPaperWidth:SMPaperWidth2inch
                                                             language:SMLanguageRussian
                                                           kickDrawer:NO] retain];
    
    [PrinterFunctions sendCommand:commands portName:p_portName portSettings:p_portSettings timeoutMillis:10000];
    
    [commands release];
    
    [self unblockView];
}

- (IBAction)printInJapanese:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Printer Width"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"2 inch", @"3 inch", @"4 inch", nil];
    p_selectedLanguage = SMLanguageJapanese;
    [alertView show];
    [alertView release];
}

- (IBAction)printInSimplifiedChinese:(id)sender
{
    [self blockView];
    
    p_portName = [AppDelegate getPortName];
    p_portSettings = [AppDelegate getPortSettings];
    
    NSData *commands = [[PrinterFunctions sampleReceiptWithPaperWidth:SMPaperWidth2inch
                                                             language:SMLanguageSimplifiedChinese
                                                           kickDrawer:NO] retain];
    
    [PrinterFunctions sendCommand:commands portName:p_portName portSettings:p_portSettings timeoutMillis:10000];
    
    [commands release];
    
    [self unblockView];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    [self blockView];
    
    p_portName = [AppDelegate getPortName];
    p_portSettings = [AppDelegate getPortSettings];
    
    switch (buttonIndex) {
        case 1:
            p_selectedWidthInch = SMPaperWidth2inch;
            break;

        case 2:
            p_selectedWidthInch = SMPaperWidth3inch;
            break;
            
        case 3:
            p_selectedWidthInch = SMPaperWidth4inch;
            break;
    }

    NSData *commands = [[PrinterFunctions sampleReceiptWithPaperWidth:p_selectedWidthInch language:p_selectedLanguage kickDrawer:NO] retain];
    
    [PrinterFunctions sendCommand:commands portName:p_portName portSettings:p_portSettings timeoutMillis:10000];
    
    [commands release];
    
    [self unblockView];
}

@end
