//
//  IOS_SDKViewControllerPortableStarLine.m
//  IOS_SDK
//
//  Created by u3237 on 2014/10/28.
//
//

#import "IOS_SDKViewControllerPortableStarLine.h"
#import "AppDelegate.h"
#import "PrinterFunctions.h"
#import "BarcodeSelector.h"
#import "BarcodeSelector2D.h"
#import "StandardHelp.h"
#import "SelectPortableLineSampleReceiptLanguageViewController.h"
#import "SelectPortableLineTextFormattingViewController.h"
#import "BluetoothSettingViewController.h"
#import "CommonTableView.h"

#import <QuartzCore/QuartzCore.h>

#import <StarIO/SMPort.h>
#import <StarIO/SMBluetoothManager.h>

@interface IOS_SDKViewControllerPortableStarLine() {
    CommonTableView *commonTableView;
    PrinterFunctions *printerFunctions;
}

@end


@implementation IOS_SDKViewControllerPortableStarLine

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [arrayFunction release];
        arrayFunction = nil;
        arrayFunction = [[NSArray alloc] initWithObjects:@"Get Firmware Information", @"Get Status", @"Sample Receipt",
                                                         @"1D Barcodes", @"2D Barcodes", @"Text Formatting", @"MSR",
                                                         @"Bluetooth Setting", nil];
        printerFunctions = [PrinterFunctions new];
    }
    return self;
}

- (void)dealloc {
    [printerFunctions release];
    printerFunctions = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setPortInfo
{
    NSString *localPortName = [NSString stringWithString: uitextfield_portname.text];
    [AppDelegate setPortName:localPortName];
    
    [AppDelegate setPortSettings:@"Portable"];
}

#pragma mark UITableView


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [uitextfield_portname resignFirstResponder];
    
    [self setPortInfo];
    
    NSString *portName = [AppDelegate getPortName];
    NSString *portSettings = [AppDelegate getPortSettings];
    
    selectIndex = indexPath.row;
    
    switch (selectIndex) {
        case 0: // Get Firmware Information
            [PrinterFunctions showFirmwareVersion:portName portSettings:portSettings];
            break;
            
        case 1: // Get Status
            [PrinterFunctions CheckStatusWithPortname:portName portSettings:portSettings sensorSetting:NoDrawer];
            break;
            
        case 2:  // Sample Receipt
        {
            id vc = [[SelectPortableLineSampleReceiptLanguageViewController alloc] initWithNibName:@"SelectLanguageViewController" bundle:NSBundle.mainBundle];
            [self presentViewController:vc animated:YES completion:nil];
            [vc release];
        }
            break;
            
        case 3: { // 1D Barcodes
            id barcodeSelector = [[BarcodeSelector alloc] initWithNibName:@"BarcodeSelector" bundle:[NSBundle mainBundle]];
            [self presentViewController:barcodeSelector animated:YES completion:nil];
            [barcodeSelector release];
        }
            break;
            
        case 4: { // 2D Barcodes
            id barcodeSelector2d = [[BarcodeSelector2D alloc] initWithNibName:@"BarcodeSelector" bundle:[NSBundle mainBundle]];
            [self presentViewController:barcodeSelector2d animated:YES completion:nil];
            [barcodeSelector2d release];
        }
            break;
            
        case 5: {// Text Formatting
            id vc = [[SelectPortableLineTextFormattingViewController alloc] initWithNibName:@"SelectLanguageViewController" bundle:NSBundle.mainBundle];
            [self presentViewController:vc animated:YES completion:nil];
            [vc release];
        }
            break;
            
        case 6: // MSR
            [printerFunctions MCRStartWithPortName:portName portSettings:portSettings];
            break;
            
        case 7: { // Bluetooth Setting
            NSInteger ret = [PrinterFunctions hasBTSettingSupportWithPortName:portName portSettings:portSettings];
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
            
            BluetoothSettingViewController *btSetting = [[BluetoothSettingViewController alloc] initWithNibName:@"BluetoothSettingViewController"
                                                                                                         bundle:[NSBundle mainBundle]
                                                                                               bluetoothManager:manager];
            [manager release];
            
            [self presentViewController:btSetting animated:YES completion:nil];
            
            [btSetting release];
            break;
        }
    }
}


#pragma mark - IBAction (Override)

- (IBAction)pushButtonSearch:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Select Interface"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Bluetooth", @"Bluetooth Low Energy", @"All", nil];
    alert.tag = SMActionTypeSearch;
    [alert show];
    [alert release];
}

- (IBAction)showHelp
{
    NSString *title = @"PORT PARAMETERS";
    
    NSString *helpText = [AppDelegate HTMLCSS];
    helpText = [helpText stringByAppendingString:@"<body>\
                This program on supports ethernet, bluetooth, or bluetooth low energy interface.<br/>\
                <Code>TCP:192.168.222.244</Code><br/>\
                <It1>Enter IP address of Star Printer</It1><br/><br/>\
                <Code>BT:Star Micronics</Code><br/>\
                <It1>Enter iOS Port Name of Star Printer</It1><br/><br/>\
                <Code>BLE:STAR L200-00001</Code><br/>\
                <It1>Enter bluetooth device name of Star Printer</It1><br/><br/>\
                <LargeTitle><center>Port Settings</center></LargeTitle>\
                <p>You should leave this blank for Desktop Printers. You should use 'portable' when connecting to a Portable Printers.</p>\
                </body><html>"];
    
    StandardHelp *helpVar = [[StandardHelp alloc]initWithNibName:@"StandardHelp" bundle:[NSBundle mainBundle]];
    [self presentViewController:helpVar animated:YES completion:nil];
    [helpVar release];
    
    [helpVar setHelpTitle:title];
    [helpVar setHelpText:helpText];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [uitextfield_portname resignFirstResponder];
    
    // Cancel
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    switch (alertView.tag) {
        case SMActionTypeSearch: {
            
            NSArray *discoveredDevices = nil;
            if (buttonIndex == 1) { // Bluetooth
                discoveredDevices = [[SMPort searchPrinter:@"BT:"] retain];
            } else if (buttonIndex == 2) { // Bluetooth Low Energy
                discoveredDevices = [[SMPort searchPrinter:@"BLE:"] retain];
            } else if (buttonIndex == 3) { // All
                discoveredDevices = [[SMPort searchPrinter] retain];
            } else { // Invalid parameter
                return;
            }
            
            searchView = [[SearchPrinterViewController alloc] initWithNibName:@"SearchPrinterViewController" bundle:nil];
            searchView.foundPrinters = discoveredDevices;
            searchView.delegate = self;
            [discoveredDevices release];
            [self presentViewController:searchView animated:YES completion:nil];
            [searchView release];
            
            break;
        }
            
        default:
            break;
    }
}

@end
