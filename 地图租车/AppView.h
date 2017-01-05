#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AppAnnotation.h"
#import "OptionView.h"
#import "carModel.h"
#import "CarDetailView.h"


//设置代理, 通过代理传递反编码出来的真实地址给 CarDetailView
@protocol AppViewDelegate <NSObject>

@optional
-(void)transferLocationText:(NSString *)locationText;

@end



@interface AppView : UIView

@property (nonatomic, weak) id <AppViewDelegate> delegate;

-(instancetype)initWithFrame:(CGRect)frame;

@end
