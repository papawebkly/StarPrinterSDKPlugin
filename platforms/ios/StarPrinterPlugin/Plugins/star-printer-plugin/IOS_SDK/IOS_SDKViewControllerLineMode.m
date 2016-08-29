//
//  IOS_SDKViewControllerLineMode.m
//  IOS_SDK
//
//  Created by Tzvi on 8/2/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import "AppDelegate.h"

#import "IOS_SDKViewControllerLineMode.h"

#import "PrinterFunctions.h"
#import "BarcodeSelector.h"
#import "BarcodeSelector2D.h"
#import "Cut.h"
#import "StandardHelp.h"
#import "SelectDesktopLineSampleReceiptLanguageViewController.h"
#import "SelectDesktopLineSampleReceiptUtf8LanguageViewController.h"
#import "SelectDesktopTextFormattingLanguageViewController.h"
#import "Utf8TextFormatting.h"

#import <QuartzCore/QuartzCore.h>

#import "AbstractActionSheetPicker.h"
#import "ActionSheetStringPicker.h"
#import <StarIO/SMPort.h>
#import <StarIO/SMBluetoothManager.h>
#import "CommonTableView.h"

#import "BluetoothSettingViewController.h"

typedef enum SMActionType {
    SMActionTypeSearchPrinter = 100,
    SMActionTypePrintReceipt = 101
} SMActionType;

@implementation IOS_SDKViewControllerLineMode

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (IBAction)pushButtonBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        array_port = [[NSArray alloc] initWithObjects:@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109", nil];
        /*arrayFunction = [[NSArray alloc] initWithObjects:@"Get Firmware Information", @"Get Status", @"Sample Receipt", @"Sample Receipt (UTF-8)", @"Open Cash Drawer 1", @"Open Cash Drawer 2",
                                                         @"1D Barcodes", @"2D Barcodes", @"Cut", @"Text Formatting", @"Text Formatting (UTF-8)", @"Bluetooth Pairing + Connect",
                                                         @"Bluetooth Disconnect", @"Bluetooth Setting", nil];
        */
        arrayFunction = [[NSArray alloc] initWithObjects:@"Get Firmware Information", @"Get Status", @"Sample Receipt", @"Sample Receipt (UTF-8)", @"Open Cash Drawer 1", @"Open Cash Drawer 2",
                         @"...", @"...", @"Cut", @"Text Formatting", @"Text Formatting (UTF-8)", @"Bluetooth Pairing + Connect",
                         @"Bluetooth Disconnect", @"Bluetooth Setting", nil];
        array_sensorActive = [[NSArray alloc] initWithObjects:@"High", @"Low", nil];
        array_sensorActive = [[NSArray alloc] initWithObjects:@"High", @"Low", nil];
        array_sensorActivePickerContents = [[NSArray alloc] initWithObjects:@"High When Drawer Open", @"Low When Drawer Open", nil];
    }
    return self;
}

