//
//  IOS_SDKViewControllerPortable.m
//  IOS_SDK
//
//  Created by Tzvi on 8/2/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import "AppDelegate.h"

#import "IOS_SDKViewControllerPortable.h"

#import <StarIO/SMPort.h>
#import "SelectPortableSampleReceiptLanguageViewController.h"
#import "PrinterFunctions.h"
#import "CheckConnectionViewController.h"
#import "BarcodeSelector.h"
#import "BarcodeSelector2D.h"
#import "Cut.h"
#import "TextFormating.h"
#import "rasterPrinting.h"
#import "StandardHelp.h"
#import "BarcodePrintingMini.h"
#import "TextFormatingMini.h"
#import "JpKnjFormatingMini.h"
#import "ImageFilePrintingMiniViewController.h"
#import "BluetoothSettingViewController.h"

#import "CommonEnum.h"


@implementation IOS_SDKViewControllerPortable

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (IBAction)pushButtonSearch:(id)sender {
    NSArray *array = [[SMPort searchPrinter:@"BT:"] retain];

    searchView = [[SearchPrinterViewController alloc] initWithNibName:@"SearchPrinterViewController" bundle:nil];
    searchView.foundPrinters = array;
    searchView.delegate = self;
    [array release];
    [self presentViewController:searchView animated:YES completion:nil];
    [searchView release];
}

- (IBAction)pushButtonBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        arrayFunction = [[NSArray alloc] initWithObjects:@"Get Firmware Information", @"Get Status", @"Check Connection", @"Sample Receipt",
                         @"1D Barcodes", @"2D Barcodes", @"Text Formatting", @"JP Kanji Text Formatting",
                         @"Raster Graphics Text Printing", @"Image File Printing", @"MSR", @"Bluetooth Setting", nil];
    }
    return self;
}

- (void)dealloc
{
    [arrayFunction release];
    
    [miniPrinterFunctions release];
    
    [uiview_block release];
    
    [uitextfield_portname release];
    [tableviewFunction release];
    [buttonSearch release];
    [buttonBack release];
    [buttonHelp release];

    [super dealloc];
}

+ (void)setPortName:(NSString *)m_portName
{
    [AppDelegate setPortName:m_portName];
}

+ (void)setPortSettings:(NSString *)m_portSettings
{
    [AppDelegate setPortSettings:m_portSettings];
}

- (void)setPortInfo
{
    NSString *localPortName = [NSString stringWithString: uitextfield_portname.text];
    [IOS_SDKViewControllerPortable setPortName:localPortName];
    
    NSString *localPortSettings = @"Portable;escpos";

    [IOS_SDKViewControllerPortable setPortSettings:localPortSettings];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    uitextfield_portname.delegate = self;
    
    miniPrinterFunctions = [[MiniPrinterFunctions alloc] init];
    
    tableviewFunction.dataSource = self;
    tableviewFunction.delegate = self;
    
    uitextfield_portname.text = @"BT:PRNT Star";
    
    [AppDelegate setButtonArrayAsOldStyle:@[buttonBack, buttonHelp, buttonSearch]];
}

