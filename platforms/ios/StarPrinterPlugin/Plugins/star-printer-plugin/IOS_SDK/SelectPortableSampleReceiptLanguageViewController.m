//
//  SelectPortableSampleReceiptLanguageViewController.m
//  IOS_SDK
//
//  Created by u3237 on 2014/08/21.
//
//

#import "SelectPortableSampleReceiptLanguageViewController.h"

#import "MiniPrinterFunctions.h"
#import "AppDelegate.h"


@implementation SelectPortableSampleReceiptLanguageViewController

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

    self.simplifiedChineseButton.hidden = YES;
    self.traditionalChineseButton.frame = self.simplifiedChineseButton.frame;
    self.russianButton.hidden = YES;
    
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
        default:
            break;
    }

    [MiniPrinterFunctions printSampleReceiptWithPortname:p_portName portSettings:p_portSettings paperWidth:p_selectedWidthInch language:p_selectedLanguage];
    
    [self unblockView];
}

@end
