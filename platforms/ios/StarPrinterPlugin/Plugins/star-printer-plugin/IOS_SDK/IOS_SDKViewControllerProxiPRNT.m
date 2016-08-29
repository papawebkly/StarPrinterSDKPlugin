//
//  IOS_SDKViewControllerProxiPRNT.m
//  IOS_SDK
//
//  Created by u3237 on 2014/01/31.
//
//

#import "IOS_SDKViewControllerProxiPRNT.h"
#import "SelectDeviceViewController.h"
#import "ThresholdSettingViewController.h"
#import "ProxiPRNTCell.h"
#import "ProxiPRNTSettingManager.h"

static const float MIN_RSSI = -80.0;
static const float MAX_RSSI = -30.0;

typedef enum _SMDongleInformation {
    SMDongleInformationPortName = 0,
    SMDongleInformationDeviceType,
    SMDongleInformationMACAddr,
    SMDongleInformationRSSI
} SMDongleInformation;

@interface IOS_SDKViewControllerProxiPRNT () {
    NSMutableArray *p_foundDongles;
}
@end

@implementation IOS_SDKViewControllerProxiPRNT

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        p_foundDongles = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.navigationItem.title = @"Proxi PRNT";
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(didTapEditButton)];
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
    
    self.mainTable.delegate = self;
    self.mainTable.dataSource = self;
    self.mainTable.allowsSelection = NO;
}

- (void)didTapEditButton
{
    [self.mainTable setEditing:!self.mainTable.editing animated:YES];
    NSString *editButtonTitle = self.mainTable.editing ? @"Done" : @"Edit";
    self.navigationItem.rightBarButtonItem.title = editButtonTitle;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    @synchronized (self) {
        [ProxiPRNTSettingManager.sharedManager clear];
        
        SMProxiPRNTManager.sharedManager.delegate = self;

        [self.navigationController setNavigationBarHidden:NO animated:YES];
    
        [self importSettings];

        [SMProxiPRNTManager.sharedManager startScan];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SMProxiPRNTManager.sharedManager stopScan];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    @synchronized (self) {
        [p_foundDongles removeAllObjects];
    
        // End editing
        [self.mainTable setEditing:NO];
        self.navigationItem.rightBarButtonItem.title = @"Edit";
    
        // Export current setting
        if ([self exportSettings] == NO) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Faild to export settings"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"OK", nil];
            [alert show];
            [alert release];
            return;
        }
        
        [self.mainTable reloadData];
    }
    

    
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    [p_foundDongles release];
    
    [_mainTable release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [self setMainTable:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark SMProxiPRNTManagerDelegate

- (void)didDiscoverPort:(NSString *)portName deviceType:(SMDeviceType)deviceType MACAddr:(NSString *)MACAddr RSSI:(NSNumber *)RSSI
{
    NSInteger sameMACAddrIndex = -1;
    
    @synchronized(self) {
        const NSInteger MACAddrIndex = 2;

        for (int i = 0; i < p_foundDongles.count; i++) {
            NSArray *info = p_foundDongles[i];
            
            if ([info[MACAddrIndex] isEqualToString:MACAddr]) {
                sameMACAddrIndex = i;
            }
        }
        
        // Refresh cell
        if (sameMACAddrIndex == -1) { // Add new cell
            dispatch_sync(dispatch_get_main_queue(), ^{

                NSString *newPortName = (portName == nil) ? @"" : portName;
                [p_foundDongles addObject:@[newPortName, @(deviceType), MACAddr, RSSI]];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:p_foundDongles.count - 1 inSection:0];
                
                [self.mainTable insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

                ProxiPRNTCell *cell = (ProxiPRNTCell *)[self.mainTable cellForRowAtIndexPath:indexPath];
                cell.RSSIProgressView.transform = CGAffineTransformMakeScale(1.0f, 20.0f);
            });
        } else { // Change existing cell
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sameMACAddrIndex inSection:0];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                ProxiPRNTCell *cell = (ProxiPRNTCell *)[self.mainTable cellForRowAtIndexPath:indexPath];
                
                cell.RSSIProgressView.progress = [self percentByRSSI:RSSI.intValue];
                if ((portName != nil) && ([portName isEqualToString:@""] == NO)) {
                    NSNumber *threshold = SMProxiPRNTManager.sharedManager.settings[portName][kSMThreshouldRSSI];
                    
                    cell.PrintOrOpenDrawerButton.enabled = (RSSI.integerValue >= threshold.integerValue) ? YES : NO;
                }
            });
        }
    }
}

- (float)percentByRSSI:(NSInteger)RSSI
{
    float percent = 1.0f - ( ((float)RSSI - (MAX_RSSI)) * (-1.0f) / (MAX_RSSI - MIN_RSSI) );
    return percent;
}

- (void)didUpdateState:(NSString *)portName MACAddr:(NSString *)MACAddr
{
    @synchronized (self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            int lostDongleIndex = -1;
            
            for (int i = 0; i < p_foundDongles.count; i++) {
                NSString *dongleMACAddr = (NSString *)([p_foundDongles[i] objectAtIndex:SMDongleInformationMACAddr]);
                if ([dongleMACAddr isEqualToString:MACAddr]) {
                    lostDongleIndex = i;
                }
            }
            
            if (lostDongleIndex != -1) {
                
                [self.mainTable beginUpdates];
                
                [p_foundDongles removeObjectAtIndex:lostDongleIndex];
                
                NSIndexPath *index = [NSIndexPath indexPathForRow:lostDongleIndex inSection:0];
                [self.mainTable deleteRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                [self.mainTable endUpdates];
                
            }
        });
    }
}


