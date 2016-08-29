//
//  CheckConnectionViewController.m
//  IOS_SDK
//
//  Created by u3237 on 12/10/25.
//

#import "CheckConnectionViewController.h"
#import <StarIO/SMPort.h>
#import "AppDelegate.h"
#import "MiniPrinterFunctions.h"
#import <sys/time.h>


@implementation CheckConnectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self connect];
    
    [AppDelegate setButtonArrayAsOldStyle:@[backButton, connectButton, getStatusButton, sampleReceiptButton]];
}

- (void)connect
{
    NSString *portName = [AppDelegate getPortName];
    NSString *portSettings = [AppDelegate getPortSettings];
    
    portNameInfo.text = portName;
    
    if ([[portName uppercaseString] hasPrefix:@"BT:"] == NO) {
        message.text = @"This function is supported only on Bluetooth I/F.";
        return;
    }
    
    starPort = [SMPort getPort:portName :portSettings :10000];
    if (starPort == nil) {
        enableCheckLoop = NO;
        
        statusInfo.text = @"NO";
        message.text = @"Please do pairing with the printer again and tap connect button.";
        
        connectButton.hidden = NO;
        sampleReceiptButton.hidden = YES;
        getStatusButton.hidden = YES;
        
        if (starPort != nil) {
            [SMPort releasePort:starPort];
            starPort = nil;
        }
    }
    
    enableCheckLoop = YES;
    
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        BOOL connected = NO;
        
        while (enableCheckLoop) {
            if (connected != starPort.connected) {
                connected = starPort.connected;
                    
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (connected == YES) {
                        statusInfo.text = @"YES";
                        message.text = @"";
                            
                        connectButton.hidden = YES;
                        sampleReceiptButton.hidden = NO;
                        getStatusButton.hidden = NO;
                    }
                    else {
                        enableCheckLoop = NO;
                        
                        statusInfo.text = @"NO";
                        message.text = @"Please do pairing with the printer again and tap connect button.";

                        connectButton.hidden = NO;
                        sampleReceiptButton.hidden = YES;
                        getStatusButton.hidden = YES;

                        if (starPort != nil) {
                            [SMPort releasePort:starPort];
                            starPort = nil;
                        }
                    }
                });
            }
            
            usleep(5000 * 1000); // Interval : 5sec
        }
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)pushButtonSampleReceipt:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Paper Width"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"2 inch", @"3 inch", @"4 inch", nil];
    [alertView show];
    [alertView release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    switch (buttonIndex) {
        case 1:
            [self printSampleReceipt2inch];
            break;
            
        case 2:
            [self printSampleReceipt3inch];
            break;
            
        case 3:
            [self printSampleReceipt4inch];
            break;
    }
}

- (void)printSampleReceipt2inch
{
    NSData *commands = [[MiniPrinterFunctions sampleReceiptDataWithLanguage:SMLanguageEnglish
                                                                 paperWidth:SMPaperWidth2inch] retain];

    unsigned char *commandsToSendToPrinter = (unsigned char *)malloc(commands.length);
    [commands getBytes:commandsToSendToPrinter length:commands.length];
    int commandSize = (int)commands.length;

    @try
    {
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            
            int blockSize = (remaining > 1024) ? 1024 : remaining;
            
            int amountWritten = [starPort writePort:commandsToSendToPrinter :totalAmountWritten :blockSize];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error"
                                                            message:@"Write port timed out"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
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
    
    free(commandsToSendToPrinter);
    [commands release];
}

- (void)printSampleReceipt3inch
{
    NSData *commands = [[MiniPrinterFunctions sampleReceiptDataWithLanguage:SMLanguageEnglish
                                                                 paperWidth:SMPaperWidth3inch] retain];
 
    unsigned char *commandsToSendToPrinter = (unsigned char *)malloc(commands.length);
    [commands getBytes:commandsToSendToPrinter length:commands.length];
    int commandSize = (int)commands.length;

    @try
    {
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            
            int blockSize = (remaining > 1024) ? 1024 : remaining;
            
            int amountWritten = [starPort writePort:commandsToSendToPrinter :totalAmountWritten :blockSize];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error"
                                                            message:@"Write port timed out"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
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
    
    free(commandsToSendToPrinter);
    [commands release];
}

- (void)printSampleReceipt4inch
{
    NSData *commands = [[MiniPrinterFunctions sampleReceiptDataWithLanguage:SMLanguageEnglish
                                                                 paperWidth:SMPaperWidth4inch] retain];
    
    unsigned char *commandsToSendToPrinter = (unsigned char *)malloc(commands.length);
    [commands getBytes:commandsToSendToPrinter length:commands.length];
    int commandSize = (int)[commands length];
    
    @try
    {
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            
            int blockSize = (remaining > 1024) ? 1024 : remaining;
            
            int amountWritten = [starPort writePort:commandsToSendToPrinter :totalAmountWritten :blockSize];
            totalAmountWritten += amountWritten;
            
            struct timeval now;
            gettimeofday(&now, NULL);
            if (now.tv_sec > endTime.tv_sec)
            {
                break;
            }
        }
        
        if (totalAmountWritten < commandSize)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error"
                                                            message:@"Write port timed out"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
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
    
    free(commandsToSendToPrinter);
    [commands release];
}

- (IBAction)pushButtonGetStatus:(id)sender {
    @try {
        StarPrinterStatus_2 status;
        [starPort getParsedStatus:&status :2];
    
        NSString *statusMessage = @"";
        if (status.offline == SM_TRUE)
        {
            statusMessage = @"The printer is offline";
            if (status.coverOpen == SM_TRUE)
            {
                statusMessage = [statusMessage stringByAppendingString:@"\nCover is Open"];
            }
            else if (status.receiptPaperEmpty == SM_TRUE)
            {
                statusMessage = [statusMessage stringByAppendingString:@"\nOut of Paper"];
            }
        }
        else
        {
            statusMessage = @"The Printer is online";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Status"
                                                        message:statusMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    @catch (PortException *e)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error"
                                                        message:@"Get status failed"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (IBAction)pushButtonConnect:(id)sender {
    [self connect];
}

- (IBAction)pushButtonBack:(id)sender {
    enableCheckLoop = NO;
    
    if (queue != nil) {
        dispatch_release(queue);
    }
    
    if (starPort != nil) {
        [starPort release];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [portNameInfo release];
    [statusInfo release];
    [message release];
    [getStatusButton release];
    [sampleReceiptButton release];
    [connectButton release];
    [backButton release];
    [super dealloc];
}
@end
