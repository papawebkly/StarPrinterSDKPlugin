//
//  IOS_SDKViewControllerDKAirCash.m
//  IOS_SDK
//
//  Created by u3237 on 13/06/07.
//
//

#import "IOS_SDKViewControllerDKAirCash.h"
#import "PrinterFunctions.h"
#import "MiniPrinterFunctions.h"
#import "DKAirCashFunctions.h"
#import <StarIO/SMPort.h>
#import <StarIO/SMBluetoothManager.h>

#import "AbstractActionSheetPicker.h"
#import "ActionSheetStringPicker.h"
#import "AppDelegate.h"
#import "CommonTableView.h"
#import "StandardHelp.h"
#import "BluetoothSettingViewController.h"

typedef enum _stage {
    SEARCH_PRINTER = 200,
    SEARCH_DK_AIRCASH,
    PRINT_SAMPLE_RECEIPT,
    WAIT_PIN,
    WAIT_DRAWER_OPEN_ONLY,
    WAIT_DRAWER_OPEN_AND_CLOSE,
    COMPLETE
} Action;

static NSString* const CORRECT_PASSWORD = @"1234";

@interface IOS_SDKViewControllerDKAirCash() {
    NSString *p_portSettings;
}

@end

@implementation IOS_SDKViewControllerDKAirCash

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        functions = [[NSArray alloc] initWithObjects:@"Get DK-AirCash Firmware Information", @"Get DK-AirCash Dip Switch Information", @"Get Printer Status",
                                                     @"Get DK-AirCash Status", @"Sample Receipt + Open Cash Drawer1 via DK-AirCash", @"Open Cash Drawer1 via DK-AirCash", @"Open Cash Drawer2 via DK-AirCash",
                                                     @"Bluetooth Pairing + Connect", @"Bluetooth Disconnect", @"DK-AirCash Bluetooth Setting", nil];
        ports = [[NSArray alloc] initWithObjects:@"Standard", @"9100", @"9101", @"9102", @"9103",
                                                 @"9104", @"9105", @"9106", @"9107", @"9108",
                                                 @"9109", nil];
        printerTypes = [[NSArray alloc] initWithObjects:@"POS Printer", @"Portable Printer (Star Line)", @"Portable Printer (ESC/POS)", nil];
        LANTypes = [[NSArray alloc] initWithObjects:@"Wired", @"Wireless", nil];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableviewFunction.delegate = self;
    _tableviewFunction.dataSource = self;
    _uitextfield_drawerPortName.delegate = self;
    _uitextfield_printerPortName.delegate = self;
    
    selectedPort = 0;
    selectedPrinterType = 0;
    selectedLANType = 0;
    selectedDrawer = 0;
    
    [portNumberButton setTitle:ports[selectedPort] forState:UIControlStateNormal];
    [printerTypeButton setTitle:printerTypes[selectedPrinterType] forState:UIControlStateNormal];
    [LANTypeButton setTitle:LANTypes[selectedLANType] forState:UIControlStateNormal];
    
    self.uitextfield_printerPortName.text = @"TCP:192.168.1.10";
    self.uitextfield_drawerPortName.text = @"TCP:192.168.1.11";
    printerTypeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    pinSecurityEnable = securitySwitch.on;
    
    [AppDelegate setButtonArrayAsOldStyle:@[portNumberButton, printerTypeButton, searchButton, drawerSearchButton, LANTypeButton, backButton, helpButton]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_tableviewFunction release];
    [_uitextfield_printerPortName release];
    [_uitextfield_drawerPortName release];
    
    [functions release];
    [ports release];
    [printerTypes release];
    [LANTypes release];

    [portNumberButton release];
    [printerTypeButton release];
    [searchButton release];
    [drawerSearchButton release];
    [backButton release];
    [helpButton release];
    [securitySwitch release];
    [LANTypeButton release];
    [super dealloc];
}

