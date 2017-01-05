#import "CarDetailView.h"
#import "AppView.h"

@interface CarDetailView ()<AppViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *carPhotoView;  //显示照片
@property (weak, nonatomic) IBOutlet UILabel     *carName;       //显示车的名字
@property (weak, nonatomic) IBOutlet UILabel     *carPrice;      //显示车的租金
@property (weak, nonatomic) IBOutlet UILabel     *carDistance;   //显示车的距离
@property (weak, nonatomic) IBOutlet UILabel     *carLocation;   //显示车的地点
@property (weak, nonatomic) IBOutlet UILabel     *carRequirement;//显示车的限制
@property (weak, nonatomic) IBOutlet UILabel     *carRate;       //显示车的接单率

@end


@implementation CarDetailView

//车辆大头针被点击时调用, 无论时租还是日租
+ (instancetype) initWithFrame: (CGRect) frame {
    
    CarDetailView *view = [[[NSBundle mainBundle] loadNibNamed:@"CarDetailView"
                                                         owner:nil options:nil] lastObject];
    view.frame = frame;
    
    return view;
}


//KVC 接收赋值(用于接收 annotation 的其他详细信息)
- (void)setAnnotationCarModel: (carModel *)annotationCarModel {
    
    _annotationCarModel  = annotationCarModel;
    
    //开始赋值
    _carPhotoView.image  = [UIImage imageNamed:_annotationCarModel.photo];
    _carName.text        = _annotationCarModel.name;
    _carPrice.text       = _annotationCarModel.price;
    _carDistance.text    = _distanceText;
    _carRequirement.text = _annotationCarModel.requirement;
    _carRate.text        = [NSString stringWithFormat:@"%.f%@",
                                     _annotationCarModel.rate.floatValue*100, @"%接单率"];
}


//代理方法收值
- (void) transferLocationText: (NSString *)locationText {
    
    _carLocation.text = [locationText substringFromIndex:8];
}

@end
