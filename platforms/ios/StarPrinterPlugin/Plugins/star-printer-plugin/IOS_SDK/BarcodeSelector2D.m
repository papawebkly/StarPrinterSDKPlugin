//
//  BarcodeSelector2D.m
//  IOS_SDK
//
//  Created by satsuki on 12/07/20.
//  Copyright 2012 - 2013 STAR MICRONICS CO., LTD. All rights reserved.
//

#import "AppDelegate.h"

#import "BarcodeSelector2D.h"
#import "QRCode.h"
#import "PDF417.h"
#import "QRCodeMini.h"
#import "PDF417mini.h"

@implementation BarcodeSelector2D

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        options = [[NSArray alloc] initWithObjects:@"QR Code", @"PDF417", nil];
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tableviewBarcode.dataSource = self;
    tableviewBarcode.delegate   = self;
    
    [AppDelegate setButtonArrayAsOldStyle:@[buttonBack]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [options release];
    
    [tableviewBarcode release];
    [buttonBack release];
    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        int index = (int)indexPath.row;
        cell.textLabel.text = options[index];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *portSettings = [AppDelegate getPortSettings];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SMPrinterType printerType = [AppDelegate parsePortSettings:portSettings];
    
    if (indexPath.row == 0)
    {
        if (printerType == SMPrinterTypePortablePrinterESCPOS)
        {
            QRCodeMini *QRcodevar = [[QRCodeMini alloc]initWithNibName:@"QRCodeMini" bundle:[NSBundle mainBundle]];
            [self presentViewController:QRcodevar animated:YES completion:nil];
            [QRcodevar release];
        }
        else
        {
            QRCode *QRCodevar = [[QRCode alloc] initWithNibName:@"QRCode" bundle:[NSBundle mainBundle]];
            [self presentViewController:QRCodevar animated:YES completion:nil];
            [QRCodevar release];
        }
    }
    else if (indexPath.row == 1)
    {
        if (printerType == SMPrinterTypePortablePrinterESCPOS)
        {
            PDF417mini *PDF417var = [[PDF417mini alloc] initWithNibName:@"PDF417mini" bundle:[NSBundle mainBundle]];
            [self presentViewController:PDF417var animated:YES completion:nil];
            [PDF417var release];
        }
        else
        {
            PDF417 *PDF417var = [[PDF417 alloc] initWithNibName:@"PDF417" bundle:[NSBundle mainBundle]];
            [self presentViewController:PDF417var animated:YES completion:nil];
            [PDF417var release];
        }
    }
}

- (IBAction)pushButtonBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end