#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return functions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    cell.textLabel.text = functions[indexPath.row];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:16.5];
    
    if (indexPath.row == 4) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            cell.textLabel.text = @"Sample Receipt +\nOpen Cash Drawer1 via DK-AirCash";
            cell.textLabel.numberOfLines = 0;
        }
    } else {
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view bringSubviewToFront:blockView];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self setPortInfo];
    
    NSString *printerPortName = [AppDelegate getPortName];
    NSString *printerPortSettings = [AppDelegate getPortSettings];
    NSString *drawerPortName = [AppDelegate getDrawerPortName];
    NSString *drawerPortSettings = @"";
    if (selectedLANType == 1) {
        drawerPortSettings = [NSString stringWithFormat:@"%@, WL", drawerPortSettings];
    }
    
    switch (indexPath.row) {
        case 0: // Show Firmware Information
            [DKAirCashFunctions showFirmwareInformation:drawerPortName portSettings:drawerPortSettings];
            break;
            
        case 1: // Get DK-AirCash Dip Switch Information
            [DKAirCashFunctions showDipSwitchInformation:drawerPortName portSettings:drawerPortSettings];
            break;

        case 2: // Get Printer Status;
            if (selectedPort == 0) {
                [PrinterFunctions CheckStatusWithPortname:printerPortName
                                             portSettings:printerPortSettings
                                            sensorSetting:NoDrawer];
            }
            else {
                [MiniPrinterFunctions CheckStatusWithPortname:printerPortName
                                                 portSettings:printerPortSettings
                                                sensorSetting:NoDrawer];
            }
            break;
            
        case 3: // Get Cash Drawer Status
            [DKAirCashFunctions CheckStatusWithPortname:drawerPortName portSettings:drawerPortSettings];
            break;
            
        case 4: // Sample Receipt + Open Cash Drawer
        {
            UIAlertView *alertView = nil;
            if (selectedPrinterType == 0) { // Desktop printer
                alertView = [[UIAlertView alloc] initWithTitle:@"Paper Width"
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"3 inch", @"4 inch", nil];
            } else { // Portable printer
                alertView = [[UIAlertView alloc] initWithTitle:@"Paper Width"
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"2 inch", @"3 inch", @"4 inch", nil];
            }
            
            alertView.tag = PRINT_SAMPLE_RECEIPT;
            
            [alertView show];
            [alertView release];

            break;
        }
            
        case 5: // Open Cash Drawer 1
        {
            selectedDrawer = 1;
            
            if (securitySwitch.on)
            {
                [[self pinCodeDialogWithAction:WAIT_DRAWER_OPEN_ONLY] show];
            }
            else
            {
                [DKAirCashFunctions OpenCashDrawerWithPortname:drawerPortName
                                                  portSettings:drawerPortSettings
                                                  drawerNumber:selectedDrawer];
            }

            break;
        }
            
        case 6: // Open Cash Drawer 2
        {
            selectedDrawer = 2;
            if (securitySwitch.on)
            {
                [[self pinCodeDialogWithAction:WAIT_DRAWER_OPEN_ONLY] show];
            }
            else
            {
                [DKAirCashFunctions OpenCashDrawerWithPortname:drawerPortName
                                                  portSettings:drawerPortSettings
                                                  drawerNumber:selectedDrawer];
            }
            
            break;
        }
            
        case 7: // Bluetooth Pairing + Connect
            [EAAccessoryManager.sharedAccessoryManager showBluetoothAccessoryPickerWithNameFilter:nil completion:nil];
            break;

        case 8: // Bluetooth Disconnect
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
            
        case 9: // DK-AirCash Bluetooth Setting
        {
            SMBluetoothManager *manager = [[PrinterFunctions loadBluetoothSetting:drawerPortName portSettings:@""] retain];
            if (manager == nil) {
                break;
            }
            
            BluetoothSettingViewController *btSetting = [[BluetoothSettingViewController alloc] initWithNibName:@"BluetoothSettingViewController"
                                                                                                         bundle:[NSBundle mainBundle]
                                                                                               bluetoothManager:manager];
            [manager release];
            
            [self presentViewController:btSetting animated:YES completion:nil];
            
            [btSetting release];
        }
            break;
    }
    
    [self.view sendSubviewToBack:blockView];
}


