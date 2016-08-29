//
//  DotPrinterFunctions.m
//  IOS_SDK
//
//  Created by u3237 on 2014/08/27.
//
//

#import "DotPrinterFunctions.h"
#import <StarIO/SMPort.h>
#import <StarIO/SMBluetoothManager.h>
#import <sys/time.h>

@implementation DotPrinterFunctions

#pragma mark Show Firmware Information

/*!
 *  This function shows the printer firmware information
 *
 *  @param  portName        Port name to use for communication.
 *  @param  portSettings    The port settings to use.
 */
+ (void)showFirmwareVersion:(NSString *)portName portSettings:(NSString *)portSettings
{
    SMPort *starPort = nil;
    NSDictionary *dict = nil;
    
    @try
    {
        starPort = [SMPort getPort:portName :portSettings :10000];
        if (starPort == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port.\nRefer to \"getPort API\" in the manual."
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        
        NSMutableString *message = [NSMutableString string];
        dict = [[starPort getFirmwareInformation] retain];
        for (id key in dict.keyEnumerator) {
            [message appendFormat:@"%@: %@\n", key, dict[key]];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Firmware"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
        
        [dict release];
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error"
                                                        message:@"Get firmware information failed"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    @finally
    {
        [SMPort releasePort:starPort];
    }
}

#pragma mark Open Cash Drawer

/*!
 *  This function opens the cashdraw connected to the printer
 *  This function just send the byte 0x07 to the printer which is the open cashdrawer command
 *
 *  @param  portName        Port name to use for communication. This should be (TCP:<IP Address>) or
 *                          (BT:<iOS Port Name>).
 *  @param  portSettings    Should be blank
 */
+ (void)openCashDrawerWithPortname:(NSString *)portName
                      portSettings:(NSString *)portSettings
                      drawerNumber:(NSUInteger)drawerNumber
{
    unsigned char opencashdrawer_command = 0x00;
    
    if (drawerNumber == 1) {
        opencashdrawer_command = 0x07; // BEL
    }
    else if (drawerNumber == 2) {
        opencashdrawer_command = 0x1a; // SUB
    }
    
    NSData *commands = [NSData dataWithBytes:&opencashdrawer_command length:1];
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
}

#pragma mark Check Status

/*!
 *  This function checks the status of the printer.
 *  The check status function can be used for both portable and non portable printers.
 *
 *  @param  portName        Port name to use for communication. This should be (TCP:<IP Address>) or
 *                          (BT:<iOS Port Name>).
 *  @param  portSettings    Should be blank
 */
+ (void)checkStatusWithPortname:(NSString *)portName
                   portSettings:(NSString *)portSettings
                  sensorSetting:(SensorActive)sensorActiveSetting
{
    SMPort *starPort = nil;
    @try
    {
        starPort = [SMPort getPort:portName :portSettings :10000];
        if (starPort == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port.\nRefer to \"getPort API\" in the manual."
                                                            message:@""
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
            return;
        }
        usleep(1000 * 1000);
        
        StarPrinterStatus_2 status;
        [starPort getParsedStatus:&status :2];
        
        NSString *message = @"";
        if (status.offline == SM_TRUE)
        {
            message = @"The printer is offline";
            if (status.coverOpen == SM_TRUE)
            {
                message = [message stringByAppendingString:@"\nCover is Open"];
            }
            else if (status.receiptPaperEmpty == SM_TRUE)
            {
                message = [message stringByAppendingString:@"\nOut of Paper"];
            }
        }
        else
        {
            message = @"The Printer is online";
        }
        
        NSString *drawerStatus;
        if (sensorActiveSetting == SensorActiveHigh)
        {
            drawerStatus = (status.compulsionSwitch == SM_TRUE) ? @"Open" : @"Close";
            message = [message stringByAppendingFormat:@"\nCash Drawer: %@", drawerStatus];
        }
        else if (sensorActiveSetting == SensorActiveLow)
        {
            drawerStatus = (status.compulsionSwitch == SM_FALSE) ? @"Open" : @"Close";
            message = [message stringByAppendingFormat:@"\nCash Drawer: %@", drawerStatus];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Status"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    @catch (PortException *exception)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Printer Error"
                                                        message:@"Get status failed"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    @finally
    {
        [SMPort releasePort:starPort];
    }
}

#pragma mark Cut

+ (void)performCutWithPortname:(NSString *)portName
                  portSettings:(NSString *)portSettings
                       cutType:(CutType)cuttype
{
    Byte autocutCommand[] = {0x1b, 0x64, 0x00};
    switch (cuttype) {
        case FULL_CUT:
            autocutCommand[2] = 48;
            break;
        case PARTIAL_CUT:
            autocutCommand[2] = 49;
            break;
        case FULL_CUT_FEED:
            autocutCommand[2] = 50;
            break;
        case PARTIAL_CUT_FEED:
            autocutCommand[2] = 51;
            break;
    }
    
    int commandSize = 3;
    
    NSData *dataToSentToPrinter = [[NSData alloc] initWithBytes:autocutCommand length:commandSize];
    
    [self sendCommand:dataToSentToPrinter portName:portName portSettings:portSettings timeoutMillis:10000];
    
    [dataToSentToPrinter release];
}


#pragma mark TextFormatting

+ (void)printTextWithPortname:(NSString *)portName
                 portSettings:(NSString *)portSettings
                  slashedZero:(BOOL)slashedZero
                    underline:(BOOL)underline
                     twoColor:(BOOL)twoColor
                   emphasized:(BOOL)emphasized
                    upperline:(BOOL)upperline
                   upsideDown:(BOOL)upsideDown
              heightExpansion:(BOOL)heightExpansion
               widthExpansion:(BOOL)widthExpansion
                   leftMargin:(unsigned char)leftMargin
                    alignment:(Alignment)alignment
                     textData:(unsigned char *)textData
                 textDataSize:(unsigned int)textDataSize
{
    NSMutableData *commands = [NSMutableData new];
    
	Byte initial[] = {0x1b, 0x40};
	[commands appendBytes:initial length:2];
	
    Byte slashedZeroCommand[] = {0x1b, 0x2f, 0x00};
    if (slashedZero) {
        slashedZeroCommand[2] = 49;
    } else {
        slashedZeroCommand[2] = 48;
    }
    [commands appendBytes:slashedZeroCommand length:3];
    
    Byte underlineCommand[] = {0x1b, 0x2d, 0x00};
    if (underline) {
        underlineCommand[2] = 49;
    } else {
        underlineCommand[2] = 48;
    }
    [commands appendBytes:underlineCommand length:3];
    
    Byte twoColorCommand[] = {0x1b, 0x00};
    if (twoColor) {
        twoColorCommand[1] = 0x34;
    } else {
        twoColorCommand[1] = 0x35;
    }
    [commands appendBytes:twoColorCommand length:2];
    
    Byte emphasizedPrinting[] = {0x1b, 0x00};
    if (emphasized) {
        emphasizedPrinting[1] = 69;
    } else {
        emphasizedPrinting[1] = 70;
    }
    [commands appendBytes:emphasizedPrinting length:2];
    
    Byte upperLineCommand[] = {0x1b, 0x5f, 0x00};
    if (upperline) {
        upperLineCommand[2] = 49;
    } else {
        upperLineCommand[2] = 48;
    }
    [commands appendBytes:upperLineCommand length:3];
    
    if (upsideDown) {
        Byte upsd = 0x0f;
        [commands appendBytes:&upsd length:1];
    } else {
        Byte upsd = 0x12;
        [commands appendBytes:&upsd length:1];
    }
    
    Byte characterHeightExpansionCommand[] = {0x1b, 0x68, 0x00};
    if (heightExpansion) {
        characterHeightExpansionCommand[2] = 49;
    } else {
        characterHeightExpansionCommand[2] = 48;
    }
    [commands appendBytes:characterHeightExpansionCommand length:3];
    
    Byte characterWidthExpansionCommand[] = {0x1b, 0x57, 0x00};
    if (widthExpansion) {
        characterWidthExpansionCommand[2] = 49;
    } else {
        characterWidthExpansionCommand[2] = 48;
    }
    [commands appendBytes:characterWidthExpansionCommand length:3];
    
    Byte leftMarginCommand[] = {0x1b, 0x6c, 0x00};
    leftMarginCommand[2] = leftMargin;
    [commands appendBytes:leftMarginCommand length:3];
    
    Byte alignmentCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    switch (alignment) {
        case Left:
            alignmentCommand[3] = 48;
            break;
        case Center:
            alignmentCommand[3] = 49;
            break;
        case Right:
            alignmentCommand[3] = 50;
            break;
    }
    [commands appendBytes:alignmentCommand length:4];
    
    [commands appendBytes:textData length:textDataSize];
    
    Byte lf = 0x0a;
    [commands appendBytes:&lf length:1];
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
    
    [commands release];
}

+ (void)printKanjiTextWithPortname:(NSString *)portName
                      portSettings:(NSString *)portSettings
                         kanjiMode:(int)kanjiMode
                         underline:(BOOL)underline
                          twoColor:(BOOL)twoColor
                        emphasized:(BOOL)emphasized
                         upperline:(BOOL)upperline
                        upsideDown:(BOOL)upsideDown
                    widthExpansion:(BOOL)widthExpansion
                        leftMargin:(unsigned char)leftMargin
                         alignment:(Alignment)alignment
                          textData:(unsigned char *)textData
                      textDataSize:(unsigned int)textDataSize
{
    NSMutableData *commands = [NSMutableData new];
    
	Byte initial[] = {0x1b, 0x40};
	[commands appendBytes:initial length:2];
    
    Byte kanjiModeCommand[] = {0x1b, 0x24, 0x00, 0x1b, 0x00};
    if (kanjiMode == 0)	{ // Shift-JIS
        kanjiModeCommand[2] = 0x01;
        kanjiModeCommand[4] = 0x71;
    } else {				// JIS
        kanjiModeCommand[2] = 0x00;
        kanjiModeCommand[4] = 0x70;
    }
    [commands appendBytes:kanjiModeCommand length:5];
    
    Byte underlineCommand[] = {0x1b, 0x2d, 0x00};
    if (underline) {
        underlineCommand[2] = 49;
    } else {
        underlineCommand[2] = 48;
    }
    [commands appendBytes:underlineCommand length:3];
    
    Byte twoColorCommand[] = {0x1b, 0x00};
    if (twoColor) {
        twoColorCommand[1] = 0x34;
    } else {
        twoColorCommand[1] = 0x35;
    }
    [commands appendBytes:twoColorCommand length:2];
    
    Byte emphasizedPrinting[] = {0x1b, 0x00};
    if (emphasized) {
        emphasizedPrinting[1] = 69;
    } else {
        emphasizedPrinting[1] = 70;
    }
    [commands appendBytes:emphasizedPrinting length:2];
    
    Byte upperLineCommand[] = {0x1b, 0x5f, 0x00};
    if (upperline) {
        upperLineCommand[2] = 49;
    } else {
        upperLineCommand[2] = 48;
    }
    [commands appendBytes:upperLineCommand length:3];
    
    if (upsideDown) {
        Byte upsd = 0x0f;
        [commands appendBytes:&upsd length:1];
    } else {
        Byte upsd = 0x12;
        [commands appendBytes:&upsd length:1];
    }
    
    Byte characterWidthExpansionCommand[] = {0x1b, 0x57, 0x00};
    if (widthExpansion) {
        characterWidthExpansionCommand[2] = 49;
    } else {
        characterWidthExpansionCommand[2] = 48;
    }
    [commands appendBytes:characterWidthExpansionCommand length:3];
    
    Byte leftMarginCommand[] = {0x1b, 0x6c, 0x00};
    leftMarginCommand[2] = leftMargin;
    [commands appendBytes:leftMarginCommand length:3];
    
    Byte alignmentCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    switch (alignment) {
        case Left:
            alignmentCommand[3] = 48;
            break;
        case Center:
            alignmentCommand[3] = 49;
            break;
        case Right:
            alignmentCommand[3] = 50;
            break;
    }
    [commands appendBytes:alignmentCommand length:4];
    
    [commands appendBytes:textData length:textDataSize];
    
    Byte lf = 0x0a;
    [commands appendBytes:&lf length:1];
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
    
    [commands release];
}

+ (void)printCHSTextWithPortname:(NSString *)portName
                    portSettings:(NSString *)portSettings
                       underline:(BOOL)underline
                        twoColor:(BOOL)twoColor
                      emphasized:(BOOL)emphasized
                       upperline:(BOOL)upperline
                      upsideDown:(BOOL)upsideDown
                  widthExpansion:(BOOL)widthExpansion
                      leftMargin:(unsigned char)leftMargin
                       alignment:(Alignment)alignment
                        textData:(unsigned char *)textData
                    textDataSize:(unsigned int)textDataSize
{
    NSMutableData *commands = [NSMutableData new];
    
	Byte initial[] = {0x1b, 0x40};
	[commands appendBytes:initial length:2];
    
    Byte underlineCommand[] = {0x1b, 0x2d, 0x00};
    if (underline) {
        underlineCommand[2] = 49;
    } else {
        underlineCommand[2] = 48;
    }
    [commands appendBytes:underlineCommand length:3];
    
    Byte twoColorCommand[] = {0x1b, 0x00};
    if (twoColor) {
        twoColorCommand[1] = 0x34;
    } else {
        twoColorCommand[1] = 0x35;
    }
    [commands appendBytes:twoColorCommand length:2];
    
    Byte emphasizedPrinting[] = {0x1b, 0x00};
    if (emphasized) {
        emphasizedPrinting[1] = 69;
    } else {
        emphasizedPrinting[1] = 70;
    }
    [commands appendBytes:emphasizedPrinting length:2];
    
    Byte upperLineCommand[] = {0x1b, 0x5f, 0x00};
    if (upperline) {
        upperLineCommand[2] = 49;
    } else {
        upperLineCommand[2] = 48;
    }
    [commands appendBytes:upperLineCommand length:3];
    
    if (upsideDown) {
        Byte upsd = 0x0f;
        [commands appendBytes:&upsd length:1];
    } else {
        Byte upsd = 0x12;
        [commands appendBytes:&upsd length:1];
    }
    
    Byte characterWidthExpansionCommand[] = {0x1b, 0x57, 0x00};
    if (widthExpansion) {
        characterWidthExpansionCommand[2] = 49;
    } else {
        characterWidthExpansionCommand[2] = 48;
    }
    [commands appendBytes:characterWidthExpansionCommand length:3];
    
    Byte leftMarginCommand[] = {0x1b, 0x6c, 0x00};
    leftMarginCommand[2] = leftMargin;
    [commands appendBytes:leftMarginCommand length:3];
    
    Byte alignmentCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    switch (alignment) {
        case Left:
            alignmentCommand[3] = 48;
            break;
        case Center:
            alignmentCommand[3] = 49;
            break;
        case Right:
            alignmentCommand[3] = 50;
            break;
    }
    [commands appendBytes:alignmentCommand length:4];
    
    [commands appendBytes:textData length:textDataSize];
    
    Byte lf = 0x0a;
    [commands appendBytes:&lf length:1];
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
    
    [commands release];
}

+ (void)printCHTTextWithPortname:(NSString *)portName
                    portSettings:(NSString *)portSettings
                       underline:(BOOL)underline
                        twoColor:(BOOL)twoColor
                      emphasized:(BOOL)emphasized
                       upperline:(BOOL)upperline
                      upsideDown:(BOOL)upsideDown
                  widthExpansion:(BOOL)widthExpansion
                      leftMargin:(unsigned char)leftMargin
                       alignment:(Alignment)alignment
                        textData:(unsigned char *)textData
                    textDataSize:(unsigned int)textDataSize
{
    NSMutableData *commands = [NSMutableData new];
    
	Byte initial[] = {0x1b, 0x40};
	[commands appendBytes:initial length:2];
    
    Byte underlineCommand[] = {0x1b, 0x2d, 0x00};
    if (underline) {
        underlineCommand[2] = 49;
    } else {
        underlineCommand[2] = 48;
    }
    [commands appendBytes:underlineCommand length:3];
    
    Byte twoColorCommand[] = {0x1b, 0x00};
    if (twoColor) {
        twoColorCommand[1] = 0x34;
    } else {
        twoColorCommand[1] = 0x35;
    }
    [commands appendBytes:twoColorCommand length:2];
    
    Byte emphasizedPrinting[] = {0x1b, 0x00};
    if (emphasized) {
        emphasizedPrinting[1] = 69;
    } else {
        emphasizedPrinting[1] = 70;
    }
    [commands appendBytes:emphasizedPrinting length:2];
    
    Byte upperLineCommand[] = {0x1b, 0x5f, 0x00};
    if (upperline) {
        upperLineCommand[2] = 49;
    } else {
        upperLineCommand[2] = 48;
    }
    [commands appendBytes:upperLineCommand length:3];
    
    if (upsideDown) {
        Byte upsd = 0x0f;
        [commands appendBytes:&upsd length:1];
    } else {
        Byte upsd = 0x12;
        [commands appendBytes:&upsd length:1];
    }
    
    Byte characterWidthExpansionCommand[] = {0x1b, 0x57, 0x00};
    if (widthExpansion) {
        characterWidthExpansionCommand[2] = 49;
    } else {
        characterWidthExpansionCommand[2] = 48;
    }
    [commands appendBytes:characterWidthExpansionCommand length:3];
    
    Byte leftMarginCommand[] = {0x1b, 0x6c, 0x00};
    leftMarginCommand[2] = leftMargin;
    [commands appendBytes:leftMarginCommand length:3];
    
    Byte alignmentCommand[] = {0x1b, 0x1d, 0x61, 0x00};
    switch (alignment) {
        case Left:
            alignmentCommand[3] = 48;
            break;
        case Center:
            alignmentCommand[3] = 49;
            break;
        case Right:
            alignmentCommand[3] = 50;
            break;
    }
    [commands appendBytes:alignmentCommand length:4];
    
    [commands appendBytes:textData length:textDataSize];
    
    Byte lf = 0x0a;
    [commands appendBytes:&lf length:1];
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
    
    [commands release];
}

#pragma mark Common

+ (void)sendCommand:(NSData *)commandsToPrint portName:(NSString *)portName portSettings:(NSString *)portSettings timeoutMillis:(u_int32_t)timeoutMillis
{
    int commandSize = (int)commandsToPrint.length;
    unsigned char *dataToSentToPrinter = (unsigned char *)malloc(commandSize);
    [commandsToPrint getBytes:dataToSentToPrinter length:commandSize];
    
    SMPort *starPort = nil;
    @try
    {
        starPort = [SMPort getPort:portName :portSettings :timeoutMillis];
        if (starPort == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port.\nRefer to \"getPort API\" in the manual."
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
        
        struct timeval endTime;
        gettimeofday(&endTime, NULL);
        endTime.tv_sec += 30;
        
        int totalAmountWritten = 0;
        while (totalAmountWritten < commandSize)
        {
            int remaining = commandSize - totalAmountWritten;
            int amountWritten = [starPort writePort:dataToSentToPrinter :totalAmountWritten :remaining];
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
            return;
        }
        
        starPort.endCheckedBlockTimeoutMillis = 30000;
        [starPort endCheckedBlock:&status :2];
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

#pragma mark Sample Receipt (Line)


+ (NSData *)english3inchSampleReceipt
{
    NSMutableData *commands = [NSMutableData data];
    
    [commands appendBytes:"\x1b\x1d\x61\x01" length:4]; // Alignment (center)
    
    [commands appendData:[@"\nStar Clothing Boutique\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendData:[@"123 Star Road\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendData:[@"City, State 12345\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x00" length:4];    // Alignment
    [commands appendBytes:"\x1b\x44\x02\x10\x22\x00" length:6]; // Set horizontal tab <ESC> <D> n1 n2 ...nk NUL
    
    [commands appendData:[@"Date: MM/DD/YYYY" dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendData:[@"             Time:HH:MM PM\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"------------------------------------------\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x45" length:2]; // bold
    [commands appendData:[@"SALE \r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendBytes:"\x1b\x46" length:2]; // bold off
    
    [commands appendData:[@"SKU " dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x09" length:1];
    
    [commands appendData:[@"Description \x09 Total\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"300678566 \tPLAIN T-SHIRT\t  10.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendData:[@"300692003 \tBLACK DENIM\t  29.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendData:[@"300651148 \tBLUE DENIM\t  29.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendData:[@"300642980 \tSTRIPED DRESS\t  49.99\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendData:[@"300638471 \tBLACK BOOTS\t  35.99\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Subtotal \t\t 156.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendData:[@"Tax \t\t   0.00\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"------------------------------------------\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Total" dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendBytes:"\x06\x09\x1b\x69\x01\x01" length:6];    // Character expansion
    [commands appendData:[@"                  $156.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendBytes:"\x1b\x69\x00\x00" length:4];    // Cancel Character Expansion
    
    [commands appendData:[@"------------------------------------------\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Charge\r\n159.95\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendData:[@"Visa XXXX-XXXX-XXXX-0123\r\n\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x34" length:2]; // Specify White/Black Invert
    [commands appendData:[@"Refunds and Exchanges" dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendBytes:"\x1b\x35" length:2]; // Cancel White/Black Invert
    [commands appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendData:[@"Within" dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendBytes:"\x1b\x2d\x01" length:3];
    [commands appendData:[@" 30 days" dataUsingEncoding:NSASCIIStringEncoding]];
    [commands appendBytes:"\x1b\x2d\x00" length:3];
    [commands appendData:[@" with receipt\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [commands appendBytes:"\x1b\x64\x02" length:3]; // Cut
    [commands appendBytes:"\x07" length:1];         // Kick cash drawer
    
    NSData *result = [NSData dataWithData:commands];

    return result;
}

+ (NSData *)french3inchSampleReceipt
{
    const NSStringEncoding ENCODING = NSWindowsCP1252StringEncoding;
    
    NSMutableData *commands = [NSMutableData data];
    
    [commands appendBytes:"\x1b\x1d\x74\x20" length:sizeof("\x1b\x1d\x74\x20") - 1]; // Code Page #1252 (Windows Latin-1)
    
    [commands appendBytes:"\x1b\x1d\x61\x01" length:sizeof("\x1b\x1d\x61\x01") - 1]; // Alignment (center)
    
    // [commands appendData:[@"[If loaded.. Logo1 goes here]\r\n" dataUsingEncoding:ENCODING]];
    
    // [commands appendBytes:"\x1b\x1c\x70\x01\x00\r\n" length:sizeof("\x1b\x1c\x70\x01\x00\r\n") - 1]; // Stored Logo Printing
    [commands appendBytes:"\x1b\x57\x01" length:sizeof("\x1b\x57\x01") - 1];
    
    [commands appendBytes:"\x1b\x68\x01" length:sizeof("\x1b\x68\x01") - 1];
    
    [commands appendData:[@"\nORANGE\r\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x57\x00" length:sizeof("\x1b\x57\x00") - 1];
    
    [commands appendBytes:"\x1b\x68\x00" length:sizeof("\x1b\x68\x00") - 1];
    
    [commands appendData:[@"36 AVENUE LA MOTTE PICQUET\r\n\r\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x44\x02\x06\x0a\x10\x14\x1a\x22\x00"
                   length:sizeof("\x1b\x44\x02\x06\x0a\x10\x14\x1a\x22\x00") - 1]; // Set horizontal tab
    
    [commands appendData:[@"------------------------------------------\r\n"
                           "Date: MM/DD/YYYY    Heure: HH:MM\r\n"
                           "Boutique: OLUA23    Caisse: 0001\r\n"
                           "Conseiller: 002970  Ticket: 3881\r\n"
                           "------------------------------------------\r\n\r\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x1d\x61\x00" length:sizeof("\x1b\x1d\x61\x00") - 1]; // Alignment
    
    [commands appendData:[@"Vous avez été servi par : Souad\r\n\r\n"
                           "CAC IPHONE ORANGE\r\n"
                           "3700615033581 \t1\t X\t 19.99€\t  19.99€\r\n\r\n"    
                           "dont contribution environnementale :\r\n"
                           "CAC IPHONE ORANGE\t\t  0.01€\r\n"
                           "------------------------------------------\r\n"
                           "1 Piéce(s) Total :\t\t\t  19.99€\r\n"
                           "Mastercard Visa  :\t\t\t  19.99€\r\n\r\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x1d\x61\x01" length:sizeof("\x1b\x1d\x61\x01") - 1]; // Alignment (center)
    
    [commands appendData:[@"Taux TVA    Montant H.T.   T.V.A\r\n"
                           "  20%          16.66€      3.33€\r\n"
                           "Merci de votre visite et. à bientôt.\r\n"
                           "Conservez votre ticket il\r\n"
                           "vous sera demandé pour tout échange.\r\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x64\x02" length:sizeof("\x1b\x64\x02") - 1]; // Cut
    
    [commands appendBytes:"\x07" length:sizeof("\x07") - 1]; // Kick cash drawer
    
    NSData *result = [NSData dataWithData:commands];
    return result;
}

+ (NSData *)portuguese3inchSampleReceipt
{
    const NSStringEncoding ENCODING = NSWindowsCP1252StringEncoding;
    
    NSMutableData *commands = [NSMutableData data];
    
    [commands appendBytes:"\x1b\x1d\x74\x20" length:sizeof("\x1b\x1d\x74\x20") - 1]; // Code Page #1252 (Windows Latin-1)
    
    [commands appendBytes:"\x1b\x44\x02\x06\x0a\x10\x14\x1a\x22\x24\x28\x00"
                   length:sizeof("\x1b\x44\x02\x06\x0a\x10\x14\x1a\x22\x24\x28\x00") - 1]; // Set horizontal tab
    
    [commands appendBytes:"\x1b\x1d\x61\x01" length:sizeof("\x1b\x1d\x61\x01") - 1]; // Alignment (center)
    
    // [commands appendData:[@"[If loaded.. Logo1 goes here]\r\n" dataUsingEncoding:ENCODING]];
    
    // [commands appendBytes:"\x1b\x1c\x70\x01\x00\r\n" length:sizeof("\x1b\x1c\x70\x01\x00\r\n") - 1]; // Stored Logo Printing
    
    // Character expansion
    [commands appendBytes:"\x1b\x68\x01" length:sizeof("\x1b\x68\x01") - 1];
    
    [commands appendData:[@"\nCOMERCIAL DE ALIMENTOS CARREFOUR LTDA.\r\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x68\x00" length:sizeof("\x1b\x68\x00") - 1];
    
    [commands appendData:[@"Avenida Moyses Roysen, S/N　Vila Guilherme\r\n"
                           "Cep: 02049-010 – Sao Paulo – SP\r\n"
                           "CNPJ: 62.545.579/0013-69\r\n"
                           "IE:110.819.138.118  IM: 9.041.041-5\r\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x1d\x61\x00" length:sizeof("\x1b\x1d\x61\x00") - 1]; // Alignment
    
    [commands appendBytes:"\x1b\x44\x02\x10\x22\x00" length:sizeof("\x1b\x44\x02\x10\x22\x00") - 1]; // Set horizontal tab
    
    [commands appendData:[@"------------------------------------------\r\n"
                           "MM/DD/YYYY HH:MM:SS  CCF:133939 COO:227808\r\n"
                           "------------------------------------------\r\n"
                           "CUPOM FISCAL\r\n"
                           "------------------------------------------\r\n"
                           "01 2505 CAFÉ DO PONTO TRAD A  1un F1 8,15)\r\n"
                           "02 2505 CAFÉ DO PONTO TRAD A  1un F1 8,15)\r\n"
                           "03 2505 CAFÉ DO PONTO TRAD A  1un F1 8,15)\r\n"
                           "04 6129 AGU MIN NESTLE 510ML  1un F1 1,39)\r\n"
                           "05 6129 AGU MIN NESTLE 510ML  1un F1 1,39)\r\n"
                           "------------------------------------------\r\n" dataUsingEncoding:ENCODING]];
    
    // Character expansion
    [commands appendBytes:"\x1b\x69\x00\x01" length:sizeof("\x1b\x69\x00\x01") - 1];
    
    [commands appendData:[@"TOTAL  R$ \t\t\t  27,23\r\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x69\x00\x00" length:sizeof("\x1b\x69\x00\x00") - 1];
    
    [commands appendData:[@"DINHEIROv \t\t\t\t\t\t  29,00\r\n"
                           "TROCO R$  \t\t\t\t\t\t   1,77\r\n"
                           "Valor dos Tributos R$2,15 (7,90%)\r\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x1d\x61\x01" length:sizeof("\x1b\x1d\x61\x01") - 1]; // Alignment (center)
    
    [commands appendData:[@"ITEM(S) CINORADIS 5\r\n"
                           "OP.:15326  PDV:9  BR,BF:93466\r\n"
                           "OBRIGADO PERA PREFERENCIA.\r\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x57\x01" length:sizeof("\x1b\x57\x01") - 1];
    
    [commands appendData:[@"VOLTE SEMPRE!\r\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x57\x00" length:sizeof("\x1b\x57\x00") - 1];
    
    [commands appendData:[@"SAC 0800 724 2822\r\n"
                           "------------------------------------------\r\n"
                           "MD5:  fe028828a532a7dbaf4271155aa4e2db\r\n"
                           "Calypso_CA CA.20.c13 – Unisys Brasil\r\n"
                           "------------------------------------------\r\n"
                           "DARUMA AUTOMAÇÃO   MACH 2\r\n"
                           "ECF-IF VERSÃO:01,00,00 ECF:093\r\n"
                           "Lj:0204 OPR:ANGELA JORGE\r\n"
                           "DDDDDDDDDAEHFGBFCC\r\n"
                           "MM/DD/YYYY HH:MM:SS\r\n"
                           "FAB:DR0911BR000000275026\r\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x1d\x61\x00" length:sizeof("\x1b\x1d\x61\x00") - 1];
    
    [commands appendBytes:"\x1b\x64\x02" length:sizeof("\x1b\x64\x02") - 1]; // Cut
    
    [commands appendBytes:"\x07" length:sizeof("\x07") - 1]; // Kick cash drawer
    
    NSData *result = [NSData dataWithData:commands];
    return result;
}

+ (NSData *)spanish3inchSampleReceipt
{
    const NSStringEncoding ENCODING = NSWindowsCP1252StringEncoding;

    NSMutableData *commands = [NSMutableData data];
    
    [commands appendBytes:"\x1b\x1d\x74\x20" length:sizeof("\x1b\x1d\x74\x20") - 1]; // Code Page #1252 (Windows Latin-1)
    
    [commands appendBytes:"\x1b\x44\x02\x06\x0a\x10\x14\x1a\x22\x24\x28\x00"
                   length:sizeof("\x1b\x44\x02\x06\x0a\x10\x14\x1a\x22\x24\x28\x00") - 1]; // Set horizontal tab
    
    [commands appendBytes:"\x1b\x1d\x61\x01" length:sizeof("\x1b\x1d\x61\x01") - 1]; // Alignment (center)
    
    // [commands appendData:[@"[If loaded.. Logo1 goes here]\r\n" dataUsingEncoding:ENCODING]];
    
    // [commands appendBytes:"\x1b\x1c\x70\x01\x00\r\n" length:sizeof("\x1b\x1c\x70\x01\x00\r\n") - 1]; // Stored Logo Printing
    
    // Character expansion
    [commands appendBytes:"\x1b\x68\x01" length:sizeof("\x1b\x68\x01") - 1];
    
    [commands appendData:[@"BAR RESTAURANT EL POZO\r\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x68\x00" length:sizeof("\x1b\x68\x00") - 1];
    
    [commands appendData:[@"C/.ROCAFORT 187 08029 BARCELONA\r\n"
                           "NIF :X-3856907Z  TEL :934199465\r\n"
                           "------------------------------------------\r\n"
                           "MESA: 100 P: - FECHA: YYYY-MM-DD\r\n"
                           "CAN P/U DESCRIPCION  SUMA\r\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x1d\x61\x00" length:sizeof("\x1b\x1d\x61\x00") - 1]; // Alignment
    
    [commands appendData:[@"------------------------------------------\r\n" 
                           " 4\t 3,00\t JARRA  CERVESA \t\t 12,00\r\n"
                           " 1\t 1,60\t COPA DE CERVESA\t\t  1,60\r\n"
                           "------------------------------------------\r\n"
                           "\t\t\t\t\t SUB TOTAL :\t\t 13,60\r\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x57\x01" length:sizeof("\x1b\x57\x01") - 1];
    
    [commands appendBytes:"\x1b\x1d\x61\x02" length:sizeof("\x1b\x1d\x61\x02") - 1];
    
    [commands appendData:[@"TOTAL:    13,60 EUROS\r\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x1d\x61\x00" length:sizeof("\x1b\x1d\x61\x00") - 1];
    
    [commands appendBytes:"\x1b\x57\x00" length:sizeof("\x1b\x57\x00") - 1];
    
    [commands appendData:[@"NO: 000018851  IVA INCLUIDO\r\n" dataUsingEncoding:ENCODING]];
    
    [commands appendData:[@"------------------------------------------\r\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x1d\x61\x01" length:sizeof("\x1b\x1d\x61\x01") - 1];
    
    [commands appendBytes:"\x1b\x68\x01" length:sizeof("\x1b\x68\x01") - 1];
    
    [commands appendData:[@"**** GRACIAS POR SU VISITA! ****\r\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x68\x00" length:sizeof("\x1b\x68\x00") - 1];
    
    [commands appendBytes:"\x1b\x68\x00" length:sizeof("\x1b\x68\x00") - 1];
    
    [commands appendBytes:"\x1b\x64\x02" length:sizeof("\x1b\x64\x02") - 1]; // Cut
    
    [commands appendBytes:"\x07" length:sizeof("\x07") - 1]; // Kick cash drawer

    NSData *result = [NSData dataWithData:commands];
    
    return result;
}

+ (NSData *)russian3inchSampleReceipt
{
    const NSStringEncoding ENCODING = NSWindowsCP1251StringEncoding;
    
    NSMutableData *commands = [NSMutableData data];
    
    [commands appendBytes:"\x1b\x1d\x74\x22" length:sizeof("\x1b\x1d\x74\x22") - 1]; // Code Page #1251 (Windows Latin-1)
    
    [commands appendBytes:"\x1b\x44\x02\x06\x0a\x10\x14\x1a\x22\x24\x28\x00"
                   length:sizeof("\x1b\x44\x02\x06\x0a\x10\x14\x1a\x22\x24\x28\x00") - 1]; // Set horizontal tab
    
    [commands appendBytes:"\x1b\x1d\x61\x01" length:sizeof("\x1b\x1d\x61\x01") - 1];
    
    // Character expansion
    [commands appendBytes:"\x1b\x57\x01" length:sizeof("\x1b\x57\x01") - 1];
    
    [commands appendBytes:"\x1b\x68\x01" length:sizeof("\x1b\x68\x01") - 1];
    
    [commands appendData:[@"Р  Е  Л  А  К  С\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x57\x00" length:sizeof("\x1b\x57\x00") - 1];
    
    [commands appendBytes:"\x1b\x68\x00" length:sizeof("\x1b\x68\x00") - 1];
    
    [commands appendData:[@"ООО “РЕЛАКС”\n"
                           "СПб., Малая Балканская, д. 38, лит. А\n"
                           "тел. 307-07-12\n"
                           "РЕГ №322736 ИНН : 123321\n"
                           "01  Белякова И.А.  КАССА: 0020 ОТД.01\n"
                           "ЧЕК НА ПРОДАЖУ  No 84373\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x1d\x61\x00" length:sizeof("\x1b\x1d\x61\x00") - 1];
    
    [commands appendData:[@"------------------------------------------\r\n"
                           "1. \t Яблоки Айдаред, кг \t 144.50\n"
                           "2. \t Соус соевый Sen So \t  36.40\n"
                           "3. \t Соус томатный Клас \t  19.90\n"
                           "4. \t Ребра свиные в.к м \t  78.20\n"
                           "5. \t Масло подсол раф д \t 114.00\n"
                           "6. \t Блокнот 10х14см сп \t 164.00\n"
                           "7. \t Морс Северная Ягод \t  99.90\n"
                           "8. \t Активия Биойогурт  \t  43.40\n"
                           "9. \t Бублики Украинские \t  26.90\n"
                           "10.\t Активия Биойогурт  \t  43.40\n"
                           "11.\t Сахар-песок 1кг    \t  58.40\n"
                           "12.\t Хлопья овсяные Ясн \t  38.40\n"
                           "13.\t Кинза 50г          \t  39.90\n"
                           "14.\t Пемза “Сердечко” .Т\t  37.90\n"
                           "15.\t Приправа Santa Mar \t  47.90\n"
                           "16.\t Томаты слива Выбор \t 162.00\n"
                           "17.\t Бонд Стрит Ред Сел \t  56.90\n"
                           "------------------------------------------\r\n"
                           "------------------------------------------\r\n"
                           "ДИСКОНТНАЯ КАРТА  No: 2440012489765\n"
                           "------------------------------------------\r\n"
                           "ИТОГО  К  ОПЛАТЕ \t = 1212.00\n"
                           "НАЛИЧНЫЕ         \t = 1212.00\n"
                           "ВАША СКИДКА : 0.41\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x1d\x61\x01" length:sizeof("\x1b\x1d\x61\x01") - 1];
    
    [commands appendData:[@"ЦЕНЫ УКАЗАНЫ С УЧЕТОМ СКИДКИ\n"
                           "08-02-2015 09:49  0254.0130604\n"
                           "00083213 #060127\n"
                           "СПАСИБО ЗА ПОКУПКУ !\n"
                           "МЫ  ОТКРЫТЫ ЕЖЕДНЕВНО С 9 ДО 23\n"
                           "СОХРАНЯЙТЕ, ПОЖАЛУЙСТА , ЧЕК\n" dataUsingEncoding:ENCODING]];
    
    [commands appendBytes:"\x1b\x1d\x61\x00" length:sizeof("\x1b\x1d\x61\x00") - 1];
    
    [commands appendBytes:"\x1b\x64\x02" length:sizeof("\x1b\x64\x02") - 1]; // Cut
    
    [commands appendBytes:"\x07" length:sizeof("\x07") - 1]; // Kick cash drawer
    
    return commands;
}

+ (NSData *)japanese3inchSampleReceipt
{
    NSMutableData *commands = [NSMutableData new];
    
    [commands appendBytes:"\x1b\x40"
                   length:sizeof("\x1b\x40") - 1];    // 初期化
    
    [commands appendBytes:"\x1b\x24\x31"
                   length:sizeof("\x1b\x24\x31") - 1];    // 漢字モード設定
    
    [commands appendBytes:"\x1b\x1d\x61\x31"
                   length:sizeof("\x1b\x1d\x61\x31") - 1];    // 中央揃え設定
    
    [commands appendBytes:"\x1b\x69\x02\x00"
                   length:sizeof("\x1b\x69\x02\x00") - 1];    // 文字縦拡大設定
    
    [commands appendBytes:"\x1b\x45"
                   length:sizeof("\x1b\x45") - 1];    // 強調印字設定
    
    [commands appendData:[@"スター電機\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendBytes:"\x1b\x69\x01\x00"
                   length:sizeof("\x1b\x69\x01\x00") - 1];    // 文字縦拡大設定
    
    [commands appendData:[@"修理報告書　兼領収書\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendBytes:"\x1b\x69\x00\x00"
                   length:sizeof("\x1b\x69\x00\x00") - 1];    // 文字縦拡大解除
    
    [commands appendBytes:"\x1b\x46"
                   length:sizeof("\x1b\x46") - 1];    // 強調印字解除
    
    [commands appendData:[@"------------------------------------------\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendBytes:"\x1b\x1d\x61\x30"
                   length:sizeof("\x1b\x1d\x61\x30") - 1];    // 左揃え設定
    
    [commands appendData:[@"発行日時：YYYY年MM月DD日HH時MM分" "\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendData:[@"TEL：054-347-XXXX\n\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendData:[@"        ｲｹﾆｼ  ｼｽﾞｺ  ｻﾏ\n" dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendData:[@"　お名前：池西  静子　様\n"
                           "　御住所：静岡市清水区七ツ新屋\n"
                           "　　　　　５３６番地\n"
                           "　伝票番号：No.12345-67890\n\n"
                           "　この度は修理をご用命頂き有難うございます。\n"
                           " 今後も故障など発生した場合はお気軽にご連絡ください。\n\n"
                          dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendBytes:"\x1b\x52\x08" length:sizeof("\x1b\x52\x08") - 1];  // 国際文字:日本
    
    [commands appendData:[@"品名／型名　\t     数量\t      金額　     備考\n"
                           "------------------------------------------\n"
                           "制御基板　　\t       1\t      10,000     配達\n"
                           "操作スイッチ\t       1\t       3,800     配達\n"
                           "パネル　　　\t       1\t       2,000     配達\n"
                           "技術料　　　\t       1\t      15,000\n"
                           "出張費用　　\t       1\t       5,000\n"
                          "------------------------------------------\n"
                          dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendData:[@"\n"
                          "                       小計       \\ 35,800\n"
                          "                       内税       \\  1,790\n"
                          "                       合計       \\ 37,590\n\n"
                          "　お問合わせ番号　　12345-67890\n\n\n\n"
                          dataUsingEncoding:NSShiftJISStringEncoding]];
    
    [commands appendBytes:"\x1b\x64\x33"
                   length:sizeof("\x1b\x64\x33") - 1];    // カット
    
    [commands appendBytes:"\x07"
                   length:sizeof("\x07") - 1];     // ドロワオープン
    
    NSData *result = [[[NSData alloc] initWithData:commands] autorelease];
    [commands release];
    
    return result;
}

+ (NSData *)simplifiedChinese3inchSampleReceipt
{
    NSMutableData *commands = [NSMutableData new];
    
    [commands appendBytes:"\x1b\x40"
                   length:sizeof("\x1b\x40") - 1];            // 初期化
    
    [commands appendBytes:"\x1b\x44\x10\x00"
                   length:sizeof("\x1b\x44\x10\x00") - 1];    // 水平タブ位置設定
    
    [commands appendBytes:"\x1b\x1d\x61\x31"
                   length:sizeof("\x1b\x1d\x61\x31") - 1];    // 中央揃え設定
    
    [commands appendBytes:"\x1b\x57\x31"
                   length:sizeof("\x1b\x57\x31") - 1];        // 文字縦拡大設定
    
    [commands appendBytes:"\x1b\x45"
                   length:sizeof("\x1b\x45") - 1];            // 強調印字設定
    
    [commands appendData:[@"STAR便利店\n"
                           "欢迎光临\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
    
    [commands appendBytes:"\x1b\x57\x30"
                   length:sizeof("\x1b\x57\x30") - 1];        // 文字縦拡大解除
    
    [commands appendBytes:"\x1b\x46"
                   length:sizeof("\x1b\x46") - 1];            // 強調印字解除
    
    [commands appendData:[@"Unit 1906-08, 19/F, Enterprise Square 2,\n"
                           "　3 Sheung Yuet Road, Kowloon Bay, KLN\n"
                           "\n"
                           "Tel : (852) 2795 2335\n"
                           "\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
    
    [commands appendBytes:"\x1b\x1d\x61\x30"
                   length:sizeof("\x1b\x1d\x61\x30") - 1];    // 左揃え設定
    
    [commands appendData:[@"货品名称   　          数量  　   价格\n"
                           "------------------------------------------\n"
                           "\n"
                           "罐装可乐\n"
                           "* Coke  \x09         1        7.00\n"
                           "纸包柠檬茶\n"
                           "* Lemon Tea  \x09         2       10.00\n"
                           "热狗\n"
                           "* Hot Dog   \x09         1       10.00\n"
                           "薯片(50克装)\n"
                           "* Potato Chips(50g)\x09      1       11.00\n"
                           "------------------------------------------\n"
                           "\n"
                           "\x09      总数 :\x09     38.00\n"
                           "\x09      现金 :\x09     38.00\n"
                           "\x09      找赎 :\x09      0.00\n"
                           "\n"
                           "卡号码 Card No.       : 88888888\n"
                           "卡余额 Remaining Val. : 88.00\n"
                           "机号   Device No.     : 1234F1\n"
                           "\n"
                           "\n"
                           "DD/MM/YYYY  HH:MM:SS  交易编号 : 88888\n"
                           "\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
    
    [commands appendBytes:"\x1b\x1d\x61\x31"
                   length:sizeof("\x1b\x1d\x61\x31") - 1];    // 中央揃え設定
    
    [commands appendData:[@"收银机 : 001  收银员 : 180\n" dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
    
    [commands appendBytes:"\x1b\x1d\x61\x30"
                   length:sizeof("\x1b\x1d\x61\x30") - 1];    // 左揃え設定
    
    [commands appendBytes:"\x1b\x64\x33"
                   length:sizeof("\x1b\x64\x33") - 1];        // カット
    
    [commands appendBytes:"\x07"
                   length:sizeof("\x07") - 1];                // ドロワオープン
    
    NSData *result = [[[NSData alloc] initWithData:commands] autorelease];
    [commands release];
    
    return result;
}

+ (NSData *)traditionalChinese3inchSampleReceipt
{
    NSMutableData *commands = [NSMutableData new];
    
    [commands appendBytes:"\x1b\x40"
                   length:sizeof("\x1b\x40") - 1];            // 初期化
    
    [commands appendBytes:"\x1b\x44\x10\x00"
                   length:sizeof("\x1b\x44\x10\x00") - 1];    // 水平タブ位置設定
    
    [commands appendBytes:"\x1b\x1d\x61\x31"
                   length:sizeof("\x1b\x1d\x61\x31") - 1];    // 中央揃え設定
    
    [commands appendBytes:"\x1b\x57\x31"
                   length:sizeof("\x1b\x57\x31") - 1];        // 文字縦拡大設定
    
    [commands appendBytes:"\x1b\x45"
                   length:sizeof("\x1b\x45") - 1];            // 強調印字設定
    
    [commands appendData:[@"Star Micronics\n" dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x57\x30"
                   length:sizeof("\x1b\x57\x30") - 1];        // 文字縦拡大解除
    
    [commands appendBytes:"\x1b\x46"
                   length:sizeof("\x1b\x46") - 1];            // 強調印字解除
    
    [commands appendData:[@"------------------------------------------\n" dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x57\x31"
                   length:sizeof("\x1b\x57\x31") - 1];        // 文字縦拡大設定
    
    [commands appendData:[@"電子發票證明聯\n"
                           "103年01-02月\n"
                           "EV-99999999\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x57\x30"
                   length:sizeof("\x1b\x57\x30") - 1];        // 文字縦拡大解除
    
    [commands appendBytes:"\x1b\x1d\x61\x30"
                   length:sizeof("\x1b\x1d\x61\x30") - 1];    // 左揃え設定
    
    [commands appendData:[@"2014/01/15 13:00\n"
                           "隨機碼 : 9999    總計 : 999\n"
                           "賣方 : 99999999\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    // 1D barcode example
    [commands appendBytes:"\x1b\x1d\x61\x01"
                   length:sizeof("\x1b\x1d\x61\x01") - 1];
    [commands appendBytes:"\x1b\x62\x35\x31\x33\x20"
                   length:sizeof("\x1b\x62\x35\x31\x33\x20") - 1];
    
    [commands appendBytes:"999999999\x1e\r\n"
                   length:sizeof("999999999\x1e\r\n") - 1];
    
    [commands appendBytes:"\x1b\x1d\x61\x30"
                   length:sizeof("\x1b\x1d\x61\x30") - 1];    // 左揃え設定
    
    [commands appendData:[@"商品退換請持本聯及銷貨明細表。\n"
                           "9999999-9999999 999999-999999 9999\n\n\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x1d\x61\x31"
                   length:sizeof("\x1b\x1d\x61\x31") - 1];    // 中央揃え設定
    
    [commands appendData:[@"銷貨明細表 　(銷售)\n" dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x1d\x61\x32"
                   length:sizeof("\x1b\x1d\x61\x32") - 1];    // 右揃え設定
    
    [commands appendData:[@"2014-01-15 13:00:02\n" dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x1d\x61\x30"
                   length:sizeof("\x1b\x1d\x61\x30") - 1];    // 左揃え設定
    
    [commands appendData:[@"\n"
                           "烏龍袋茶2g20入  \x09           55 x2 110TX\n"
                           "茉莉烏龍茶2g20入  \x09         55 x2 110TX\n"
                           "天仁觀音茶2g*20   \x09         55 x2 110TX\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x45"
                   length:sizeof("\x1b\x45") - 1];            // 強調印字設定
    
    [commands appendData:[@"      小　 計 :\x09             330\n"
                           "      總   計 :\x09             330\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x46"
                   length:sizeof("\x1b\x46") - 1];            // 強調印字解除
    
    [commands appendData:[@"------------------------------------------\n"
                           "現 金\x09             400\n"
                           "      找　 零 :\x09              70\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x45"
                   length:sizeof("\x1b\x45") - 1];            // 強調印字設定
    
    [commands appendData:[@" 101 發票金額 :\x09             330\n" dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x46"
                   length:sizeof("\x1b\x46") - 1];            // 強調印字解除
    
    [commands appendData:[@"2014-01-15 13:00\n" dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    
    // 1D barcode example
    [commands appendBytes:"\x1b\x1d\x61\x01"
                   length:sizeof("\x1b\x1d\x61\x01") - 1];
    [commands appendBytes:"\x1b\x62\x35\x31\x33\x20"
                   length:sizeof("\x1b\x62\x35\x31\x33\x20") - 1];
    
    [commands appendBytes:"999999999\x1e\r\n"
                   length:sizeof("999999999\x1e\r\n") - 1];
    
    [commands appendBytes:"\x1b\x1d\x61\x30"
                   length:sizeof("\x1b\x1d\x61\x30") - 1];    // 左揃え設定
    
    [commands appendData:[@"商品退換、贈品及停車兌換請持本聯。\n"
                           "9999999-9999999 999999-999999 9999\n"
                          dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)]];
    
    [commands appendBytes:"\x1b\x64\x33"
                   length:sizeof("\x1b\x64\x33") - 1];        // カット
    
    [commands appendBytes:"\x07"
                   length:sizeof("\x07") - 1];                // ドロワオープン
    
    NSData *result = [[[NSData alloc] initWithData:commands] autorelease];
    [commands release];
    
    return result;
}

+ (void)printSampleReceiptWithPortName:(NSString *)portName
                          portSettings:(NSString *)portSettings
                            paperWidth:(SMPaperWidth)paperWidth
                              language:(SMLanguage)language
{
    NSString *paperWidthString = nil;
    switch (paperWidth) {
        case SMPaperWidth2inch:
            paperWidthString = @"2inch";
            break;
        case SMPaperWidth3inch:
            paperWidthString = @"3inch";
            break;
        case SMPaperWidth4inch:
            paperWidthString = @"4inch";
            break;
    }
    
    NSString *languageString = nil;
    switch (language) {
        case SMLanguageEnglish:
            languageString = @"english";
            break;
        case SMLanguageFrench:
            languageString = @"french";
            break;
        case SMLanguagePortuguese:
            languageString = @"portuguese";
            break;
        case SMLanguageSpanish:
            languageString = @"spanish";
            break;
        case SMLanguageRussian:
            languageString = @"russian";
            break;
        case SMLanguageJapanese:
            languageString = @"japanese";
            break;
        case SMLanguageSimplifiedChinese:
            languageString = @"simplifiedChinese";
            break;
        case SMLanguageTraditionalChinese:
            languageString = @"traditionalChinese";
            break;
        default:
            break;
    }
    
    NSString *methodName = [NSString stringWithFormat:@"%@%@SampleReceipt", languageString, paperWidthString];
    SEL selector = NSSelectorFromString(methodName);
    if ([self respondsToSelector:selector] == NO) {
        return;
    }
    
    NSData *commands = [[self performSelector:selector] retain];
    
    [self sendCommand:commands portName:portName portSettings:portSettings timeoutMillis:10000];
    
    [commands release];
}

#pragma mark Bluetooth Setting

+ (SMBluetoothManager *)loadBluetoothSetting:(NSString *)portName
                                portSettings:(NSString *)portSettings
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error"
                                                     message:@""
                                                    delegate:nil
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"OK", nil] autorelease];
    
    if ([portName rangeOfString:@"BT:" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 3)].location == NSNotFound) {
        alert.message = @"This function is available via the bluetooth interface only.";
        [alert show];
        return nil;
    }
    
    SMDeviceType deviceType;
    SMPrinterType printerType = [AppDelegate parsePortSettings:portSettings];
    if (printerType == SMPrinterTypeDesktopPrinterStarLine) {
        deviceType = SMDeviceTypeDesktopPrinter;
    } else {
        deviceType = SMDeviceTypePortablePrinter;
    }
    
    SMBluetoothManager *manager = [[[SMBluetoothManager alloc] initWithPortName:portName deviceType:deviceType] autorelease];
    if (manager == nil) {
        alert.message = @"initWithPortName:deviceType: is failure.";
        [alert show];
        return nil;
    }
    
    if ([manager open] == NO) {
        alert.message = @"open is failure.";
        [alert show];
        return nil;
    }
    
    if ([manager loadSetting] == NO) {
        alert.message = @"loadSetting is failure.";
        [alert show];
        [manager close];
        return nil;
    }
    
    [manager close];
    
    return manager;
}

#pragma mark Disconnect (Bluetooth)

+ (void)disconnectPort:(NSString *)portName
          portSettings:(NSString *)portSettings
               timeout:(u_int32_t)timeout
{
    SMPort *port = [SMPort getPort:portName :portSettings :timeout];
    if (port == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Open Port.\nRefer to \"getPort API\" in the manual."
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    
    BOOL result = [port disconnect];
    if (result == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail to Disconnect"
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
        return;
    }
    
    [SMPort releasePort:port];
}

@end
