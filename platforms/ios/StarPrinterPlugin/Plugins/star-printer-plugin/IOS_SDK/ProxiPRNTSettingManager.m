//
//  ProxiPRNTSettingManager.m
//  IOS_SDK
//
//  Created by u3237 on 2014/07/03.
//
//

#import "ProxiPRNTSettingManager.h"

static ProxiPRNTSettingManager *sharedManager = nil;

@implementation ProxiPRNTSettingManager

+ (ProxiPRNTSettingManager *)sharedManager
{
    @synchronized(self) {
        if (sharedManager == nil) {
            sharedManager = [[self alloc] init];
        }
    }
    
    return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedManager == nil) {
            sharedManager = [super allocWithZone:zone];
            return sharedManager;
        }
    }
    return nil;
}

- (void)dealloc
{
    [_portName release];
    [_peripheralMACAddr release];
    
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return UINT_MAX;
}

- (oneway void)release
{
    // nothing to do
}

- (id)autorelease
{
    return self;
}

#pragma mark -

- (void)clear
{
    self.type = EditTypeAddNewDevice;
    self.peripheralMACAddr = nil;
    self.portName = nil;
    self.deviceType = SMDeviceTypeUnknown;
    self.useCashDrawer = NO;
    self.useAirPort = NO;
    self.portNumber = 0;
    self.lanType = LANTypeWired;
    self.nickName = nil;
    self.threshold = 0;
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString string];
    
    [description appendString:@"\n"];
    [description appendString:[NSString stringWithFormat:@"  type = %@\n", (self.type == EditTypeAddNewDevice) ? @"EditTypeAddNewDevice" : @"EditTypeEditExistSetting"]];
    [description appendString:[NSString stringWithFormat:@"  PeripheralMACAddr = %@\n", self.peripheralMACAddr]];
    [description appendString:[NSString stringWithFormat:@"  portName = %@\n", self.portName]];
    [description appendString:@"  deviceType = "];
    switch (self.deviceType) {
        case SMDeviceTypeUnknown:
            [description appendString:@"SMDeviceTypeUnknown"];
            break;
        case SMDeviceTypeDesktopPrinter:
            [description appendString:@"SMDeviceTypeDesktopPrinter"];
            break;
        case SMDeviceTypeDKAirCash:
            [description appendString:@"SMDeviceTypeDKAirCash"];
            break;
        case SMDeviceTypePortablePrinter:
            [description appendString:@"SMDeviceTypePortablePrinter"];
            break;
    }
    [description appendString:@"\n"];

    [description appendString:[NSString stringWithFormat:@"  useCashDrawer = %@\n", (self.useCashDrawer) ? @"YES" : @"NO"]];
    [description appendString:[NSString stringWithFormat:@"  useAirPort = %@\n", (self.useAirPort) ? @"YES" : @"NO"]];
    [description appendString:[NSString stringWithFormat:@"  portNumber = %lu\n", (unsigned long)self.portNumber]];
    [description appendString:[NSString stringWithFormat:@"  lanType = %@\n", (self.lanType == LANTypeWired) ? @"lanTypeWired" : @"lanTypeWireless"]];

    [description appendString:[NSString stringWithFormat:@"  nickName = %@\n", self.nickName]];
    [description appendString:[NSString stringWithFormat:@"  threshold = %ld\n", (long)self.threshold]];

    return description;
}

@end