#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *drawerPortName = [AppDelegate getDrawerPortName];
    
    if (alertView.cancelButtonIndex == buttonIndex) {
        return;
    }
    
    NSString *drawerPortSettings = @"";
    if (selectedLANType == 1) {
        drawerPortSettings = [NSString stringWithFormat:@"%@, WL", drawerPortSettings];
    }
    
    //
    // Search Printer and DK-AirCash
    //
    switch (alertView.tag) {
        case PRINT_SAMPLE_RECEIPT:
        {
            NSString *printerPortName = [AppDelegate getPortName];
            NSString *printerPortSettings = [AppDelegate getPortSettings];
            int selectedWidthIndex = (int)buttonIndex;
            
            //
            // Sample Receipt
            //
            NSMutableString *errorMessage = [NSMutableString new];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@""
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            alert.tag = WAIT_PIN;

            SMPaperWidth paperWidth = SMPaperWidth2inch;
            switch (selectedPrinterType) {
                case 0: // Desktop Printer
                    switch (selectedWidthIndex) {
                        case 1: // 3 inch
                            paperWidth = SMPaperWidth3inch;
                            break;
                        case 2: // 4 inch
                            paperWidth = SMPaperWidth4inch;
                            break;
                        default:
                            [errorMessage release];
                            return;
                    }
                    
                    [PrinterFunctions printSampleReceiptWithoutDrawerKickWithPortname:printerPortName
                                                                         portSettings:printerPortSettings
                                                                           paperWidth:paperWidth
                                                                         errorMessage:errorMessage];
                    break;
                case 1: // Portable Printer (Star Line)
                    switch (selectedWidthIndex) {
                        case 1: // 2 inch
                            paperWidth = SMPaperWidth2inch;
                            break;
                        case 2: // 3 inch
                            paperWidth = SMPaperWidth3inch;
                            break;
                        case 3: // 4 inch
                            paperWidth = SMPaperWidth4inch;
                            break;
                    }
                    
                    [PrinterFunctions printSampleReceiptWithoutDrawerKickWithPortname:printerPortName
                                                                         portSettings:printerPortSettings
                                                                           paperWidth:paperWidth
                                                                         errorMessage:errorMessage];
                    break;
                case 2: // Portable Printer (ESC/POS)
                    switch (selectedWidthIndex) {
                        case 1: // 2 inch
                            paperWidth = SMPaperWidth2inch;
                            break;
                        case 2: // 3 inch
                            paperWidth = SMPaperWidth3inch;
                            break;
                        case 3:
                            paperWidth = SMPaperWidth4inch;
                            break;
                    }
                    
                    [MiniPrinterFunctions PrintSampleReceiptWithPortname:printerPortName
                                                            portSettings:printerPortSettings
                                                              paperWidth:paperWidth
                                                            errorMessage:errorMessage];
                    break;
            }
            
            if (errorMessage.length > 0) {
                alert.message = errorMessage;
                [alert show];
                [alert release];
                [errorMessage release];
                return;
            }
            [errorMessage release];
            [alert release];
            
            [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
            
            selectedDrawer = 1;
            if (securitySwitch.on) {
                [[self pinCodeDialogWithAction:WAIT_DRAWER_OPEN_AND_CLOSE] show];
            }
            else
            {
                NSString *drawerPortName = [AppDelegate getDrawerPortName];
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{
                    [DKAirCashFunctions waitDrawerOpenAndCloseWithPortName:drawerPortName portSettings:drawerPortSettings drawerNumber:1];
                });
            }
            
            return;
        }
        case SEARCH_PRINTER:
        case SEARCH_DK_AIRCASH:
        {
            NSArray *devices = nil;
            if (alertView.tag == SEARCH_PRINTER) {
                switch (buttonIndex) {
                    case 1: // LAN
                        devices = [[SMPort searchPrinter:@"TCP:"] retain];
                        break;
                    case 2: // Bluetooth
                        devices = [[SMPort searchPrinter:@"BT:"] retain];
                        break;
                    case 3: // Bluetooth Low Energy
                        devices = [[SMPort searchPrinter:@"BLE:"] retain];
                        break;
                    case 4: // All
                        devices = [[SMPort searchPrinter] retain];
                        break;
                }
                
                NSMutableArray *posPrinters = [NSMutableArray new];
                for (PortInfo *port in devices) {
                    if ([port.modelName isEqualToString:@"SAC10"] == NO) {
                        [posPrinters addObject:port];
                    }
                }
                searchView = [[SearchPrinterViewController alloc] initWithNibName:@"SearchPrinterViewController"
                                                                           bundle:nil
                                                                           target:self
                                                                           action:@selector(returnSelectedCellText)];
                searchView.foundPrinters = posPrinters;
                [posPrinters release];
            }
            else if (alertView.tag == SEARCH_DK_AIRCASH) { // Search DK-AirCash
                switch (buttonIndex) {
                    case 1: // LAN
                        devices = [[SMPort searchPrinter:@"TCP:"] retain];
                        break;
                    case 2: // Bluetooth
                        devices = [[SMPort searchPrinter:@"BT:"] retain];
                        break;
                    case 3: // All
                        devices = [[SMPort searchPrinter] retain];
                        break;
                }
                
                NSMutableArray *dkAirCash = [NSMutableArray new];
                for (PortInfo *port in devices) {
                    if ([port.modelName isEqualToString:@"SAC10"] == YES) {
                        [dkAirCash addObject:port];
                    }
                }
                
                searchView = [[SearchPrinterViewController alloc] initWithNibName:@"SearchPrinterViewController"
                                                                           bundle:nil
                                                                           target:self
                                                                           action:@selector(returnSelectedCellText2)];
                searchView.foundPrinters = dkAirCash;
                [dkAirCash release];
            }

            searchView.delegate = self;
            [self presentViewController:searchView animated:YES completion:nil];
            [searchView release];
            [devices release];
            return;
        }
    
        //
        // Open DK-AirCash 1 / 2
        //  - Check Password
        //
        case WAIT_DRAWER_OPEN_ONLY:
        {
            // Password Check
            NSString *password = [alertView textFieldAtIndex:0].text;
            [[alertView textFieldAtIndex:0] resignFirstResponder];

            if ([password isEqualToString:CORRECT_PASSWORD] == NO) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                                message:@"The password is incorrect. stop the process."
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
                [alert show];
                [alert release];
                return;
            }
            
            [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
            
            [DKAirCashFunctions OpenCashDrawerWithPortname:drawerPortName
                                              portSettings:drawerPortSettings
                                              drawerNumber:selectedDrawer];
            return;
        }

        case WAIT_DRAWER_OPEN_AND_CLOSE:
        {
            //
            // Check PIN code
            //
            
            if (securitySwitch.on) {
                NSString *enteredPassword = [alertView textFieldAtIndex:0].text;
                [[alertView textFieldAtIndex:0] resignFirstResponder];
                
                if ([enteredPassword isEqualToString:CORRECT_PASSWORD] == NO) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                                    message:@"The password is incorrect. stop the process."
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"OK", nil];
                    [alert show];
                    [alert release];
                    return;
                }
            }
            
            //
            // Wait drawer open and close.
            //
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                [DKAirCashFunctions waitDrawerOpenAndCloseWithPortName:drawerPortName portSettings:drawerPortSettings drawerNumber:1];
            });
        }
    }
}


