//
//  BrotherPrinterPlugin.h
//  BrotherPrinterPlugin
//
//  Created by Ye Star on 4/9/16.
//
//

#import <Cordova/CDVPlugin.h>


@interface StarPrinterPlugin : CDVPlugin
    - (void)setting:(CDVInvokedUrlCommand*)command;
    - (void)print:(CDVInvokedUrlCommand*)command;
    - (void)cancelPrint:(CDVInvokedUrlCommand*)command;
@end
