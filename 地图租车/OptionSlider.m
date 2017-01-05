#import "OptionSlider.h"


@implementation OptionSlider

#pragma mark 配置 slider控件
- (void) configSlider {
    
    [self setThumbImage:[UIImage imageNamed:@"thumbIcon"]         //设置浮标图案
               forState:UIControlStateNormal];                      
    
    [self setThumbImage:[UIImage imageNamed:@"thumbHighlighted"]
               forState:UIControlStateHighlighted];
}

@end
