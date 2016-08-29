//
//  ProxiPRNTCell.m
//  IOS_SDK
//
//  Created by u3237 on 2014/02/06.
//
//

#import <sys/time.h>
#import "ProxiPRNTCell.h"
#import "RasterDocument.h"
#import "StarBitmap.h"
#import "PrinterFunctions.h"
#import <StarIO/SMPort.h>

@interface ProxiPRNTCell() {
    UIView *p_blockingView;
}
@end

@implementation ProxiPRNTCell

typedef enum _DeviceType {
    DeviceTypePrinter,
    DeviceTypeDKAirCash
} DeviceType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }

    return self;
}

- (void)dealloc
{
    [_peripheralMACAddrLabel release];
    [_portNameLabel release];
    [_nickNameLabel release];
    [_RSSIProgressView release];
    [_PrintOrOpenDrawerButton release];
    [_selectDeviceLabel release];
    [_portSettings release];
    [_thresholdProgressView release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)printOrOpenDrawer:(id)sender
{
    // Get root view controller
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if (window == nil) {
        window = UIApplication.sharedApplication.windows[0];
    }
    UIView *rootView = window.rootViewController.view;

    [self blockView:rootView message:@"Please wait"];
    
    switch (_deviceType) {
        case SMDeviceTypeDesktopPrinter:
            [self printRasterSampleReceipt3InchWithPortname:self.portNameLabel.text
                                               portSettings:self.portSettings];
            break;
        case SMDeviceTypeDKAirCash:
            [self openCashDrawerWithPortname:self.portNameLabel.text
                                portSettings:self.portSettings
                                drawerNumber:1];
            break;
        default:
            break;
    }
    [self unblockView];
}

- (void)setCellType:(enum ProxiPRNTCellType)cellType
{
    _cellType = cellType;
    
    if (cellType == kProxiPRNTCellTypeUnregistered) {
        self.portNameLabel.hidden = YES;
        self.nickNameLabel.hidden = YES;
        self.RSSIProgressView.progressTintColor = [UIColor grayColor];
        self.thresholdProgressView.hidden = YES;
        self.selectDeviceLabel.hidden = NO;
        self.PrintOrOpenDrawerButton.hidden = YES;
    } else { //Registered
        self.nickNameLabel.hidden = NO;
        self.portNameLabel.hidden = NO;
        self.RSSIProgressView.progressTintColor = nil;
        self.thresholdProgressView.hidden = NO;
        self.selectDeviceLabel.hidden = YES;
        self.PrintOrOpenDrawerButton.hidden = NO;
    }
}

#pragma mark -
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
    [parentView addSubview:p_blockingView];
    
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.0]];
}

- (void)unblockView
{
    // Dismiss
    [p_blockingView removeFromSuperview];
}

#pragma mark Print / Open Cash Drawer

/**
 * This function print the Raster sample receipt (3inch)
 * portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 * portSettings - Should be blank
 */
- (void)printRasterSampleReceipt3InchWithPortname:(NSString *)portName
                                     portSettings:(NSString *)portSettings
{
    static NSString *textToPrint = @"        Star Clothing Boutique\r\n"
    "             123 Star Road\r\n"
    "           City, State 12345\r\n"
    "\r\n"
    "Date: MM/DD/YYYY         Time:HH:MM PM\r\n"
    "--------------------------------------\r\n"
    "SALE\r\n"
    "SKU            Description       Total\r\n"
    "300678566      PLAIN T-SHIRT     10.99\n"
    "300692003      BLACK DENIM       29.99\n"
    "300651148      BLUE DENIM        29.99\n"
    "300642980      STRIPED DRESS     49.99\n"
    "30063847       BLACK BOOTS       35.99\n"
    "\n"
    "Subtotal                        156.95\r\n"
    "Tax                               0.00\r\n"
    "--------------------------------------\r\n"
    "Total                          $156.95\r\n"
    "--------------------------------------\r\n"
    "\r\n"
    "Charge\r\n159.95\r\n"
    "Visa XXXX-XXXX-XXXX-0123\r\n"
    "Refunds and Exchanges\r\n"
    "Within 30 days with receipt\r\n"
    "And tags attached\r\n";
    

    int width = 576;
    
    static NSString *fontName = @"Courier";
    
    double fontSize = 12.0 * 2;
    
    UIFont *font = [UIFont fontWithName:fontName size:fontSize];

    UIImage *imageToPrint = [PrinterFunctions imageWithString:textToPrint
                                                         font:font
                                                        width:576];
    
    [self printImageWithPortname:portName
                    portSettings:portSettings
                    imageToPrint:imageToPrint
                        maxWidth:width
               compressionEnable:YES
                  withDrawerKick:YES];
}