#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    return YES;
}


#pragma mark - 

- (UIAlertView *)pinCodeDialogWithAction:(Action)nextAction {
    
    UIAlertView *alert = nil;
    
    alert = [[[UIAlertView alloc] initWithTitle:@"Please Input Password"
                                        message:@""
                                       delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"OK", nil] autorelease];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = nextAction;

    
    return alert;
}

- (void)disconnect:(PortInfo *)portInfo
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (portInfo != nil) {
        [PrinterFunctions disconnectPort:portInfo.portName portSettings:@"" timeout:10000];
    }
}

#pragma mark -

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)searchPrinter:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Select Interface"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"LAN", @"Bluetooth", @"Bluetooth Low Energy", @"All", nil];
    alert.tag = SEARCH_PRINTER;
    [alert show];
    [alert release];
}

- (IBAction)searchCashDrawer:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Select Interface"
                                                    message:@""
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"LAN", @"Bluetooth", @"All", nil];
    
    alert.tag = SEARCH_DK_AIRCASH;
    [alert show];
    [alert release];
}

- (IBAction)selectPort:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedPort = (int)selectedIndex;
        
        [portNumberButton setTitle:selectedValue forState:UIControlStateNormal];
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Port"
                                            rows:ports
                                initialSelection:selectedPort
                                       doneBlock:done
                                     cancelBlock:cancel
                                          origin:sender];
}

