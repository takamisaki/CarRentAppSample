#import <UIKit/UIKit.h>
#import "carModel.h"


@interface CarDetailView : UIView

@property (nonatomic, strong) carModel *annotationCarModel; //用于接收 annotation 其他详细信息的模型实例
@property (nonatomic, copy  ) NSString *distanceText;       //接收距离值

+ (instancetype) initWithFrame: (CGRect)frame;

@end
