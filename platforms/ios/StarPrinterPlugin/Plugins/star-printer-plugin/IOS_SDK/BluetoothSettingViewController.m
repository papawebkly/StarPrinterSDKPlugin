//
//  BluetoothSettingViewController.m
//  IOS_SDK
//
//  Created by u3237 on 2013/10/24.
//
//

#import <StarIO/SMBluetoothManager.h>
#import "BluetoothSettingViewController.h"

typedef enum _AlertViewType {
    AlertViewTypeAlphabetPINCode = 100
} AlertViewType;

@interface BluetoothSettingViewController() {
    BOOL p_isSMLSeries; ///< SM-Lxxx series
    NSUInteger p_minPINCodeLength;
    NSUInteger p_maxPINCodeLength;
}
@end

@implementation BluetoothSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil bluetoothManager:(SMBluetoothManager *)manager
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.bluetoothManager = manager;
        
        // SM-Lxxx series or not
        p_minPINCodeLength = 4;
        if ([self.bluetoothManager.portName.uppercaseString hasPrefix:@"BLE:"]) {
            p_isSMLSeries = YES;
            p_maxPINCodeLength = 4;
        } else {
            p_isSMLSeries = NO;
            p_maxPINCodeLength = 16;
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    functions = [[NSArray alloc] initWithObjects:@"Device Name", @"iOS Port Name", @"Auto Connect", @"Security", @"Change PIN Code", @"New PIN Code", nil];
    
    self.mainTable.delegate = self;
    self.mainTable.dataSource = self;
    self.mainTable.scrollEnabled = NO;

    changePINcode = NO;
    
    // Gesture Recognizer
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [singleTap release];
    
    [functions release];
    [_bluetoothManager release];
    [_mainTable release];
    
    [_applyButton release];
    [super dealloc];
}

#pragma mark Gesture Recognizer

- (void)onSingleTap:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == singleTap) {
        if ((deviceNameField.isFirstResponder)  ||
            (iOSPortNameField.isFirstResponder) ||
            (pinCodeField.isFirstResponder)) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

#pragma mark UIButton

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)applySettings:(id)sender {
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error"
                                                     message:@""
                                                    delegate:nil
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"OK", nil] autorelease];
    if ((self.bluetoothManager.deviceType == SMDeviceTypeDesktopPrinter) ||
        (self.bluetoothManager.deviceType == SMDeviceTypeDKAirCash)) {
            if ((self.bluetoothManager.autoConnect == YES) &&
                (self.bluetoothManager.security == SMBluetoothSecurityPINcode)) {
                alert.message = @"Auto Connection function is available only when the security setting is \"SSP\".";
                alert.delegate = self;
                [alert show];
                return;
            }
    }
    
    // Check PIN Code
    if (changePINcode == YES) {
        if ([self validatePinCodeChar:self.bluetoothManager.pinCode] == NO) {
            alert.message = [NSString stringWithFormat:@"%@ is invalid PIN Code", self.bluetoothManager.pinCode];
            [alert show];
            return;
        }
        
        if ([self isDigit:self.bluetoothManager.pinCode] == NO) {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Warning"
                                                             message:@"iPhone and iPod touch cannot use Alphabet PIN code, iPad only can use."
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:@"OK", nil] autorelease];
            alert.tag = 100;
            [alert show];
            return;
        }
    } else {
        self.bluetoothManager.pinCode = nil;
    }
    
    // Apply settings
    if ([self.bluetoothManager open] == NO) {
        alert.message = @"Failed to open port.";
        [alert show];
        return;
    }

    if ([self.bluetoothManager apply] == NO) {
        alert.message = @"Failed to apply.";
        [alert show];
        [self.bluetoothManager close];
        return;
    }

    [self.bluetoothManager close];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    alert.title = @"Complete";
    alert.message = @"To apply settings, please turn the device power OFF and ON, and established pairing again.";
    [alert show];
}

- (BOOL)isDigit:(NSString *)text
{
    NSCharacterSet *digitCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    NSScanner *aScanner = [NSScanner localizedScannerWithString:text];
    [aScanner setCharactersToBeSkipped:nil];
    
    [aScanner scanCharactersFromSet:digitCharSet intoString:NULL];
    return [aScanner isAtEnd];
}