#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayFunction count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    int index = (int)indexPath.row;
    cell.textLabel.text = arrayFunction[index];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view bringSubviewToFront:uiview_block];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    selectIndex = indexPath.row;
    
    [uitextfield_portname resignFirstResponder];
    
    [self setPortInfo];
    NSString *portName = [AppDelegate getPortName];
    NSString *portSettings = [AppDelegate getPortSettings];
    
    switch (selectIndex)
    {
        case 0:
            [MiniPrinterFunctions showFirmwareInformation:portName portSettings:portSettings];
            break;
            
        case 1:
            [MiniPrinterFunctions CheckStatusWithPortname:portName portSettings:portSettings sensorSetting:SensorActiveHigh];
            break;

        case 2:
        {
            CheckConnectionViewController *viewController = [[CheckConnectionViewController alloc] initWithNibName:@"CheckConnectionViewController" bundle:[NSBundle mainBundle]];
            [self presentViewController:viewController animated:YES completion:nil];
            [viewController release];
            
            break;
        }
        
        case 3: // Sample Receipt
        {
            UIViewController *vc = [[SelectPortableSampleReceiptLanguageViewController alloc] initWithNibName:@"SelectLanguageViewController" bundle:NSBundle.mainBundle];
            [self presentViewController:vc animated:YES completion:nil];
            [vc release];
            break;
        }
            
        case 4:
        {
            BarcodePrintingMini *barcodeMini = [[BarcodePrintingMini alloc] initWithNibName:@"BarcodePrintingMini" bundle:[NSBundle mainBundle]];
            [self presentViewController:barcodeMini animated:YES completion:nil];
            [barcodeMini release];
            
            break;
        }
            
        case 5:
        {
            BarcodeSelector2D *barcodeSelector2d = [[BarcodeSelector2D alloc] initWithNibName:@"BarcodeSelector" bundle:[NSBundle mainBundle]];
            [self presentViewController:barcodeSelector2d animated:YES completion:nil];
            [barcodeSelector2d release];
            
            break;
        }
            
        case 6:
        {
            TextFormatingMini *textformatingvar = [[TextFormatingMini alloc] initWithNibName:@"TextFormatingMini" bundle:[NSBundle mainBundle]];
            [self presentViewController:textformatingvar animated:YES completion:nil];
            [textformatingvar release];
            
            break;
        }
            
        case 7:
        {
            JpKnjFormatingMini *jpKnjformatingvar = [[JpKnjFormatingMini alloc] initWithNibName:@"JpKnjFormatingMini" bundle:[NSBundle mainBundle]];
            [self presentViewController:jpKnjformatingvar animated:YES completion:nil];
            [jpKnjformatingvar release];
            
            break;
        }
            
        case 8:
        {
            rasterPrinting *rasterPrintingVar = [[rasterPrinting alloc] initWithNibName:@"rasterPrinting" bundle:[NSBundle mainBundle]];
            [self presentViewController:rasterPrintingVar animated:YES completion:nil];
            [rasterPrintingVar setOptionSwitch:YES];
            [rasterPrintingVar release];
            break;
        }
            
        case 9: // Image File Printing
        {
            UIViewController *viewController = [[ImageFilePrintingMiniViewController alloc] initWithNibName:@"ImageFilePrintingViewController" bundle:NSBundle.mainBundle];
            [self presentViewController:viewController animated:YES completion:nil];
            [viewController release];
            break;
        }
            
        case 10:
            [miniPrinterFunctions MCRStartWithPortName:portName portSettings:portSettings];
            break;
            
        case 11: // Bluetooth Setting
        {
            NSInteger ret = [MiniPrinterFunctions hasBTSettingSupportWithPortName:portName portSettings:portSettings];
            if (ret != 0) {
                NSString *message = nil;
                switch (ret) {
                    case 1:
                        message = @"This function is supported only on Bluetooth or Bluetooth Low Energy.";
                        break;
                    case 2:
                        message = @"Failed to open port.";
                        break;
                    case 3:
                        message = @"This firmware does not support the Bluetooth setting function.";
                        break;
                    default:
                        return;
                }
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:message
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
                [alert show];
                [alert release];
                
                break;
            }
            
            SMBluetoothManager *manager = [[PrinterFunctions loadBluetoothSetting:portName portSettings:portSettings] retain];
            if (manager == nil) {
                break;
            }
            
            id vc = [[BluetoothSettingViewController alloc] initWithNibName:@"BluetoothSettingViewController"
                                                                     bundle:[NSBundle mainBundle]
                                                           bluetoothManager:manager];
            [manager release];
            
            [self presentViewController:vc animated:YES completion:nil];
            
            [vc release];
            break;
        }
            
    }
    
    [self.view sendSubviewToBack:uiview_block];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UITextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"] == YES)
    {
        [uitextfield_portname resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (IBAction)showHelp
{
    NSString *title = @"PORT PARAMETERS";
    
    NSString *helpText = [AppDelegate HTMLCSS];
    helpText = [helpText stringByAppendingString:@"<body>\
                 This program on supports Wireless LAN and bluetooth interface.<br/>\
                 <Code>TCP:192.168.222.244</Code><br/>\
                 <It1>Enter IP address of Star Printer</It1><br/><br/>\
                 <Code>BT:PRNT Star</Code><br/>\
                 <It1>Enter iOS Port Name of Star Portable Printer</It1><br/><br/>\
                 <LargeTitle><center>Port Settings</center></LargeTitle>\
                 <p>You should leave this blank for Desktop Printers. You should use 'portable' when connecting to a Portable Printers.</p>\
                 </body><html>"];
    
    StandardHelp *helpVar = [[StandardHelp alloc]initWithNibName:@"StandardHelp" bundle:[NSBundle mainBundle]];
    [self presentViewController:helpVar animated:YES completion:nil];
    [helpVar release];

    [helpVar setHelpTitle:title];
    [helpVar setHelpText:helpText];
}

- (void)returnSelectedCellText
{
    NSString *selectedPortName = [searchView lastSelectedPortName];
    
    if ((selectedPortName != nil) && ([selectedPortName isEqualToString:@""] == NO))
    {
        uitextfield_portname.text = selectedPortName;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
