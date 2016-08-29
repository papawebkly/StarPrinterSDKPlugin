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
//  AppDelegate.h
//  StarPrinterPlugin
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import <Cordova/CDVViewController.h>
#import <Cordova/CDVAppDelegate.h>

typedef enum _SMPrinterType {
    SMPrinterTypeUnknown = 0,
    SMPrinterTypeDesktopPrinterStarLine,
    SMPrinterTypePortablePrinterStarLine,
    SMPrinterTypePortablePrinterESCPOS
} SMPrinterType;

typedef enum _SMPaperWidth {
    SMPaperWidth2inch,
    SMPaperWidth3inch,
    SMPaperWidth4inch
} SMPaperWidth;

typedef enum _SMLanguage {
    SMLanguageEnglish,
    SMLanguageEnglishUtf8,
    SMLanguageFrench,
    SMLanguageFrenchUtf8,
    SMLanguagePortuguese,
    SMLanguagePortugueseUtf8,
    SMLanguageSpanish,
    SMLanguageSpanishUtf8,
    SMLanguageRussian,
    SMLanguageRussianUtf8,
    SMLanguageJapanese,
    SMLanguageJapaneseUtf8,
    SMLanguageSimplifiedChinese,
    SMLanguageSimplifiedChineseUtf8,
    SMLanguageTraditionalChinese,
    SMLanguageTraditionalChineseUtf8,
} SMLanguage;

@interface AppDelegate : CDVAppDelegate {}
+ (NSString *)getPortName;
+ (void)setPortName:(NSString *)m_portName;
+ (NSString*)getPortSettings;
+ (void)setPortSettings:(NSString *)m_portSettings;

+ (NSString *)getDrawerPortName;
+ (void)setDrawerPortName:(NSString *)portName;

+ (void)setButtonArrayAsOldStyle:(NSArray *)buttons;

+ (SMPrinterType)parsePortSettings:(NSString *)portSettings;

+ (NSString *)HTMLCSS;
@end
