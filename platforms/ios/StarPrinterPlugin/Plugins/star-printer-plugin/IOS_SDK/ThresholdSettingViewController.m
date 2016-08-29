//
//  ThresholdSettingViewController.m
//  IOS_SDK
//
//  Created by u3237 on 2014/02/05.
//
//

#import "ThresholdSettingViewController.h"
#import "ProxiPRNTSettingManager.h"
#import <StarIO/SMPort.h>
#import <StarIO/SMProxiPRNTManager.h>

static const float MIN_RSSI = -80.0;
static const float MAX_RSSI = -30.0;

typedef enum _AlertViewType {
    AlertViewTypeConfirmOverwrite = 0,
    AlertViewTypeAutoThresholdSetting = 1
} AlertViewType;

@interface ThresholdSettingViewController () {
    NSInteger p_currentRSSI;
    NSInteger p_threshold;
    
    UIView *p_blockingView;
    
    UIActionSheet *p_portNumberSheet;
    UIActionSheet *p_deviceTypeSheet;
    UIActionSheet *p_LANTypeSheet;
    
    NSString *p_removePortName;
}

@end

@implementation ThresholdSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        p_currentRSSI = -127;
        p_threshold = -127;
        
        thresholdSlider.minimumValue = 0;
        thresholdSlider.maximumValue = 100;

    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.navigationItem.title = @"Settings";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneButton;
    [doneButton release];
    
    UIBarButtonItem *cancelButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModalView)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];

    portNameField.delegate = self;
    nickNameField.delegate = self;
    
    [useCashDrawerSwitch addTarget:self action:@selector(onChangeSwitch:) forControlEvents:UIControlEventValueChanged ];
    
    ProxiPRNTSettingManager *settingManager = ProxiPRNTSettingManager.sharedManager;

    if (settingManager.type == EditTypeAddNewDevice) { // Add new device
        settingManager.nickName = @"Sample Nick Name:";
        settingManager.threshold = -50;
    } else { // Edit existing device
        NSDictionary *starIOSetting = SMProxiPRNTManager.sharedManager.settings[settingManager.portName];
        settingManager.nickName = starIOSetting[kSMNickName];
        settingManager.portNumber = ((NSString *)starIOSetting[kSMPortSettings]).intValue;
        settingManager.threshold = ((NSNumber *)starIOSetting[kSMThreshouldRSSI]).intValue;
        
        NSRange range = [starIOSetting[kSMPortSettings] rangeOfString:@";wl"];
        if ( range.location != NSNotFound ) {
            settingManager.lanType = LANTypeWireless;
        }
        else {
            settingManager.lanType = LANTypeWired;
        }
    }
    
    [self refreshUI];
}

