//
//  ProxiPRNTSettingManager.h
//  IOS_SDK
//
//  Created by u3237 on 2014/07/03.
//
//

#import <Foundation/Foundation.h>
#import <StarIO/SMProxiPRNTManager.h>

@class PortInfo;

typedef enum _EditType {
    EditTypeAddNewDevice,
    EditTypeEditExistSetting
} EditType;

typedef enum _LANType {
    LANTypeWired,
    LANTypeWireless
} LANType;

@interface ProxiPRNTSettingManager : NSObject

@property (assign, nonatomic) EditType type;

//BLE Dongle
@property (retain, nonatomic) NSString *peripheralMACAddr;

//Device
@property (retain, nonatomic) NSString *portName;
@property (assign, nonatomic) SMDeviceType deviceType;
@property (assign, nonatomic) BOOL useCashDrawer;
@property (assign, nonatomic) BOOL useAirPort;
@property (assign, nonatomic) NSUInteger portNumber;
@property (assign, nonatomic) LANType lanType;

//setting
@property (retain, nonatomic) NSString *nickName;
@property (assign, nonatomic) NSInteger threshold;

- (void)clear;

+ (ProxiPRNTSettingManager *)sharedManager;
@end
