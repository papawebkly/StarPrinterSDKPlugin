//
//  SearchPrinterViewController.m
//  IOS_SDK
//
//  Created by satsuki on 12/08/17.
//
//

#import "SearchPrinterViewController.h"
#import <StarIO/SMPort.h>


@implementation SearchPrinterViewController
@synthesize lastSelectedPortName;
@synthesize delegate = _delegate;
@synthesize target = _target;
@synthesize action = _action;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _target = nil;
        _action = nil;
   }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil target:(id)target action:(SEL)action {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _target = target;
        _action = action;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    uitableview_printerList.dataSource = self;
    uitableview_printerList.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    [_foundPrinters release];
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.foundPrinters.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    if (indexPath.row < self.foundPrinters.count) {
        PortInfo *port = self.foundPrinters[indexPath.row];
        cell.textLabel.text = port.modelName;

        if (([port.macAddress isEqualToString:@""]) ||
            ([port.portName isEqualToString:@"BLE:"])) {
            cell.detailTextLabel.text = port.portName;
        } else {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", port.portName, port.macAddress];
        }
    } else if (indexPath.row == self.foundPrinters.count) {
        cell.textLabel.text = @"Back";
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.foundPrinters.count) {
        PortInfo *portInfo = self.foundPrinters[indexPath.row];
        lastSelectedPortName = portInfo.portName;
    }

    if ((self.target == nil) || (self.action == nil)) {
        [self.delegate returnSelectedCellText];
    } else {
        [self.target performSelector:self.action];
    }
}

@end
