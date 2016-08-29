//
//  SelectDesktopLineSampleReceiptUtf8LanguageViewController.m
//  IOS_SDK
//
//  Created by Yuichi Matsushita on 2015/06/29.
//
//

#import "SelectDesktopLineSampleReceiptUtf8LanguageViewController.h"

#import "PrinterFunctions.h"
#import "AppDelegate.h"


@implementation SelectDesktopLineSampleReceiptUtf8LanguageViewController

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
    self.SBCSLabel.text = @"Sample Receipt (UTF-8)";
    self.DBCSLabel.hidden = YES;
    self.descriptionLabel.text = @"These samples will require the correct UTF-8 character set to be loaded and a memory switch change to print correctly. \nPlease contact your local support to discuss.";
    
    CGFloat OFFSET = (-280.0);
    CGAffineTransform affineTransform = CGAffineTransformMakeTranslation(0.0, OFFSET);
    
    self.descriptionLabel.transform = affineTransform;
    
    OFFSET = (80.0);
    affineTransform = CGAffineTransformMakeTranslation(0.0, OFFSET);
    
    self.englishButton.transform = affineTransform;
    self.frenchButton.transform = affineTransform;
    self.portugueseButton.transform = affineTransform;
    self.spanishButton.transform = affineTransform;
    self.russianButton.transform = affineTransform;
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
                                              otherButtonTitles:@"3 inch", nil];
    p_selectedLanguage = SMLanguageEnglishUtf8;
    [alertView show];
    [alertView release];
}

- (IBAction)printInFrench:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Printer Width"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"3 inch", nil];
    p_selectedLanguage = SMLanguageFrenchUtf8;
    [alertView show];
    [alertView release];
}

- (IBAction)printInPortuguese:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Printer Width"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"3 inch", nil];
    p_selectedLanguage = SMLanguagePortugueseUtf8;
    [alertView show];
    [alertView release];
}

- (IBAction)printInSpanish:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Printer Width"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"3 inch", nil];
    p_selectedLanguage = SMLanguageSpanishUtf8;
    [alertView show];
    [alertView release];
}

- (IBAction)printInRussian:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Printer Width"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"3 inch", nil];
    p_selectedLanguage = SMLanguageRussianUtf8;
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
    p_selectedLanguage = SMLanguageJapaneseUtf8;
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
    p_selectedLanguage = SMLanguageSimplifiedChineseUtf8;
    [alertView show];
    [alertView release];
}

- (IBAction)printInTraditionalChinese:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Printer Width"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"3 inch", nil];
    p_selectedLanguage = SMLanguageTraditionalChineseUtf8;
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
