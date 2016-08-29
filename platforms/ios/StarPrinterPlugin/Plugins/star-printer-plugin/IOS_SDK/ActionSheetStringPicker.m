#import "ActionSheetStringPicker.h"

@implementation ActionSheetStringPicker

@synthesize strings     = _strings;
@synthesize index       = _index;
@synthesize doneBlock   = _doneBlock;
@synthesize cancelBlock = _cancelBlock;

+ (id)showPickerWithTitle:(NSString *)title rows:(NSArray *)strings initialSelection:(NSInteger)index doneBlock:(ActionStringDoneBlock)doneBlock cancelBlock:(ActionStringCancelBlock)cancelBlockOrNil origin:(id)origin
{
    ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:title rows:strings initialSelection:index doneBlock:doneBlock cancelBlock:cancelBlockOrNil origin:origin];

    [picker showSubViewPicker];

    return [picker autorelease];
}

- (id)initWithTitle:(NSString *)title rows:(NSArray *)strings initialSelection:(NSInteger)index doneBlock:(ActionStringDoneBlock)doneBlock cancelBlock:(ActionStringCancelBlock)cancelBlock origin:(id)origin
{
    self = [self initWithTarget:origin];

    if (self) {
        self.title   = title;
        self.strings = strings;
        self.index   = index;

        self.doneBlock   = doneBlock;
        self.cancelBlock = cancelBlock;
    }

    return self;
}

- (void)dealloc {
    self.strings = nil;
    
    Block_release(_doneBlock);
    Block_release(_cancelBlock);

    [super dealloc];
}

- (UIView *)configuredPickerView {
    if (!self.strings) {
        return nil;
    }

    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    CGFloat stringPickerWidth = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        stringPickerWidth = screenSize.width;
    } else {
        stringPickerWidth = 320;
    }
    
    const int PICKER_HEIGHT = 216;
    UIPickerView *stringPicker = [[[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, stringPickerWidth, PICKER_HEIGHT)] autorelease];

    stringPicker.delegate                = self;
    stringPicker.dataSource              = self;
    stringPicker.showsSelectionIndicator = YES;

    [stringPicker selectRow:self.index inComponent:0 animated:NO];

    return self.pickerView = stringPicker;
}

- (void)notifyDoneTarget {
    if (self.doneBlock) {
        _doneBlock(self, self.index, self.strings[self.index]);
    }
}

- (void)notifyCancelTarget {
    if (self.cancelBlock) {
        _cancelBlock(self);
    }
}

// UIPickerViewDataSource(@required)

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.strings.count;
}

// UIPickerViewDelegate(@optional)

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.strings[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.index = row;
}

// Setters

- (void)setOnActionSheetDone:(ActionStringDoneBlock)doneBlock {
    if (_doneBlock) {
        Block_release(_doneBlock);
    }

    _doneBlock = Block_copy(doneBlock);
}

- (void)setOnActionSheetCancel:(ActionStringCancelBlock)cancelBlock {
    if (_cancelBlock) {
        Block_release(_cancelBlock);
    }

    _cancelBlock = Block_copy(cancelBlock);
}

@end