- (void)dismissModalView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)refreshUI
{
    ProxiPRNTSettingManager *settingManager = ProxiPRNTSettingManager.sharedManager;
    
    if (settingManager.type ==  EditTypeAddNewDevice) { // Add new device
        deviceTypeLabel.hidden = YES;
        deviceTypeButton.hidden = YES;
        
        portNameField.text = settingManager.portName;
        if (settingManager.useAirPort) {  // via AirPort
            [portSettingsButton setTitle:@(settingManager.portNumber).stringValue forState:UIControlStateNormal];
            LANTypeLabel.hidden = YES;
            LANTypeButton.hidden = YES;
        } else {                          // Direct connection
            portNameField.hidden = YES;
            portNameLabel.hidden = YES;
            portSettingsButton.hidden = YES;
            portSettingsLabel.hidden = YES;
            
            if (settingManager.deviceType == SMDeviceTypeDKAirCash) {
                if(settingManager.lanType == LANTypeWired)
                {
                    NSString *WiredLabel = @"Wired";
                    [LANTypeButton setTitle:WiredLabel forState:UIControlStateNormal];
                }
                else
                {
                    NSString *WiredLabel = @"Wireless";
                    [LANTypeButton setTitle:WiredLabel forState:UIControlStateNormal];
                }
                
                useCashDrawerSwitchLabel.hidden = YES;
                useCashDrawerSwitch.hidden = YES;
                LANTypeLabel.hidden = NO;
                LANTypeButton.hidden = NO;
            }
            else{
                LANTypeLabel.hidden = YES;
                LANTypeButton.hidden = YES;
            }
        }
    } else { //Edit existing setting
        if (settingManager.useAirPort){
            deviceTypeLabel.hidden = YES;
            deviceTypeButton.hidden = YES;
        }
        portNameField.text = settingManager.portName;
        NSString *portNumberLabel = (settingManager.portNumber == 0) ? @"Standard" : @(settingManager.portNumber).stringValue;
        [portSettingsButton setTitle:portNumberLabel forState:UIControlStateNormal];
        
        if(settingManager.lanType == LANTypeWired)
        {
            NSString *WiredLabel = @"Wired";
            [LANTypeButton setTitle:WiredLabel forState:UIControlStateNormal];
        }
        else
        {
            NSString *WiredLabel = @"Wireless";
            [LANTypeButton setTitle:WiredLabel forState:UIControlStateNormal];
        }
        
        if (settingManager.deviceType == SMDeviceTypeDesktopPrinter) {
            [deviceTypeButton setTitle:@"Printer" forState:UIControlStateNormal];
            portSettingsLabel.hidden = NO;
            portSettingsButton.hidden = NO;
            useCashDrawerSwitchLabel.hidden = NO;
            useCashDrawerSwitch.hidden = NO;
            LANTypeLabel.hidden = YES;
            LANTypeButton.hidden = YES;
        } else {
            [deviceTypeButton setTitle:@"DK-AirCash" forState:UIControlStateNormal];
            portSettingsLabel.hidden = YES;
            portSettingsButton.hidden = YES;
            useCashDrawerSwitchLabel.hidden = YES;
            useCashDrawerSwitch.hidden = YES;
            LANTypeLabel.hidden = NO;
            LANTypeButton.hidden = NO;
        }
        
        if ([settingManager.portName rangeOfString:@"TCP"].location == NSNotFound){ // via Bluetooth
            LANTypeLabel.hidden = YES;
            LANTypeButton.hidden = YES;
        }

        nickNameField.text = settingManager.nickName;
        thresholdSlider.value = [self percentByRSSI:settingManager.threshold];
        thresholdLabel.text = @(settingManager.threshold).stringValue;
        useCashDrawerSwitch.on = settingManager.useCashDrawer;
    }
}

#pragma test

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    SMProxiPRNTManager.sharedManager.delegate = self;
    
    [SMProxiPRNTManager.sharedManager startScan];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [SMProxiPRNTManager.sharedManager stopScan];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)done
{
    [self hideKeyboard];
    
    ProxiPRNTSettingManager *settingManager = ProxiPRNTSettingManager.sharedManager;

    NSDictionary *starIOSettings = SMProxiPRNTManager.sharedManager.settings;
    
    // Setting exist (portName)
    if ([starIOSettings objectForKey:settingManager.portName] != nil) {
        p_removePortName = settingManager.portName;
        
        if (settingManager.type == EditTypeAddNewDevice) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                            message:@"This port name is already set by another Peripheral MAC address.\n"
                                                            "If you push \"OK\", then override new settings."
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"OK", nil];
            alert.tag = AlertViewTypeConfirmOverwrite;
            [alert show];
            [alert release];
            return;
        }
    }
    
    // Setting exist (MAC address)
    for (NSString *key in starIOSettings.allKeys) {
        NSDictionary *setting = starIOSettings[key];
        NSString *dongleMACAddr = (NSString *)setting[kSMDongleMACAddr];
        
        if ([dongleMACAddr isEqualToString:settingManager.peripheralMACAddr]) {
            p_removePortName = key;
            
            if (settingManager.type == EditTypeAddNewDevice) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation"
                                                                message:@"This MAC address is already set by another port name.\n"
                                                                "If you push \"OK\", then setting of previous MAC Address will delete."
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"OK", nil];
                alert.tag = AlertViewTypeConfirmOverwrite;
                [alert show];
                [alert release];
                return;
            }
            
            break;
        }
    }
    
    // Edit existing setting
    if (p_removePortName != nil) {
         if (settingManager.type == EditTypeEditExistSetting) {
            [SMProxiPRNTManager.sharedManager removeSettingWithPortName:p_removePortName];
        }
    }
    
    [self addSetting];
}

