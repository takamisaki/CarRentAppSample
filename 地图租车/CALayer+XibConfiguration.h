#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

//本 category 实现了可以在 xib 直接设置 view 的 borderColor
//方法是重写 borderColor 的 setter 和 getter 实现了 UIColor 和 CGColor 的转换
@interface CALayer (XibConfiguration)
@property(nonatomic, assign) UIColor* borderUIColor;
@end
