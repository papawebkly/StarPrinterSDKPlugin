//
//  DotPrinterFunctions.h
//  IOS_SDK
//
//  Created by u3237 on 8/27/2014.
//  Copyright 2016 STAR MICRONICS CO., LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CommonEnum.h"
#import "AppDelegate.h"

@class SMBluetoothManager;

@interface DotPrinterFunctions : NSObject

#pragma mark Show Firmware Information

+ (void)showFirmwareVersion:(NSString *)portName portSettings:(NSString *)portSettings;

#pragma mark Open Cash Drawer

+ (void)openCashDrawerWithPortname:(NSString *)portName
                      portSettings:(NSString *)portSettings
                      drawerNumber:(NSUInteger)drawerNumber;

#pragma mark Check Status

+ (void)checkStatusWithPortname:(NSString *)portName
                   portSettings:(NSString *)portSettings
                  sensorSetting:(SensorActive)sensorActiveSetting;

#pragma mark Cut

+ (void)performCutWithPortname:(NSString *)portName
                  portSettings:(NSString *)portSettings
                       cutType:(CutType)cuttype;

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
                 textDataSize:(unsigned int)textDataSize;

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
                      textDataSize:(unsigned int)textDataSize;

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
                    textDataSize:(unsigned int)textDataSize;

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
                    textDataSize:(unsigned int)textDataSize;

#pragma mark Sample Receipt (Line)

+ (void)printSampleReceiptWithPortName:(NSString *)portName
                          portSettings:(NSString *)portSettings
                            paperWidth:(SMPaperWidth)paperWidth
                              language:(SMLanguage)language;

#pragma mark Bluetooth Setting

+ (SMBluetoothManager *)loadBluetoothSetting:(NSString *)portName
                                portSettings:(NSString *)portSettings;

#pragma mark Disconnect (Bluetooth)

+ (void)disconnectPort:(NSString *)portName
          portSettings:(NSString *)portSettings
               timeout:(u_int32_t)timeout;

@end