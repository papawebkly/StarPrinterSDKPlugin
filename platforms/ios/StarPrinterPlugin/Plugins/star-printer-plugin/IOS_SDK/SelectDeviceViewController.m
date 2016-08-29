//
//  SelectDeviceViewController.m
//  IOS_SDK
//
//  Created by u3237 on 2014/02/05.
//
//

#import "SelectDeviceViewController.h"
#import "ThresholdSettingViewController.h"
#import "ProxiPRNTSettingManager.h"

typedef enum _Section {
    SectionDirectConnection = 0,
    SectionViaAirPort
} Section;

@interface SelectDeviceViewController() {
    BOOL p_searching;
    NSArray *p_currentDevices;
}
@end

@implementation SelectDeviceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        p_currentDevices = nil;
        p_searching = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [_mainTable release];
    [p_currentDevices release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Select Device";
    
    UIBarButtonItem *leftItem  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModalView)];
    self.navigationItem.leftBarButtonItem = leftItem;
    [leftItem release];
    
    self.mainTable.delegate = self;
    self.mainTable.dataSource = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    // Start searching devices in backgroup thread.
    p_searching = YES;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (YES) {
            // Check searching flag
            BOOL searchingStatus;
            @synchronized(self) {
                searchingStatus = p_searching;
            }

            if (searchingStatus == NO) {
                break;
            }

            // Search
            [self searchDevices];
            
            // Reload table
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.mainTable reloadData];
            });
        }
    });
    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    @synchronized(self) {
        p_searching = NO;
    }
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dismissModalView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark Search Star Devices

- (void)searchDevices
{
    // Compare
    NSArray *foundDevices = [[SMPort searchPrinter] retain];
    NSSet *foundDeviceSet = [NSSet setWithArray:foundDevices];
    
    NSSet *currentDeviceSet = [NSSet setWithArray:p_currentDevices];

    // Set
    if ([foundDeviceSet isEqual:currentDeviceSet] == NO) {
        p_currentDevices = [foundDevices retain];
    }
    [foundDevices release];
}


#pragma mark UITableViewDelegate / UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* const CellIdentifier = @"CellIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    PortInfo *port = nil;
    
    switch (indexPath.section) {
        case SectionDirectConnection:
            port = p_currentDevices[indexPath.row];
            cell.textLabel.text = port.portName;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", port.modelName, port.macAddress];
            break;
        case SectionViaAirPort:
            cell.textLabel.text = @"USB Printer via AirPort";
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SectionDirectConnection:
            return p_currentDevices.count;
        case SectionViaAirPort:
            return 1;
        default:
            return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Deselect Table View Cell
    [self.mainTable deselectRowAtIndexPath:indexPath animated:YES];
    
    ProxiPRNTSettingManager *settingManager = ProxiPRNTSettingManager.sharedManager;
    settingManager.type = EditTypeAddNewDevice;
    
    switch (indexPath.section) {
        case SectionDirectConnection: {
            PortInfo *selectedPortInfo = p_currentDevices[indexPath.row];
            settingManager.portName = selectedPortInfo.portName;
            settingManager.type = EditTypeAddNewDevice;
            settingManager.useAirPort = NO;
            
            PortInfo *portInfo = (PortInfo *)p_currentDevices[indexPath.row];
            if ([portInfo.modelName isEqualToString:@"SAC10"]) {
                settingManager.deviceType = SMDeviceTypeDKAirCash;
            } else {
                settingManager.deviceType = SMDeviceTypeDesktopPrinter;
            }

            break;
        }
        case SectionViaAirPort:
            settingManager.portName = @"TCP:192.168.192.45";
            settingManager.deviceType = SMDeviceTypeDesktopPrinter;
            settingManager.useAirPort = YES;
            settingManager.portNumber = 9100;
            break;
        default:
            return;
    }

    // Show ThresholdSettingView
    UIViewController *viewController = [[ThresholdSettingViewController alloc] initWithNibName:@"ThresholdSettingViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SectionDirectConnection:
            return @"Discovered Devices";
        case SectionViaAirPort:
            return @"USB Printer";
    }
    
    return @"";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *kTableViewReusableHeader = @"Header";
    
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kTableViewReusableHeader];
    
    if (header == nil) {
        header = [[[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:kTableViewReusableHeader] autorelease];
    }
    
    switch (section) {
        case SectionDirectConnection:
            header.textLabel.text = @"Discovered Devices";
            
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView new] autorelease];
            indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            indicator.frame = CGRectMake(170, header.frame.origin.y + 15, 50, 50);

            [header.contentView addSubview:indicator];
            
            [indicator startAnimating];
            
            break;
            
        case SectionViaAirPort:
            header.textLabel.text = @"USB Printer";
            break;
            
        default:
            break;
    }
    
    return header;
}

@end