- (void)printImageWithPortname:(NSString *)portName
                  portSettings:(NSString *)portSettings
                  imageToPrint:(UIImage *)imageToPrint
                      maxWidth:(int)maxWidth
             compressionEnable:(BOOL)compressionEnable
                withDrawerKick:(BOOL)drawerKick
{
    RasterDocument *rasterDoc = [[RasterDocument alloc] initWithDefaults:RasSpeed_Medium
                                                      endOfPageBehaviour:RasPageEndMode_FeedAndFullCut
                                                  endOfDocumentBahaviour:RasPageEndMode_FeedAndFullCut
                                                               topMargin:RasTopMargin_Standard
                                                              pageLength:0
                                                              leftMargin:0
                                                             rightMargin:0];
    StarBitmap *starbitmap = [[StarBitmap alloc] initWithUIImage:imageToPrint :maxWidth :false];
    
    NSMutableData *commandsToPrint = [NSMutableData new];
    NSData *shortcommand = [rasterDoc BeginDocumentCommandData];
    [commandsToPrint appendData:shortcommand];
    
    shortcommand = [starbitmap getImageDataForPrinting:compressionEnable];
    [commandsToPrint appendData:shortcommand];
    
    shortcommand = [rasterDoc EndDocumentCommandData];
    [commandsToPrint appendData:shortcommand];
    
    if (drawerKick == YES) {
        [commandsToPrint appendBytes:"\x07"
                              length:sizeof("\x07") - 1];    // Kick Cash Drawer
    }
    
    [starbitmap release];
    [rasterDoc release];
    
    [self sendCommand:commandsToPrint
             portName:portName
         portSettings:portSettings
        timeoutMillis:10000
           deviceType:DeviceTypePrinter];
    
    [commandsToPrint release];
}

- (void)sendCommand:(NSData *)commandsToPrint
           portName:(NSString *)portName
       portSettings:(NSString *)portSettings
      timeoutMillis:(u_int32_t)timeoutMillis
         deviceType:(DeviceType)deviceType
{
    Byte *dataToSentToPrinter = (Byte *)malloc(commandsToPrint.length);
    [commandsToPrint getBytes:dataToSentToPrinter length:commandsToPrint.length];
    
    SMPort *starPort = nil;
    @try
    {
        starPort = [SMPort getPort:portName :portSettings :timeoutMillis];
        if (starPort == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port"
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        
        StarPrinterStatus_2 status;
        [starPort beginCheckedBlock:&status :2];
        if (status.offline == SM_TRUE) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Printer is offline"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        if ((self.useDrawer) && (status.compulsionSwitch == SM_FALSE)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Drawer was already opened"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }

        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandsToPrint.length) {
            int remaining = (int)(commandsToPrint.length - totalAmountWritten);
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :remaining];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec) {
                break;
            }
        }
        
        if (totalAmountWritten < commandsToPrint.length) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error"
                                                            message:@"Write port timed out"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        
        starPort.endCheckedBlockTimeoutMillis = 30000;
        [starPort endCheckedBlock:&status :2];
        if (deviceType == DeviceTypePrinter) {
            if (status.offline == SM_TRUE) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Printer is offline"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
                return;
            }
            if ((self.useDrawer) && (status.compulsionSwitch == SM_FALSE)) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"Drawer was opened"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
                return;
            }
        } else if (deviceType == DeviceTypeDKAirCash) {
            usleep(150 * 1000);
            
            [starPort getParsedStatus:&status :2];
            if (status.offline == SM_TRUE) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                                message:@"A drawer is offline"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
                return;
            }
            
            if (status.compulsionSwitch == SM_FALSE) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                                message:@"Drawer was opened"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [alert release];
                return;
            }
        }
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error"
                                                        message:@"Write port timed out"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    @finally
    {
        free(dataToSentToPrinter);
        [SMPort releasePort:starPort];
    }
}

/**
 *  This function opens the DK-AirCash.
 *  This function just send the byte 0x07 to the DK-AirCash which is the open Cash Drawer command
 *  portName - Port name to use for communication. This should be (TCP:<IPAddress>)
 *  portSettings - Should be blank
 */
- (void)openCashDrawerWithPortname:(NSString *)portName
                      portSettings:(NSString *)portSettings
                      drawerNumber:(NSUInteger)drawerNumber
{
    Byte opencashdrawer_command = 0x00;

    if (drawerNumber == 1) {
        opencashdrawer_command = 0x07;  // BEL
    } else if (drawerNumber == 2) {
        opencashdrawer_command = 0x1a;  // SUB
    }
    
    NSData *commands = [NSData dataWithBytes:&opencashdrawer_command length:1];
    [self sendCommand:commands
             portName:portName
         portSettings:portSettings
        timeoutMillis:10000
           deviceType:DeviceTypeDKAirCash];
}
@end