- (IBAction)selectPrinterType:(id)sender {
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue)
    {
        selectedPrinterType = (int)selectedIndex;
        
        [printerTypeButton setTitle:selectedValue forState:UIControlStateNormal];
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker)
    {
    };
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select Printer Type"
                                            rows:printerTypes
                                initialSelection:selectedPrinterType
                                       doneBlock:done
                                     cancelBlock:cancel
                                          origin:sender];
}

- (IBAction)selectLANType:(id)sender {
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        selectedLANType = (int)selectedIndex;
        [LANTypeButton setTitle:selectedValue forState:UIControlStateNormal];
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {};
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select LAN Type"
                                            rows:LANTypes
                                initialSelection:selectedLANType
                                       doneBlock:done
                                     cancelBlock:cancel
                                          origin:sender];
}

- (IBAction)showHelp:(id)sender {
    NSString *title = @"PORT PARAMETERS";
    
    NSString *helpText = [AppDelegate HTMLCSS];
    helpText = [helpText stringByAppendingString:@"<body>\
                This program on supports ethernet, wireless LAN, Bluetooth interface.<br/>\
                <Code>TCP:192.168.222.244</Code><br/>\
                <It1>Enter IP address of Star Device</It1><br/><br/>\
                <Code>BT:Star Micronics</Code><br/>\
                <It1>Enter iOS Port Name of Star Device</It1><br/><br/>\
                <LargeTitle><center>Port Settings</center></LargeTitle>\
                <p>You should leave this blank for Desktop Printers or DK-AirCash. You should use 'mini' when connecting to a Portable Printers.</p>\
                </body><html>"];
    
    StandardHelp *helpVar = [[StandardHelp alloc] initWithNibName:@"StandardHelp" bundle:[NSBundle mainBundle]];
    
    [self presentViewController:helpVar animated:YES completion:nil];
    [helpVar release];
    
    [helpVar setHelpTitle:title];
    [helpVar setHelpText:helpText];
}

- (void)returnSelectedCellText {
    NSString *selectedPortName = [searchView lastSelectedPortName];
    
    if ((selectedPortName != nil) && ([selectedPortName isEqualToString:@""] == NO))
    {
        self.uitextfield_printerPortName.text = selectedPortName;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)returnSelectedCellText2 {
    NSString *selectedPortName = [searchView lastSelectedPortName];
    
    if ((selectedPortName != nil) && ([selectedPortName isEqualToString:@""] == NO))
    {
        self.uitextfield_drawerPortName.text = selectedPortName;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setPortInfo
{
    [AppDelegate setPortName:self.uitextfield_printerPortName.text];
    [AppDelegate setDrawerPortName:self.uitextfield_drawerPortName.text];
    
    switch (selectedPrinterType) {
        case 0:
            if ([ports[selectedPort] isEqualToString:@"Standard"] == NO) {
                [AppDelegate setPortSettings:ports[selectedPort]];
            } else {
                [AppDelegate setPortSettings:@""];
            }
            break;
        case 1:
            [AppDelegate setPortSettings:@"Portable"];
            break;
        case 2:
            [AppDelegate setPortSettings:@"Portable;escpos"];
            break;
    }
}

static UIAlertView* alert = nil;

+ (void)showCommonProgressDialogWithTitle:(NSString *)title message:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (alert != nil) {
            [self dismissCommonProgressDialog];
        }
        
        alert = [[UIAlertView alloc] initWithTitle:title
                                           message:message
                                          delegate:nil
                                 cancelButtonTitle:nil
                                 otherButtonTitles:nil];
        [alert show];
    });
}

+ (void)dismissCommonProgressDialog
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        [alert dismissWithClickedButtonIndex:0 animated:NO];
        [alert release];
        alert = nil;
    });
}

@end
