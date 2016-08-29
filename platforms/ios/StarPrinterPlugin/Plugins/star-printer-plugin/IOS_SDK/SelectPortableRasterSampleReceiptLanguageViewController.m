//
//  SelectPortableRasterSampleReceiptLanguageViewController.m
//  IOS_SDK
//
//  Created by u3237 on 2014/10/30.
//
//

#import "SelectPortableRasterSampleReceiptLanguageViewController.h"

#import "PrinterFunctions.h"
#import "AppDelegate.h"

@implementation SelectPortableRasterSampleReceiptLanguageViewController

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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Printer Width"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"2 inch", @"3 inch", @"4 inch", nil];
    p_selectedLanguage = SMLanguageRussian;
    [alertView show];
    [alertView release];
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Printer Width"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"2 inch", @"3 inch", @"4 inch", nil];
    p_selectedLanguage = SMLanguageSimplifiedChinese;
    [alertView show];
    [alertView release];
}

- (IBAction)printInTraditionalChinese:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Printer Width"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"2 inch", @"3 inch", @"4 inch", nil];
    p_selectedLanguage = SMLanguageTraditionalChinese;
    [alertView show];
    [alertView release];
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
    
    [PrinterFunctions PrintRasterSampleReceiptWithPortname:p_portName portSettings:p_portSettings paperWidth:p_selectedWidthInch Language:p_selectedLanguage];
    
    [self unblockView];
}
@end
