//
//  SelectDesktopSampleReceiptLanguageViewController.m
//  IOS_SDK
//
//  Created by u3237 on 2014/08/21.
//
//

#import "SelectDesktopLineSampleReceiptLanguageViewController.h"

#import "PrinterFunctions.h"
#import "AppDelegate.h"


@implementation SelectDesktopLineSampleReceiptLanguageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark button action

- (IBAction)printInEnglish:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Printer Width"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"3 inch", @"4 inch", nil];
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
                                              otherButtonTitles:@"3 inch", @"4 inch", nil];
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
                                              otherButtonTitles:@"3 inch", @"4 inch", nil];
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
                                              otherButtonTitles:@"3 inch", @"4 inch", nil];
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
                                              otherButtonTitles:@"3 inch", @"4 inch", nil];
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
                                              otherButtonTitles:@"3 inch", @"4 inch", nil];
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
                                              otherButtonTitles:@"3 inch", @"4 inch", nil];
    p_selectedLanguage = SMLanguageSimplifiedChinese;
    [alertView show];
    [alertView release];
}

- (IBAction)printInTraditionalChinese:(id)sender
{
    [self blockView];
    
    p_portName = [AppDelegate getPortName];
    p_portSettings = [AppDelegate getPortSettings];
    
    

    NSData *commands = [[PrinterFunctions sampleReceiptWithPaperWidth:SMPaperWidth3inch
                                                             language:SMLanguageTraditionalChinese
                                                           kickDrawer:YES] retain];
    
    [PrinterFunctions sendCommand:commands
                         portName:p_portName
                     portSettings:p_portSettings
                    timeoutMillis:10000];
    
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
            p_selectedWidthInch = SMPaperWidth3inch;
            break;
            
        case 2:
            p_selectedWidthInch = SMPaperWidth4inch;
            break;
    }
    
    NSData *commands = [[PrinterFunctions sampleReceiptWithPaperWidth:p_selectedWidthInch
                                                             language:p_selectedLanguage
                                                           kickDrawer:YES] retain];
    if (commands == nil) {
        return;
    }
    
    [PrinterFunctions sendCommand:commands
                         portName:p_portName
                     portSettings:p_portSettings
                    timeoutMillis:10000];

    [commands release];
    
    [self unblockView];
}
@end
