#import <UIKit/UIKit.h>
#import "OptionSlider.h"

@protocol OptionViewDelegate <NSObject>

@required
-(void)transferClickedPosition:(int)position;

@end


@interface OptionView : UIView

@property (nonatomic, weak) id       <OptionViewDelegate>   delegate;
@property (weak, nonatomic) IBOutlet OptionSlider           *optionSlider;

+ (instancetype) initWithFrame: (CGRect)frame;

@end
