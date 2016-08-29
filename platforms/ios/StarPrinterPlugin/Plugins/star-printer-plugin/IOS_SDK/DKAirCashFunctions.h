//
//  DKAirCashFunctions.h
//  IOS_SDK
//
//  Created by u3237 on 13/06/25.
//
//

#import <Foundation/Foundation.h>

@interface DKAirCashFunctions : NSObject

#pragma mark Show F/W Information

+ (void)showFirmwareInformation:(NSString *)portName portSettings:(NSString *)portSettings;

#pragma mark Show Dip-SW Information

+ (void)showDipSwitchInformation:(NSString *)portName portSettings:(NSString *)portSettings;

#pragma mark Open Cash Drawer

+ (void)OpenCashDrawerWithPortname:(NSString *)portName
                      portSettings:(NSString *)portSettings
                      drawerNumber:(NSUInteger)drawerNumber;

#pragma mark Check Status

+ (void)CheckStatusWithPortname:(NSString *)portName
                   portSettings:(NSString *)portSettings;

+ (BOOL)waitDrawerOpenAndCloseWithPortName:(NSString *)portName
                              portSettings:(NSString *)portSettings
                              drawerNumber:(NSUInteger)drawerNumber;

#pragma show alert

+ (void)showCommonProgressDialogWithTitle:(NSString *)title message:(NSString *)message;

+ (void)dismissCommonProgressDialog;
@end