- (void)dealloc
{
    [array_port release];
    [arrayFunction release];
    [array_sensorActive release];
    [array_sensorActivePickerContents release];
    [buttonBack release];
    [buttonPort release];
    [tableviewFunction release];
    [buttonHelp release];
    [buttonSearch release];
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
    [IOS_SDKViewControllerLineMode setPortName:localPortName];
    [IOS_SDKViewControllerLineMode setPortSettings:array_port[selectedPort]];
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

    tableviewFunction.dataSource = self;
    tableviewFunction.delegate = self;

    selectedPort = 0;
    selectedSensorActive = 0;

    [buttonPort setTitle:array_port[selectedPort] forState:UIControlStateNormal];
    [buttonSensorActive setTitle:array_sensorActive[selectedSensorActive] forState:UIControlStateNormal];
    
    [AppDelegate setButtonArrayAsOldStyle:@[buttonBack, buttonHelp, buttonPort, buttonSearch, buttonSensorActive]];
    
    uitextfield_portname.text = @"BT:Star Micronics";
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
    [self.view bringSubviewToFront:blockView];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [uitextfield_portname resignFirstResponder];
    
    [self setPortInfo];

    NSString *portName = [AppDelegate getPortName];
    NSString *portSettings = [AppDelegate getPortSettings];

    selectIndex = indexPath.row;
    
    switch (selectIndex)
    {
        case 0:
            [PrinterFunctions showFirmwareVersion:portName portSettings:portSettings];
            break;
            
        case 1:
            {
                SensorActive sensorSetting = (selectedSensorActive == 0) ? SensorActiveHigh : SensorActiveLow;

                [PrinterFunctions CheckStatusWithPortname:portName portSettings:portSettings sensorSetting:sensorSetting];
            }
            
            break;

        case 2:  // Sample Receipt
            {
                UIViewController *viewController
                    = [[SelectDesktopLineSampleReceiptLanguageViewController alloc] initWithNibName:@"SelectLanguageViewController" bundle:NSBundle.mainBundle];
                [self presentViewController:viewController animated:YES completion:nil];
                [viewController release];
            }
            break;

        case 3:  // Sample Receipt (UTF-8)
            {
                UIViewController *viewController
                    = [[SelectDesktopLineSampleReceiptUtf8LanguageViewController alloc] initWithNibName:@"SelectLanguageViewController" bundle:NSBundle.mainBundle];
                [self presentViewController:viewController animated:YES completion:nil];
                [viewController release];
            }
            break;
            
        case 4:
            [PrinterFunctions OpenCashDrawerWithPortname:portName portSettings:portSettings drawerNumber:1];
            break;
            
        case 5:
            [PrinterFunctions OpenCashDrawerWithPortname:portName portSettings:portSettings drawerNumber:2];
            break;
            
        case 6:
            {
                /*BarcodeSelector *barcodeSelector = [[BarcodeSelector alloc] initWithNibName:@"BarcodeSelector" bundle:[NSBundle mainBundle]];
                [self presentViewController:barcodeSelector animated:YES completion:nil];
                [barcodeSelector release];*/
            }
            break;
            
        case 7:
            {
                /*BarcodeSelector2D *barcodeSelector2d = [[BarcodeSelector2D alloc] initWithNibName:@"BarcodeSelector" bundle:[NSBundle mainBundle]];
                [self presentViewController:barcodeSelector2d animated:YES completion:nil];
                [barcodeSelector2d release];*/
            }
            break;
            
        case 8:
            {
                Cut *cut = [[Cut alloc] initWithNibName:@"Cut" bundle:[NSBundle mainBundle]];
                [self presentViewController:cut animated:YES completion:nil];
                [cut release];
            }
            break;
            
        case 9: // Text Formatting
            {
                UIViewController *vc =
                    [[SelectDesktopTextFormattingLanguageViewController alloc] initWithNibName:@"SelectLanguageViewController" bundle:NSBundle.mainBundle];
                [self presentViewController:vc animated:YES completion:nil];
                [vc release];
            }
            break;

        case 10: // Text Formatting (UTF-8)
            {
                UIViewController *vc =
                    [[Utf8TextFormatting alloc] initWithNibName:@"TextFormating" bundle:NSBundle.mainBundle];
                [self presentViewController:vc animated:YES completion:nil];
                [vc release];
            }
            break;
            
        case 11: // Bluetooth Pairing + Connect
            [EAAccessoryManager.sharedAccessoryManager showBluetoothAccessoryPickerWithNameFilter:nil completion:nil];
            break;

        case 12: // Bluetooth Disconnect
        {
            NSArray *devices = [[SMPort searchPrinter:@"BT:"] retain];
            
            NSMutableArray *supportedDevices = [NSMutableArray new];
            for (PortInfo *port in devices) {
                if ([port.modelName isEqualToString:@"SAC10"] ||        // DK-AirCash
                    [port.modelName isEqualToString:@"Star Micronics"]) { // POS Printer
                    [supportedDevices addObject:port];
                }
            }
            
            commonTableView = [[CommonTableView alloc] initWithNibName:@"CommonTableView"
                                                                bundle:[NSBundle mainBundle]
                                                               devices:supportedDevices
                                                              delegate:self
                                                                action:@selector(disconnect:)];
            [self presentViewController:commonTableView animated:YES completion:nil];
            
            [supportedDevices release];
            [devices release];
            [commonTableView release];
        }
        break;
            
        case 13: // Bluetooth Setting
        {
            SMBluetoothManager *manager = [[PrinterFunctions loadBluetoothSetting:portName portSettings:portSettings] retain];
            if (manager == nil) {
                break;
            }
            
            BluetoothSettingViewController *btSetting = [[BluetoothSettingViewController alloc] initWithNibName:@"BluetoothSettingViewController"
                                                                                                         bundle:[NSBundle mainBundle]
                                                                                               bluetoothManager:manager];
            [manager release];
            
            [self presentViewController:btSetting animated:YES completion:nil];
            
            [btSetting release];
            break;
        }
    }
    
    [self.view sendSubviewToBack:blockView];
}

- (void)disconnect:(PortInfo *)portInfo {
    if (portInfo != nil)
        [PrinterFunctions disconnectPort:portInfo.portName portSettings:@"" timeout:10000];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [uitextfield_portname resignFirstResponder];
    
    // Cancel
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    if (alertView.tag == SMActionTypeSearchPrinter) {
        NSArray *array = nil;
        switch (buttonIndex) {
            case 1: // LAN
                array = [[SMPort searchPrinter:@"TCP:"] retain];
                break;
                
            case 2: // Bluetooth
                array = [[SMPort searchPrinter:@"BT:"] retain];
                break;
                
            case 3: // All
                array = [[SMPort searchPrinter] retain];
                break;
        }
        
        searchView = [[SearchPrinterViewController alloc] initWithNibName:@"SearchPrinterViewController" bundle:nil];
        searchView.foundPrinters = array;
        searchView.delegate = self;
        [self presentViewController:searchView animated:YES completion:nil];
        [searchView release];
        [array release];
    }
}

#pragma mark -

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

#pragma mark Other methods

- (IBAction)pushButtonSearch:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Select Interface"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"LAN", @"Bluetooth", @"All", nil];
    alert.tag = SMActionTypeSearchPrinter;
    
    [alert show];
    [alert release];
}

- (IBAction)selectPort:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedPort = selectedIndex;
        
        [buttonPort setTitle:selectedValue forState:UIControlStateNormal];
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Port" rows:array_port initialSelection:selectedPort doneBlock:done cancelBlock:cancel origin:sender];
}

- (IBAction)selectSensorActive:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedSensorActive = selectedIndex;
        
        [buttonSensorActive setTitle:array_sensorActive[selectedIndex] forState:UIControlStateNormal];
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };
    
    [ActionSheetStringPicker showPickerWithTitle:@"Drawer Open Status" rows:array_sensorActivePickerContents initialSelection:selectedSensorActive doneBlock:done cancelBlock:cancel origin:sender];
}

- (IBAction)showHelp
{
    NSString *title = @"PORT PARAMETERS";
    
    NSString *helpText = [AppDelegate HTMLCSS];
    helpText = [helpText stringByAppendingString:@"<body>\
                 This program on supports ethernet and bluetooth interface.<br/>\
                 <Code>TCP:192.168.222.244</Code><br/>\
                 <It1>Enter IP address of Star Printer</It1><br/><br/>\
                 <Code>BT:Star Micronics</Code><br/>\
                 <It1>Enter iOS Port Name of Star Printer</It1><br/><br/>\
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
