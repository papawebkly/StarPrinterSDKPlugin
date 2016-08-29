//
//  SMCSAllReceipts.h
//  SMCloudServices
//
//  Created by Yuji on 2015/**/**.
//  Copyright (c) 2015年 Star Micronics. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMCSAllReceipts : NSObject

+ (NSString *)uploadBitmap:(UIImage *)image completion:(void (^)(NSInteger statusCode, NSError *error))completion;

+ (void)updateStatus:(NSString *)status completion:(void (^)(NSInteger statusCode, NSError *error))completion;

+ (NSData *)generateAllReceipts:(NSString *)urlString emulation:(StarIoExtEmulation)emulation info:(BOOL)info qrCode:(BOOL)qrCode;

@end