#pragma mark UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == AlertViewTypeAlphabetPINCode) {
        if (buttonIndex == 0) {
            return;
        }
        
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error"
                                                         message:@""
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil] autorelease];
        
        // Apply settings
        if ([self.bluetoothManager open] == NO) {
            alert.message = @"Failed to open port.";
            [alert show];
            return;
        }
        
        if ([self.bluetoothManager apply] == NO) {
            alert.message = @"Failed to apply.";
            [alert show];
            [self.bluetoothManager close];
            return;
        }
        
        [self.bluetoothManager close];
        [self dismissViewControllerAnimated:YES completion:nil];
        
        alert.title = @"Complete";
        alert.message = @"To apply settings, please turn the device power OFF and ON, and established pairing again.";
        [alert show];
        return;
    }
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
    
    UIColor *detailTextColor = [UIColor colorWithRed:59.0/255.0 green:85.0/255.0 blue:133.0/255.0 alpha:1.0];
    
    // tableViewCell
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    cell.textLabel.text = functions[indexPath.row];

    cell.detailTextLabel.textColor = detailTextColor;
    
    // textfield
    UITextField *field = [[[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, cell.frame.size.height * 0.6)] autorelease];
    field.textColor = detailTextColor;
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field.textAlignment = NSTextAlignmentLeft;
    field.tag = indexPath.row;
    field.delegate = self;
    field.keyboardType = UIKeyboardTypeAlphabet;
    
    cell.textLabel.text = functions[indexPath.row];
    
    switch (indexPath.row) {
        case 0: // Device Name
            if (self.bluetoothManager.deviceNameCapability == SMBluetoothSettingCapabilitySupport) {
                field.text = _bluetoothManager.deviceName;
                deviceNameField = field;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryView = field;
            } else {
                cell.detailTextLabel.text = @"No Support";
                cell.detailTextLabel.textColor = UIColor.grayColor;
            }
            
            break;
            
        case 1: // iOS Port Name
            if (self.bluetoothManager.iOSPortNameCapability == SMBluetoothSettingCapabilitySupport) {
                field.text = _bluetoothManager.iOSPortName;
                iOSPortNameField = field;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryView = field;
            } else {
                cell.detailTextLabel.text = @"No Support";
                cell.detailTextLabel.textColor = UIColor.grayColor;
            }
            break;
            
        case 2: // Auto Connect
            if (self.bluetoothManager.autoConnectCapability == SMBluetoothSettingCapabilitySupport) {
                UISwitch *switch1 = [[UISwitch new] autorelease];
                switch1.on = (self.bluetoothManager.autoConnect) ? YES : NO;
                [switch1 addTarget:self action:@selector(autoConnectSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryView = switch1;
            } else {
                cell.detailTextLabel.text = @"No Support";
                cell.detailTextLabel.textColor = UIColor.grayColor;
            }
            break;
            
        case 3: // Security
            if (self.bluetoothManager.securityTypeCapability == SMBluetoothSettingCapabilitySupport) {
                switch (self.bluetoothManager.security) {
                    case SMBluetoothSecurityDisable:
                        cell.detailTextLabel.text = @"Disable";
                        break;
                    case SMBluetoothSecurityPINcode:
                        cell.detailTextLabel.text = @"PIN Code";
                        break;
                    case SMBluetoothSecuritySSP:
                        cell.detailTextLabel.text = @"SSP";
                        break;
                }
            } else {
                cell.detailTextLabel.text = @"No Support";
                cell.detailTextLabel.textColor = UIColor.grayColor;
            }
            
            break;
            
        case 4: // Change PIN code
            if (self.bluetoothManager.pinCodeCapability == SMBluetoothSettingCapabilitySupport) {
                cell.detailTextLabel.text = changePINcode ? @"Change" : @"No Change";
            } else {
                cell.detailTextLabel.text = @"No Support";
                cell.detailTextLabel.textColor = UIColor.grayColor;
            }
            break;
            
        case 5: // New PIN Code
            if (self.bluetoothManager.pinCodeCapability == SMBluetoothSettingCapabilitySupport) {
                cell.accessoryView = field;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                field.secureTextEntry = YES;
                field.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                pinCodeField = field;
            } else {
                cell.detailTextLabel.text = @"No Support";
                cell.detailTextLabel.textColor = UIColor.grayColor;
            }
            break;
            
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 3:
        case 4:
            return indexPath;
        default:
            break;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 3: // Security
            if ((self.bluetoothManager.deviceType == SMDeviceTypeDesktopPrinter) ||
                (self.bluetoothManager.deviceType == SMDeviceTypeDKAirCash)) {
                self.bluetoothManager.security = (self.bluetoothManager.security == SMBluetoothSecuritySSP) ? SMBluetoothSecurityPINcode : SMBluetoothSecuritySSP;
            } else if (self.bluetoothManager.deviceType == SMDeviceTypePortablePrinter) {
                self.bluetoothManager.security = (self.bluetoothManager.security == SMBluetoothSecurityDisable) ? SMBluetoothSecurityPINcode : SMBluetoothSecurityDisable;
            }

            break;
            
        case 4: // PIN code
            changePINcode = !changePINcode;
            
            [self refreshApplyButtonStateWithPINCode:pinCodeField.text];

            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark UISwitch

- (void)autoConnectSwitchValueChanged:(UISwitch *)sender {
    self.bluetoothManager.autoConnect = sender.on;
}

#pragma mark UITextField

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString *text = [[textField.text mutableCopy] autorelease];
    [text replaceCharactersInRange:range withString:string];

    if (text.length > 16) {
        return NO;
    }
    
    switch (textField.tag) {
        case 0: // Device Name
            if ([self validateName:string] == NO) {
                return NO;
            }
            
            break;
            
        case 1: // iOS Port Name
            if ([self validateName:string] == NO) {
                return NO;
            }

            break;
            
        case 5: { // PIN code
            // Check character
            BOOL result = NO;
            if ([self validatePinCodeChar:text]) {
                result = YES;
            }
            
            return result;
        }
    }

    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case 0: // Device Name
            if (textField.text.length == 0) {
                return NO;
            }
            self.bluetoothManager.deviceName = textField.text;
            break;
            
        case 1: // iOS Port Name
            if (textField.text.length == 0) {
                return NO;
            }
            self.bluetoothManager.iOSPortName = textField.text;
            break;

        case 5: // PIN code
            self.bluetoothManager.pinCode = textField.text;
            
            [self refreshApplyButtonStateWithPINCode:textField.text];
            
            break;
    }
    
    return YES;
}

- (void)refreshApplyButtonStateWithPINCode:(NSString *)pinCode {
    UIColor *defaultColor = [UIColor colorWithRed:0.219608 green:0.329412 blue:0.529412 alpha:1];
    if (changePINcode == NO) {
        self.applyButton.enabled = YES;
        [self.applyButton setTitleColor:defaultColor forState:UIControlStateNormal];
    } else if ((pinCode.length < p_minPINCodeLength) ||
               (pinCode.length > p_maxPINCodeLength)) {
        self.applyButton.enabled = NO;
        [self.applyButton setTitleColor:UIColor.lightGrayColor forState:UIControlStateDisabled];
    } else {
        self.applyButton.enabled = YES;
        [self.applyButton setTitleColor:defaultColor forState:UIControlStateNormal];
    }
}

- (BOOL)validateName:(NSString *)string {
    const char *str = string.UTF8String;
    
    for (int i = 0; i < string.length; i++) {
        const char c = *(str + i);
        
        if ((('a' <= c) && (c <= 'z')) ||
            (('A' <= c) && (c <= 'Z')) ||
            (('0' <= c) && (c <= '9')) ||
            (c == ';') ||
            (c == ':') ||
            (c == '!') ||
            (c == '?') ||
            (c == '#') ||
            (c == '$') ||
            (c == '%') ||
            (c == '&') ||
            (c == ',') ||
            (c == '.') ||
            (c == '@') ||
            (c == '_') ||
            (c == '-') ||
            (c == '=') ||
            (c == ' ') ||
            (c == '/') ||
            (c == '*') ||
            (c == '+') ||
            (c == '~') ||
            (c == '^') ||
            (c == '[') ||
            (c == '{') ||
            (c == '(') ||
            (c == ']') ||
            (c == '}') ||
            (c == ')') ||
            (c == '|') ||
            (c == '\\') ||
            (c == 0x0a) ||       // LF
            (c == 0x00))         // NUL
        {
            continue;
        }
        
        return NO;
    }
    
    return YES;
}

/*! 
 *  Validate PIN Code.
 */
- (BOOL)validatePinCodeChar:(NSString *)pinCode {
    if (changePINcode == NO) {
        return YES;
    }
    
    if (pinCode == nil) {
        return NO;
    }
    
    if (p_isSMLSeries) {
        return [self validateSMLPINCode:pinCode];
    }
    
    const char *str = [pinCode UTF8String];
    
    for (int i = 0; i < pinCode.length; i++) {
        const char c = *(str + i);

        if ((('0' <= c) && (c <= '9')) ||
            (c == 0x0a) ||
            (c == 0x00)) {
            continue;
        }

        if ((('a' <= c) && (c <= 'z')) ||
            (('A' <= c) && (c <= 'Z'))) {
            continue;
        }

        return NO;
    }
    
    return YES;
}

/*!
 *  Validate PIN Code. (for SM-Lxxx series)
 */
- (BOOL)validateSMLPINCode:(NSString *)pinCode {
    NSString *capableChars = @"0123456789";
    NSCharacterSet *capableCharSet = [NSCharacterSet characterSetWithCharactersInString:capableChars];
    NSCharacterSet *pinCodeCharSet = [NSCharacterSet characterSetWithCharactersInString:pinCode];
    
    if ([capableCharSet isSupersetOfSet:pinCodeCharSet] == NO) {
        return NO;
    }

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end