- (void)addSetting
{
    ProxiPRNTSettingManager *settingManager = ProxiPRNTSettingManager.sharedManager;
    
    NSString *portName = settingManager.portName;
    NSString *tcpPort = @(settingManager.portNumber).stringValue;
    NSString *LANType;
    if(settingManager.lanType == LANTypeWireless){
        LANType = @";wl";
    }
    else{
        LANType = @"";
    }
    NSString *portSettings = [NSString stringWithFormat:@"%@%@",tcpPort, LANType];
    
    NSString *peripheralMACADdr = settingManager.peripheralMACAddr;
    BOOL withDrawer = settingManager.useCashDrawer;
    NSInteger threshold = settingManager.threshold;
    NSString *nickName = settingManager.nickName;
    
    @try
    {
        if (settingManager.deviceType == SMDeviceTypeDesktopPrinter) {
            [SMProxiPRNTManager.sharedManager addSettingForPrinterPortName:portName
                                                              portSettings:portSettings
                                                                withDrawer:withDrawer
                                                                dongleMACAddr:peripheralMACADdr
                                                            RSSIthreshould:@(threshold)
                                                                  nickName:nickName];
        } else {
            [SMProxiPRNTManager.sharedManager addSettingForDKAirCashPortName:portName
                                                                portSettings:portSettings
                                                                  dongleMACAddr:peripheralMACADdr
                                                              RSSIthreshould:@(threshold)
                                                                    nickName:nickName];
        }
    }
    @catch (PortException *e)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:e.reason
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
        return;
    }
    
    [self exportSettings];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)dealloc
{
    [portNameLabel release];
    [portSettingsLabel release];
    [nickNameLabel release];
    [portNameField release];
    [portSettingsButton release];
    [nickNameField release];
    [currentRSSITitleLabel release];
    [currentRSSIProgressView release];
    [thresholdTitleLabel release];
    [thresholdSlider release];
    [thresholdLabel release];
    [currentRSSILabel release];
    [useCashDrawerSwitch release];
    [useCashDrawerSwitchLabel release];
    
    [p_blockingView release];
    [deviceTypeLabel release];
    [deviceTypeButton release];
    [LANTypeLabel release];
    [LANTypeButton release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [portNameLabel release];
    portNameLabel = nil;
    [portSettingsLabel release];
    portSettingsLabel = nil;
    [nickNameLabel release];
    nickNameLabel = nil;
    [portNameField release];
    portNameField = nil;
    [portSettingsButton release];
    portSettingsButton = nil;
    [nickNameField release];
    nickNameField = nil;
    [currentRSSITitleLabel release];
    currentRSSITitleLabel = nil;
    [currentRSSIProgressView release];
    currentRSSIProgressView = nil;
    [thresholdTitleLabel release];
    thresholdTitleLabel = nil;
    [thresholdSlider release];
    thresholdSlider = nil;
    [thresholdLabel release];
    thresholdLabel = nil;
    [currentRSSILabel release];
    currentRSSILabel = nil;
    [useCashDrawerSwitch release];
    useCashDrawerSwitch = nil;
    [useCashDrawerSwitchLabel release];
    useCashDrawerSwitchLabel = nil;
    [deviceTypeLabel release];
    deviceTypeLabel = nil;
    [deviceTypeButton release];
    deviceTypeButton = nil;
    [LANTypeLabel release];
    LANTypeLabel = nil;
    [LANTypeButton release];
    LANTypeButton = nil;
    [super viewDidUnload];
}


#pragma mark SMProxiPRNTManagerDelegate

- (void)didDiscoverPort:(NSString *)portName deviceType:(SMDeviceType)deviceType MACAddr:(NSString *)MACAddr RSSI:(NSNumber *)RSSI
{
    if ([ProxiPRNTSettingManager.sharedManager.peripheralMACAddr isEqualToString:MACAddr] == NO) {
        return;
    }
    
    const int INVALID_RSSI = 127;
    if (RSSI.intValue == INVALID_RSSI) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        currentRSSIProgressView.progress = [self percentByRSSI:RSSI.intValue];
        [currentRSSILabel setText:[NSString stringWithFormat:@"%d", RSSI.intValue]];
        
        if (RSSI.integerValue >= [self RSSIByPercent:thresholdSlider.value]) {
            currentRSSIProgressView.progressTintColor = [UIColor yellowColor];
        } else {
            currentRSSIProgressView.progressTintColor = nil; //default color
        }
    });
}

#pragma mark Input Port Name

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    
    return YES;
}

