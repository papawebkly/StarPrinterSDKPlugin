//
//  IOS_SDKViewControllerRasterMode.m
//  IOS_SDK
//
//  Created by Tzvi on 8/2/11.
//  Copyright 2011 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//



#import "IOS_SDKViewControllerRasterMode.h"

#import "PrinterFunctions.h"
#import "SelectDesktopRasterSampleReceiptLanguageViewController.h"
#import "Cut.h"
#import "rasterPrinting.h"
#import "StandardHelp.h"
#import "CommonTableView.h"
#import "ImageFilePrintingViewController.h"
#import "BluetoothSettingViewController.h"
#import "AllReceiptsViewController.h"

#import <StarIO/SMPort.h>
#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"
#import "AbstractActionSheetPicker.h"
#import "ActionSheetStringPicker.h"



typedef enum SMActionType {
    SMActionTypeSearchPrinter = 100,
    SMActionTypePrintReceipt = 101
} SMActionType;

@implementation IOS_SDKViewControllerRasterMode

- (id)init
{
    self = [super init];
    return self;
}

- (IBAction)pushButtonBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        array_port = [[NSArray alloc] initWithObjects:@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104",
                                                      @"9105", @"9106", @"9107", @"9108", @"9109", nil];
        arrayFunction = [[NSArray alloc] initWithObjects:@"Get Firmware Information", @"Get Status", @"Sample Receipt",
                                                         @"Open Cash Drawer 1", @"Open Cash Drawer 2",
                                                         @"Raster Graphics Text Printing", @"Image File Printing", 
                                                         @"AllReceipts", @"Bluetooth Pairing + Connect",
                                                         @"Bluetooth Disconnect", @"Bluetooth Setting", nil];
        array_sensorActive = [[NSArray alloc] initWithObjects:@"High", @"Low", nil];
        array_sensorActivePickerContents = [[NSArray alloc] initWithObjects:@"High When Drawer Open", @"Low When Drawer Open", nil];
    }
    
    return self;
}

- (void)dealloc
{
    [arrayFunction release];

    [uiview_block release];

    [uitextfield_portname release];
    [tableviewFunction release];
    [buttonBack release];
    
    [buttonPort release];
    [buttonSensorActive release];
    
    [array_port release];
    [array_sensorActive release];
    [array_sensorActivePickerContents release];

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
    [IOS_SDKViewControllerRasterMode setPortName:localPortName];

    [IOS_SDKViewControllerRasterMode setPortSettings:array_port[selectedPort]];
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
    tableviewFunction.delegate   = self;

    selectedPort = 0;
    selectedSensorActive = 0;

    [buttonPort setTitle:array_port[selectedPort] forState:UIControlStateNormal];
    [buttonSensorActive setTitle:array_sensorActive[selectedSensorActive] forState:UIControlStateNormal];
    
    uitextfield_portname.text = @"BT:Star Micronics";
    
    [AppDelegate setButtonArrayAsOldStyle:@[buttonBack, buttonHelp, buttonPort, buttonSearch, buttonSensorActive]];
}

#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayFunction.count;
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
    
    [uitextfield_portname resignFirstResponder];
    
    [self setPortInfo];

    NSString *portName = [AppDelegate getPortName];
    NSString *portSettings = [AppDelegate getPortSettings];

    selectIndex = indexPath.row;

    switch (selectIndex)
    {
        case 0:
        {
            [PrinterFunctions showFirmwareVersion:portName portSettings:portSettings];
            break;
        }
        case 1:
        {
            SensorActive sensorSetting = (selectedSensorActive == 0) ? SensorActiveHigh : SensorActiveLow;
        
            [PrinterFunctions CheckStatusWithPortname:portName portSettings:portSettings sensorSetting:sensorSetting];
            break;
        }
            
        case 2:
            {
                SelectDesktopRasterSampleReceiptLanguageViewController *vc
                    = [[SelectDesktopRasterSampleReceiptLanguageViewController alloc] initWithNibName:@"SelectLanguageViewController"
                                                                                               bundle:NSBundle.mainBundle];
                [vc hideDBCSDescription];
                [self presentViewController:vc animated:YES completion:nil];
                [vc release];
            }
            
            break;
            
        case 3:
            [PrinterFunctions OpenCashDrawerWithPortname:portName portSettings:portSettings drawerNumber:1];
            break;
            
        case 4:
            [PrinterFunctions OpenCashDrawerWithPortname:portName portSettings:portSettings drawerNumber:2];
            break;
            
        case 5:
        {
            rasterPrinting *rasterPrintingVar = [[rasterPrinting alloc] initWithNibName:@"rasterPrinting" bundle:[NSBundle mainBundle]];
            [self presentViewController:rasterPrintingVar animated:YES completion:nil];
            [rasterPrintingVar setOptionSwitch:NO];
            [rasterPrintingVar release];
            break;
        }
            
        case 6: // Image File Printing
        {
            ImageFilePrintingViewController *viewController = [[ImageFilePrintingViewController alloc] initWithNibName:@"ImageFilePrintingViewController" bundle:NSBundle.mainBundle];
            [self presentViewController:viewController animated:YES completion:nil];
            [viewController release];
            
            break;
        }
        
        case 7: // AllReceipts
        {
            id vc = [[AllReceiptsViewController alloc] initWithNibName:@"SelectLanguageViewController"
                                                                bundle:NSBundle.mainBundle
                                                             emulation:StarIoExtEmulationStarGraphic
                                                           printerType:SMPrinterTypeDesktopPrinterStarLine];
            [vc hideDBCSDescription];
            [self presentViewController:vc animated:YES completion:nil];
            [vc release];
            
            break;
        }
            
        case 8: // Bluetooth Pairing + Connect
            [EAAccessoryManager.sharedAccessoryManager showBluetoothAccessoryPickerWithNameFilter:nil completion:nil];
            break;
            
        case 9: // Bluetooth Disconnect
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
            
        case 10: // Bluetooth Setting
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
    
    [self.view sendSubviewToBack:uiview_block];
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
    if (buttonIndex == 0) {
        return;
    }

    if (alertView.tag == SMActionTypeSearchPrinter) // Search Printer
    {
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
