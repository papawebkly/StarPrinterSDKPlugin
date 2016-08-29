//
//  SelectDotMatrixSampleReceiptLanguageViewController.m
//  IOS_SDK
//
//  Created by u3237 on 2014/08/21.
//
//

#import "SelectDotMatrixSampleReceiptLanguageViewController.h"

#import "TextFormattingDotMatrixViewController.h"
#import "DotPrinterFunctions.h"
#import "AppDelegate.h"

@implementation SelectDotMatrixSampleReceiptLanguageViewController

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

- (IBAction)printInEnglish:(id)sender
{
    [self blockView];
    
    p_portName = [AppDelegate getPortName];
    p_portSettings = [AppDelegate getPortSettings];

    [DotPrinterFunctions printSampleReceiptWithPortName:p_portName
                                           portSettings:p_portSettings
                                             paperWidth:SMPaperWidth3inch
                                               language:SMLanguageEnglish];

    [self unblockView];
}

- (void)printInFrench:(id)sender
{
    [self blockView];
    
    p_portName = [AppDelegate getPortName];
    p_portSettings = [AppDelegate getPortSettings];
    
    [DotPrinterFunctions printSampleReceiptWithPortName:p_portName
                                           portSettings:p_portSettings
                                             paperWidth:SMPaperWidth3inch
                                               language:SMLanguageFrench];
    
    [self unblockView];
}

- (void)printInPortuguese:(id)sender
{
    [self blockView];
    
    p_portName = [AppDelegate getPortName];
    p_portSettings = [AppDelegate getPortSettings];
    
    [DotPrinterFunctions printSampleReceiptWithPortName:p_portName
                                           portSettings:p_portSettings
                                             paperWidth:SMPaperWidth3inch
                                               language:SMLanguagePortuguese];
    
    [self unblockView];
}

- (void)printInSpanish:(id)sender
{
    [self blockView];
    
    p_portName = [AppDelegate getPortName];
    p_portSettings = [AppDelegate getPortSettings];
    
    [DotPrinterFunctions printSampleReceiptWithPortName:p_portName
                                           portSettings:p_portSettings
                                             paperWidth:SMPaperWidth3inch
                                               language:SMLanguageSpanish];
    
    [self unblockView];
}

- (void)printInRussian:(id)sender
{
    [self blockView];
    
    p_portName = [AppDelegate getPortName];
    p_portSettings = [AppDelegate getPortSettings];
    
    [DotPrinterFunctions printSampleReceiptWithPortName:p_portName
                                           portSettings:p_portSettings
                                             paperWidth:SMPaperWidth3inch
                                               language:SMLanguageRussian];
    
    [self unblockView];
}

- (IBAction)printInJapanese:(id)sender
{
    [self blockView];
    
    p_portName = [AppDelegate getPortName];
    p_portSettings = [AppDelegate getPortSettings];

    [DotPrinterFunctions printSampleReceiptWithPortName:p_portName
                                           portSettings:p_portSettings
                                             paperWidth:SMPaperWidth3inch
                                               language:SMLanguageJapanese];

    [self unblockView];
}

- (IBAction)printInSimplifiedChinese:(id)sender
{
    [self blockView];
    
    p_portName = [AppDelegate getPortName];
    p_portSettings = [AppDelegate getPortSettings];
    
    [DotPrinterFunctions printSampleReceiptWithPortName:p_portName
                                           portSettings:p_portSettings
                                             paperWidth:SMPaperWidth3inch
                                               language:SMLanguageSimplifiedChinese];
    [self unblockView];
}

- (IBAction)printInTraditionalChinese:(id)sender
{
    [self blockView];
    
    p_portName = [AppDelegate getPortName];
    p_portSettings = [AppDelegate getPortSettings];
    
    [DotPrinterFunctions printSampleReceiptWithPortName:p_portName
                                           portSettings:p_portSettings
                                             paperWidth:SMPaperWidth3inch
                                               language:SMLanguageTraditionalChinese];
    [self unblockView];
}

@end
