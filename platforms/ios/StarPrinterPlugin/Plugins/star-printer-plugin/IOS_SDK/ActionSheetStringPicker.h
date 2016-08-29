
#import "AbstractActionSheetPicker.h"

@class ActionSheetStringPicker;

typedef void(^ActionStringDoneBlock)(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue);
typedef void(^ActionStringCancelBlock)(ActionSheetStringPicker *picker);

@interface ActionSheetStringPicker : AbstractActionSheetPicker <UIPickerViewDelegate, UIPickerViewDataSource>

+ (id)showPickerWithTitle:(NSString *)title
                     rows:(NSArray *)strings
         initialSelection:(NSInteger)index
                doneBlock:(ActionStringDoneBlock)doneBlock
              cancelBlock:(ActionStringCancelBlock)cancelBlock
                   origin:(id)origin;

- (id)initWithTitle:(NSString *)title
               rows:(NSArray *)strings
   initialSelection:(NSInteger)index
          doneBlock:(ActionStringDoneBlock)doneBlock
        cancelBlock:(ActionStringCancelBlock)cancelBlock
             origin:(id)origin;

@property (nonatomic, retain) NSArray *strings;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, copy) ActionStringDoneBlock doneBlock;
@property (nonatomic, copy) ActionStringCancelBlock cancelBlock;

@end