#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return p_foundDongles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* const CellIdentifier = @"Cell";
    
    ProxiPRNTCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        UIViewController *vc = [[[UIViewController alloc] initWithNibName:@"ProxiPRNTCell" bundle:nil] autorelease];
        cell = (ProxiPRNTCell *)vc.view;
    }
    
    NSArray *dongleInfo = p_foundDongles[indexPath.row];
    NSDictionary *settings = SMProxiPRNTManager.sharedManager.settings;
    
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    if ([p_foundDongles[indexPath.row][SMDongleInformationDeviceType] isEqual:@(SMDeviceTypeUnknown)]) {
        cell.cellType = kProxiPRNTCellTypeUnregistered;
    } else {
        cell.cellType = kProxiPRNTCellTypeRegistered;
        NSNumber *threshold = settings[dongleInfo[SMDongleInformationPortName]][kSMThreshouldRSSI];
        cell.thresholdProgressView.progress = [self percentByRSSI:threshold.intValue];
    }
    
    cell.nickNameLabel.adjustsFontSizeToFitWidth = YES;
    cell.peripheralMACAddrLabel.adjustsFontSizeToFitWidth = YES;
    cell.peripheralMACAddrLabel.text = dongleInfo[SMDongleInformationMACAddr];

    for (NSString *portName in settings.allKeys) {
        NSDictionary *setting = settings[portName];

        if ([setting[kSMDongleMACAddr] isEqualToString:dongleInfo[SMDongleInformationMACAddr]]) {
            cell.portNameLabel.text = portName;
            break;
        }
    }
    cell.nickNameLabel.text = settings[dongleInfo[SMDongleInformationPortName]][kSMNickName];
    int deviceTypeNum = ((NSNumber *)dongleInfo[SMDongleInformationDeviceType]).intValue;
    cell.deviceType = (SMDeviceType)deviceTypeNum;
    cell.portSettings = settings[dongleInfo[SMDongleInformationPortName]][kSMPortSettings];
    cell.useDrawer = ((NSNumber *)settings[dongleInfo[SMDongleInformationPortName]][kSMWithDrawer]).boolValue;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        cell.RSSIProgressView.transform = CGAffineTransformMakeScale(1.0f, 5.0f);
        cell.thresholdProgressView.transform = CGAffineTransformMakeScale(1.0f, 5.0f);
    });

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSArray *selectedDongle = p_foundDongles[indexPath.row];
    NSString *peripheralMACAddrString = selectedDongle[SMDongleInformationMACAddr];

    ProxiPRNTSettingManager.sharedManager.peripheralMACAddr = peripheralMACAddrString;
    
    // Show Discovery or Threshold setting view
    id nextView = nil;
    
    ProxiPRNTSettingManager *setting = ProxiPRNTSettingManager.sharedManager;
    
    if ([selectedDongle[SMDongleInformationDeviceType] isEqual:@(SMDeviceTypeUnknown)]) {
        setting.type = EditTypeAddNewDevice;
        
        nextView = [[SelectDeviceViewController alloc] initWithNibName:@"SelectDeviceViewController" bundle:[NSBundle mainBundle]];
    } else {
        setting.type = EditTypeEditExistSetting;
        
        setting.portName = selectedDongle[SMDongleInformationPortName];
        
        NSDictionary *starIOSetting = SMProxiPRNTManager.sharedManager.settings[setting.portName];
        setting.deviceType = (SMDeviceType)((NSNumber *)starIOSetting[kSMDeviceType]).intValue;
        setting.nickName = starIOSetting[kSMNickName];
        setting.threshold = ((NSNumber *)starIOSetting[kSMThreshouldRSSI]).intValue;
        setting.useCashDrawer = ((NSNumber *)starIOSetting[kSMWithDrawer]).boolValue;
        setting.portNumber = ((NSString *)starIOSetting[kSMPortSettings]).intValue;

        nextView = [[ThresholdSettingViewController alloc] initWithNibName:@"ThresholdSettingViewController" bundle:[NSBundle mainBundle]];
    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:nextView];
    [self presentViewController:navigationController animated:YES completion:nil];

    [nextView release];
    [navigationController release];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProxiPRNTCell *cell = (ProxiPRNTCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.cellType == kProxiPRNTCellTypeUnregistered) {
        return NO;
    }

    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    @synchronized(self) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            [self.mainTable beginUpdates];
            
            [SMProxiPRNTManager.sharedManager removeSettingWithPortName:p_foundDongles[indexPath.row][SMDongleInformationPortName]];
            [p_foundDongles removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            [self.mainTable endUpdates];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    return cell.frame.size.height;
}

#pragma mark -

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

- (void)importSettings
{
    NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"setting.json"];
    if (filePath == nil) {
        return;
    }
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (fileHandle == nil) {
        NSLog(@"%@ is not exists.", filePath);
        return;
    }
    
    NSData *data = [fileHandle readDataToEndOfFile];
    
    if ([SMProxiPRNTManager.sharedManager respondsToSelector:@selector(deserializeSettings:)] == NO) {
        NSLog(@"not respond");
        return;
    }
    
    [SMProxiPRNTManager.sharedManager deserializeSettings:data];
}

@end
