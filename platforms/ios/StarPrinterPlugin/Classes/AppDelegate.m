/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  AppDelegate.m
//  StarPrinterPlugin
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

static NSString *portName = nil;
static NSString *portSettings = nil;
static NSString *drawerPortName = nil;

@implementation AppDelegate

#pragma mark getter/setter

+ (NSString*)getPortName
{
    return portName;
}

+ (void)setPortName:(NSString *)m_portName
{
    if (portName != m_portName) {
        [portName release];
        portName = [m_portName copy];
    }
}

+ (NSString *)getPortSettings
{
    return portSettings;
}

+ (void)setPortSettings:(NSString *)m_portSettings
{
    if (portSettings != m_portSettings) {
        [portSettings release];
        portSettings = [m_portSettings copy];
    }
}

+ (NSString *)getDrawerPortName {
    return drawerPortName;
}

+ (void)setDrawerPortName:(NSString *)portName {
    if (drawerPortName != portName) {
        [drawerPortName release];
        drawerPortName = [portName copy];
    }
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    self.viewController = [[MainViewController alloc] init];
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

+ (void)setButtonArrayAsOldStyle:(NSArray *)buttons {
    for (id object in buttons) {
        if ([object isKindOfClass:[UIButton class]] == NO) {
            continue;
        }
        
        UIButton *button = (UIButton *)object;
        button.layer.backgroundColor = [[UIColor whiteColor] CGColor];
        button.layer.borderColor = [[UIColor grayColor] CGColor];
        button.layer.borderWidth = 1.0;
        button.layer.cornerRadius = 10.0;
        button.clipsToBounds = YES;
    }
}

+ (SMPrinterType)parsePortSettings:(NSString *)portSettings {
    if (portSettings == nil) {
        return SMPrinterTypeDesktopPrinterStarLine;
    }
    
    NSArray *params = [portSettings componentsSeparatedByString:@";"];
    
    BOOL isESCPOSMode = NO;
    BOOL isPortablePrinter = NO;
    
    for (NSString *param in params) {
        NSString *str = [param stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
        
        if ([str caseInsensitiveCompare:@"mini"] == NSOrderedSame) {
            return SMPrinterTypePortablePrinterESCPOS;
        }
        
        if ([str caseInsensitiveCompare:@"Portable"] == NSOrderedSame) {
            isPortablePrinter = YES;
            continue;
        }
        
        if ([str caseInsensitiveCompare:@"escpos"] == NSOrderedSame) {
            isESCPOSMode = YES;
            continue;
        }
    }
    
    if (isPortablePrinter) {
        if (isESCPOSMode) {
            return SMPrinterTypePortablePrinterESCPOS;
        } else {
            return SMPrinterTypePortablePrinterStarLine;
        }
    }
    
    return SMPrinterTypeDesktopPrinterStarLine;
}

#pragma mark Help

+ (NSString *)HTMLCSS
{
    NSString *cssDefninition = @"<html>\
    <head>\
    <style type=\"text/css\">\
    Code {color:blue;}\n\
    CodeDef {color:blue;font-weight:bold}\n\
    TitleBold {font-weight:bold}\n\
    It1 {font-style:italic; font-size:12}\n\
    LargeTitle{font-size:20px}\n\
    SectionHeader{font-size:17;font-weight:bold}\n\
    UnderlineTitle {text-decoration:underline}\n\
    div_cutParam {position:absolute; top:100; left:30; width:200px;font-style:italic;}\n\
    div_cutParam0 {position:absolute; top:130; left:30; font-style:italic;}\n\
    div_cutParam1 {position:absolute; top:145; left:30; font-style:italic;}\n\
    div_cutParam2 {position:absolute; top:160; left:30; font-style:italic;}\n\
    div_cutParam3 {position:absolute; top:175; left:30; font-style:italic;}\n\
    .div-tableBarcodeWidth{display:table;}\n\
    .div-table-rowBarcodeWidth{display:table-row;}\n\
    .div-table-colBarcodeWidthHeader{display:table-cell;border:1px solid #000000;background: #800000;color:#ffffff}\n\
    .div-table-colBarcodeWidthHeader2{display:table-cell;border:1px solid #000000;background: #800000;color:#ffffff}\n\
    .div-table-colBarcodeWidth{display:table-cell;border:1px solid #000000;}\n\
    rightMov {position:absolute; left:30px; font-style:italic;}\n\
    rightMov_NOI {position:absolute; left:55px;}\n\
    rightMov_NOI2 {position:absolute; left:90px;}\n\
    StandardItalic {font-style:italic}\
    .div-tableCut{display:table;}\n\
    .div-table-rowCut{display:table-row;}\n\
    .div-table-colFirstCut{display:table-cell;width:40px}\n\
    .div-table-colCut{display:table-cell;}\n\
    .div-table-colRaster{display:table-cell; border:1px solid #000000;}\n\
    </style>\
    </head>";
    
    return cssDefninition;
}

@end