#pragma mark Select Port Number

- (IBAction)selectPortNumber:(id)sender
{
    [self hideKeyboard];
    
    if (ProxiPRNTSettingManager.sharedManager.type == EditTypeAddNewDevice) {
        p_portNumberSheet = [[UIActionSheet alloc] initWithTitle:@"Port Number"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109", nil];
    } else {
        p_portNumberSheet = [[UIActionSheet alloc] initWithTitle:@"Port Number"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"Standard", @"9100", @"9101", @"9102", @"9103", @"9104", @"9105", @"9106", @"9107", @"9108", @"9109", nil];

    }
    [p_portNumberSheet showInView:self.view];
    [p_portNumberSheet release];
}

- (IBAction)selectDeviceType:(id)sender
{
    [self hideKeyboard];
    
    p_deviceTypeSheet = [[UIActionSheet alloc] initWithTitle:@"Device Type"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:@"Printer", @"DK-AirCash", nil];
    [p_deviceTypeSheet showInView:self.view];
    [p_deviceTypeSheet release];
}

- (IBAction)selectLANType:(id)sender {
    [self hideKeyboard];
    
    p_LANTypeSheet = [[UIActionSheet alloc] initWithTitle:@"Select LAN Type"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:@"Wired", @"Wireless", nil];
    [p_LANTypeSheet showInView:self.view];
    [p_LANTypeSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Cancel
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    // Select and set port number
    if (actionSheet == p_portNumberSheet) { //port number
        NSString *portNumberString = [actionSheet buttonTitleAtIndex:buttonIndex];
        ProxiPRNTSettingManager.sharedManager.portNumber = (NSUInteger)portNumberString.intValue;
    }
    else if (actionSheet == p_LANTypeSheet) { //LAN Type
        if (buttonIndex == 0) {
            ProxiPRNTSettingManager.sharedManager.lanType = LANTypeWired;
        } else {
            ProxiPRNTSettingManager.sharedManager.lanType = LANTypeWireless;
        }
    }
    else { //device type
        if (buttonIndex == 0) {
            ProxiPRNTSettingManager.sharedManager.deviceType = SMDeviceTypeDesktopPrinter;
        } else {
            ProxiPRNTSettingManager.sharedManager.deviceType = SMDeviceTypeDKAirCash;
        }
    }
    
    [self refreshUI];
}


#pragma mark Set RSSI Threshold

- (IBAction)updatedThreshold:(id)sender
{
    [self hideKeyboard];

    // get
    UISlider *slider = (UISlider *)sender;
    NSInteger newRSSI = (long)[self RSSIByPercent:slider.value];
    
    // Update UI
    thresholdLabel.text = [NSString stringWithFormat:@"%ld", (long)newRSSI];
    
    // Update internal setting value
    ProxiPRNTSettingManager.sharedManager.threshold = newRSSI;
}


#pragma mark Set RSSI Threshold (Auto)

- (IBAction)setThresholdAutomatically:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Calibrate RSSI Threshold"
                                                    message:@"Please do not move the iOS device"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Start Calibration", nil];
    alert.tag = AlertViewTypeAutoThresholdSetting;
    [alert show];
    [alert release];
}


/*!
 *  Block view
 */
- (void)blockView:(UIView *)parentView message:(NSString *)message
{
    if (p_blockingView == nil) {
        // Get screen size
        CGRect rect = [UIScreen.mainScreen bounds];
        CGFloat width = rect.size.width;
        CGFloat height = rect.size.height;
        
        // Create block view
        p_blockingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        p_blockingView.backgroundColor = [UIColor grayColor];
        p_blockingView.alpha = 0.7;
        
        // Add subView
        const NSInteger subViewWidth  = 320;
        const NSInteger subViewHeight = 230;
        CGRect subViewRect = CGRectMake((width - subViewWidth) / 2, (height - subViewHeight) / 2, subViewWidth, subViewHeight);
        UIView *subView = [[UIView alloc] initWithFrame:subViewRect];
        
        subView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5f];
        
        // Add indicator
        const NSInteger indicatorSize = 38;
        CGRect indicatorRect = CGRectMake((subViewWidth - indicatorSize) / 2, (subViewHeight - indicatorSize) / 2 - 38, indicatorSize, indicatorSize);
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:indicatorRect];
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [indicator startAnimating];
        
        [subView addSubview:indicator];
        [indicator release];
        
        // label
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (subViewHeight - 100) / 2 + 70, subViewWidth, 38)];
        messageLabel.text = message;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        
        [subView addSubview:messageLabel];
        [messageLabel release];
        
        [p_blockingView addSubview:subView];
        [subView release];
    }

    // Show
    [self.view addSubview:p_blockingView];
}

