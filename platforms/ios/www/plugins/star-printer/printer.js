/**
 * @constructor
 */


var StarPrinterPlugin = function () {
    this.SETTING_PRINTERS_METHOD = 'setting';
    this.PRINT_METHOD = 'print';
    this.CANCEL_PRINT_METHOD = 'cancelPrint';
    this.CLASS = 'StarPrinterPlugin';
};

StarPrinterPlugin.prototype.setting = function(callback, errorc) {
    // make the call
    var successCallback = (callback && typeof(callback) === 'function') ? callback : this.defaultCallback;
    var errorCallback = (errorc && typeof(errorc) === 'function') ? errorc : this.defaultCallback;

    cordova.exec(successCallback, errorCallback, this.CLASS, this.SETTING_PRINTERS_METHOD, []);
};

/*
 NSInteger deviceType = (NSInteger)[arguments objectAtIndex:0];//[1, params, path], 1:WIFI, 0:Bluetooth
 NSDictionary *settings = [arguments objectAtIndex:1];//[1, params, path]
 NSString *pdfPath = [arguments objectAtIndex:2];
 */
StarPrinterPlugin.prototype.print = function(callback, errorc) {

    // make the call
    var successCallback = (callback && typeof(callback) === 'function') ? callback : this.defaultCallback;
    var errorCallback = (errorc && typeof(errorc) === 'function') ? errorc : this.defaultCallback;
    
    cordova.exec(successCallback, errorCallback, this.CLASS, this.PRINT_METHOD, []);
};

StarPrinterPlugin.prototype.cancelPrint = function () {
        cordova.exec(null, null, this.CLASS, this.CANCEL_PRINT_METHOD, []);
};

StarPrinterPlugin.prototype.defaultCallback = null;

// Plug in to Cordova
cordova.addConstructor(function () {
        if (!window.Cordova) {
            window.Cordova = cordova;
        };
                       
        if (!window.plugins) window.plugins = {};
            window.plugins.StarPrinterPlugin = new StarPrinterPlugin();
});