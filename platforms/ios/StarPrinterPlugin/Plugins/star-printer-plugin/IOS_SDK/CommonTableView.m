//
//  CommonTableView.m
//  IOS_SDK
//
//  Created by u3237 on 13/06/25.
//
//

#import "CommonTableView.h"
#import <StarIO/SMPort.h>

@implementation CommonTableView

@synthesize deviceArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
 
    }

    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil devices:(NSArray *)devices delegate:(id)delegate action:(SEL)action
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        deviceArray = [devices retain];
        _target = delegate;
        _action = action;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_tableView release];
    [deviceArray release];
    [super dealloc];
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return deviceArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    if (indexPath.row + 1 == deviceArray.count + 1) {
        cell.textLabel.text = @"Back";
    }
    else {
        PortInfo *p = deviceArray[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", p.portName];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@(%@)", p.modelName, p.macAddress];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PortInfo *portInfo = nil;
    if (indexPath.row + 1 < deviceArray.count + 1) {
        portInfo = deviceArray[indexPath.row];
    }
    
    [_target performSelector:_action withObject:portInfo];
}

@end