- (void)unblockView
{
    // Dismiss
    [p_blockingView removeFromSuperview];
}

#pragma mark Using Cash Drawer

- (void)onChangeSwitch:(id)sender
{
    ProxiPRNTSettingManager.sharedManager.useCashDrawer = useCashDrawerSwitch.on;
}


#pragma mark - UITextField

// when tap keyboard
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    const char *str = string.UTF8String;

    if (textField == portNameField) {
        // Max: 19 characters
        // LAN:       "TCP:" + IP Address
        // Bluetooth: "BT:" + accessory name
        if (textField.text.length + string.length > 19) {
            if ((*str != 0x00) && (*str != 0x0a)) {
                return NO;
            }
        }
        
        // restrict available character
        if ([self validatePortName:string] == NO) {
            return NO;
        }
    }

    return YES;
}

/*!
 *  restrict available character (Port Name)
 */
- (BOOL)validatePortName:(NSString *)string
{
    NSCharacterSet *stringCharacterSet = [NSCharacterSet characterSetWithCharactersInString:string];
    NSString *allowedCharacters = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz;:!?#$%&,.@_-= /*+~^[{(]})|\\";
    NSCharacterSet *allowedCharacterSet = [NSCharacterSet characterSetWithCharactersInString:allowedCharacters];
    
    return [allowedCharacterSet isSupersetOfSet:stringCharacterSet];
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // Cancel
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    switch (alertView.tag) {
        case AlertViewTypeAutoThresholdSetting:
        {
            // Set threshold automatically
            [self blockView:self.view message:@"Please wait a few seconds."];
            
            // Refresh UI
            [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
            
            [SMProxiPRNTManager.sharedManager stopScan];
            
            NSString *targetMACADDRString = ProxiPRNTSettingManager.sharedManager.peripheralMACAddr;
            int calibratedThreshold = [SMProxiPRNTManager.sharedManager calibrateActionArea:targetMACADDRString];
            
            thresholdSlider.value = [self percentByRSSI:calibratedThreshold];
            thresholdLabel.text = [NSString stringWithFormat:@"%d", calibratedThreshold];
            ProxiPRNTSettingManager.sharedManager.threshold = calibratedThreshold;
            
            [SMProxiPRNTManager.sharedManager startScan];
            
            [self unblockView];
            break;
        }
        case AlertViewTypeConfirmOverwrite:
            [SMProxiPRNTManager.sharedManager removeSettingWithPortName:p_removePortName];
            
            [self addSetting];
            break;
    }
}

#pragma mark -

- (float)percentByRSSI:(NSInteger)rssi
{
    if (rssi > MAX_RSSI) {
        return 1.0;
    }

    if (rssi < MIN_RSSI) {
        return 0.0;
    }
    
    static const float RANGE = MAX_RSSI - MIN_RSSI;
    
    float percent = ((float)rssi - MAX_RSSI + RANGE) / RANGE;
    return percent;
}

- (NSInteger)RSSIByPercent:(float)percent
{
    if (percent > 1.0) {
        return -30;
    }
    
    if (percent < 0) {
        return -80;
    }
    
    static const float RANGE = MAX_RSSI - MIN_RSSI;
    
    NSInteger rssi = (NSInteger)((percent - 1.0) * RANGE) + MAX_RSSI;
    
    return rssi;
}

- (void)hideKeyboard
{
    [portNameField resignFirstResponder];
    [nickNameField resignFirstResponder];
    
    ProxiPRNTSettingManager *settingManager = ProxiPRNTSettingManager.sharedManager;
    settingManager.portName = portNameField.text;
    settingManager.nickName = nickNameField.text;
}

- (BOOL)exportSettings
{
    NSData *data = [SMProxiPRNTManager.sharedManager serializedSettings];
    if (nil) {
        return NO;
    }
    
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"setting.json"];
    
    if ([data writeToFile:filePath atomically:YES] == NO) {
        return NO;
    }
    
    return YES;
}

@end
