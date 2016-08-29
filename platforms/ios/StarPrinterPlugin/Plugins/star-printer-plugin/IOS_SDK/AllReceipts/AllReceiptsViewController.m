//
//  AllReceiptsViewController.m
//  IOS_SDK
//
//  Created by u3237 on 2016/02/22.
//
//

#import "AllReceiptsViewController.h"
#import <SMCloudServices/SMCloudServices.h>
#import <SMCloudServices/SMCSAllReceipts.h>
#import <CoreImage/CoreImage.h>
#import "AppDelegate.h"
#import "PrinterFunctions.h"
#import "MiniPrinterFunctions.h"

@interface AllReceiptsViewController()

@property(retain, nonatomic) UIAlertView *alert;
@property(assign, nonatomic) SMLanguage selectedLanguage;
@property(assign, readonly, nonatomic) StarIoExtEmulation emulation;
@property(assign, readonly, nonatomic) SMPrinterType printerType;

@end

@implementation AllReceiptsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil
                      emulation:(StarIoExtEmulation)emulation
                    printerType:(SMPrinterType)printerType
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _emulation = emulation;
        _printerType = printerType;
        
        switch (printerType) {
            case SMPrinterTypeDesktopPrinterStarLine:
                self.alert = [[UIAlertView alloc] initWithTitle:@"Paper Width"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"3 inch", @"4 inch", nil];
                break;
            case SMPrinterTypePortablePrinterStarLine:
                self.alert = [[UIAlertView alloc] initWithTitle:@"PaperWidth"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"2 inch", @"3 inch", @"4 inch", nil];
                break;
            default:
                [self release];
                return nil;
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshUIWithRegistered:[SMCloudServices isRegistered]];
}

- (void)refreshUIWithRegistered:(BOOL)registered {
    self.cloudServiceButton.hidden = NO;
    
    for (UIButton *btn in self.printButtons) {
        btn.enabled = registered;
    }
    
    if (registered) {
        [self stopAnimation];
        self.cloudServiceButton.titleLabel.textColor = self.englishButton.titleLabel.textColor;
    } else {
        [self startAnimation];
        self.cloudServiceButton.titleLabel.textColor = [UIColor redColor];
    }
}

- (void)dealloc {
    [_alert release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)startAnimation {
    [UIView beginAnimations:nil context:nil];
    
    self.cloudServiceButton.alpha = 0.0;
    
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationDuration:0.6];
    [UIView setAnimationRepeatCount:UINT32_MAX];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    self.cloudServiceButton.alpha = 1.0;
    
    [UIView commitAnimations];
}

- (void)stopAnimation {
    [self.cloudServiceButton.layer removeAllAnimations];
}

#pragma mark - Override


- (IBAction)printInEnglish:(id)sender {
    self.selectedLanguage = SMLanguageEnglish;
    [self.alert show];
}

- (IBAction)printInFrench:(id)sender {
    self.selectedLanguage = SMLanguageFrench;
    [self.alert show];
}

- (IBAction)printInPortuguese:(id)sender {
    self.selectedLanguage = SMLanguagePortuguese;
    [self.alert show];
}

- (IBAction)printInSpanish:(id)sender {
    self.selectedLanguage = SMLanguageSpanish;
    [self.alert show];
}

- (IBAction)printInRussian:(id)sender {
    self.selectedLanguage = SMLanguageRussian;
    [self.alert show];
}

- (IBAction)printInJapanese:(id)sender {
    self.selectedLanguage = SMLanguageJapanese;
    [self.alert show];
}

- (IBAction)printInTraditionalChinese:(id)sender {
    self.selectedLanguage = SMLanguageTraditionalChinese;
    [self.alert show];
}

- (IBAction)printInSimplifiedChinese:(id)sender {
    self.selectedLanguage = SMLanguageSimplifiedChinese;
    [self.alert show];
}

- (void)showLoginDialog:(id)sender {
    [SMCloudServices showRegistrationView:^(BOOL isRegistration) {
        [self refreshUIWithRegistered:isRegistration];
    }];
}

#pragma mark Delegate methods

- (void)        alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    [self blockView];

    // Paper Width
    SMPaperWidth paperWidth = SMPaperWidth2inch;
    switch (self.printerType) {
        case SMPrinterTypeDesktopPrinterStarLine:
            switch (buttonIndex) {
                case 1:
                    paperWidth = SMPaperWidth3inch;
                    break;
                case 2:
                    paperWidth = SMPaperWidth4inch;
                    break;
            }
            break;
        case SMPrinterTypePortablePrinterStarLine:
            switch (buttonIndex) {
                case 1:
                    paperWidth = SMPaperWidth2inch;
                    break;
                case 2:
                    paperWidth = SMPaperWidth3inch;
                    break;
                case 3:
                    paperWidth = SMPaperWidth4inch;
                    break;
            }
            break;

        default:
            [self unblockView];
            return;
    }
    
    UIImage *image = [PrinterFunctions rasterSampleReceiptImageWithLanguage:self.selectedLanguage
                                                                 paperWidth:paperWidth];
    if (!image) {
        [self unblockView];
        NSLog(@"image is nil");
        return;
    }
    
    NSString *portName = [AppDelegate getPortName];
    NSString *portSettings = [AppDelegate getPortSettings];
    
    // Upload
    NSString *urlString = [SMCSAllReceipts uploadBitmap:image
                                             completion:^(NSInteger statusCode, NSError *error) {
                                                 NSLog(@"%ld %@", (long)statusCode, error);
                                             }];
    
    // Generate command
    ISCBBuilder *builder = [StarIoExt createCommandBuilder:self.emulation];
    
    [builder beginDocument];
    
    [builder appendBitmap:image diffusion:NO];
    
    [builder.commands appendData:[SMCSAllReceipts generateAllReceipts:urlString
                                                            emulation:self.emulation
                                                                 info:YES
                                                               qrCode:YES]];
    
    [builder appendCutPaper:SCBCutPaperActionPartialCutWithFeed];
    
    [builder endDocument];
    
    // Print
    [PrinterFunctions sendCommand:builder.commands
                         portName:portName
                     portSettings:portSettings
                    timeoutMillis:10000];
    
    [self unblockView];
}


@end
