#import "AppView.h"

#define VIEW_H self.frame.size.height
#define VIEW_W self.frame.size.width

@interface AppView ()<CLLocationManagerDelegate, MKMapViewDelegate, OptionViewDelegate>

@property (nonatomic, strong ) MKMapView         *mapView;//显示地图的 View
@property (nonatomic, strong ) CLLocationManager *locationManager;//LM实例
@property (nonatomic, strong ) AppAnnotation     *userAnnotation;//自定义大头针+用户当前位置
@property (nonatomic, strong ) CLGeocoder        *coder;//地理编码
@property (nonatomic, assign ) double            regionDistance;//地图 span, 调节比例尺

@property (nonatomic, strong ) UIButton          *zoomOutButton;//放大按钮
@property (nonatomic, strong ) UIButton          *zoomInButton;//缩小按钮
@property (nonatomic, strong ) UIButton          *positionButton;//定位按钮
@property (nonatomic, strong ) OptionView        *optionView;//档位选择 UIView 实例
@property (nonatomic, strong ) CarDetailView     *carDetailView;//车详情 view 实例

@property (nonatomic, strong ) NSMutableArray    *carArray;//该档位车辆数组
@property (nonatomic, strong ) NSMutableArray    *annoArray;//该档位车辆大头针数组(用于添加和移除)
@property (nonatomic, copy   ) NSString          *locationText;//传递地址给CarDetailView

@end



@implementation AppView

#pragma mark 重写初始化方法, 进行 map 的各种配置
- (instancetype) initWithFrame: (CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        _coder = [CLGeocoder new]; //初始化地理编码
        [self mapView];            //激活懒加载的地图
        [self locationManager];    //激活懒加载的 lm
        [self startPositioning];   //开启定位
        [self positionButton];     //加载定位按钮
        [self zoomOutButton];      //加载放大按钮
        [self zoomInButton];       //加载缩小按钮
        [self optionView];         //加载档位选择View
    }
    return self;
}


//重写 regionDistance 的 getter, 把米单位换算成经纬度单位
- (double) regionDistance {
    return _regionDistance / 111000; //米换成经纬度;
}


#pragma mark 地图懒加载方法
- (MKMapView *) mapView {
    
    if(!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame: CGRectMake(0, 0, VIEW_W, VIEW_H*0.7)];//铺满
        _mapView.rotateEnabled = NO;    //不允许双手转动地图;
        _mapView.delegate      = self;
    }
    
    [self addSubview:_mapView];
    return _mapView;
}


#pragma mark locationManager 懒加载方法
- (CLLocationManager *) locationManager {
    
    if (!_locationManager) {
        
        _locationManager = [CLLocationManager new];
        _locationManager.delegate        = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;             //地图精确度
        _locationManager.distanceFilter  = kCLLocationAccuracyNearestTenMeters; //移动距离过滤设置
    }
    return _locationManager;
}


#pragma mark 定位按钮懒加载
- (UIButton *) positionButton {
    
    if (!_positionButton) {
         _positionButton = [[UIButton alloc] initWithFrame:
                                             CGRectMake(10, VIEW_H*0.7-40, 30, 30)];
        
        [_positionButton setImage:[UIImage imageNamed:@"position"] forState:UIControlStateNormal];
    }
    
    [self.mapView addSubview:_positionButton];
    
    [_positionButton addTarget:self
                        action:@selector(positionToCenter)
              forControlEvents:UIControlEventTouchUpInside];
    
    return _positionButton;
}


#pragma mark 放大缩小按钮懒加载
- (UIButton *) zoomOutButton {
    
    if (!_zoomOutButton) {
         _zoomOutButton = [[UIButton alloc] initWithFrame:
                                            CGRectMake(VIEW_W-40, VIEW_H*0.7-40, 30, 30)];
        
        [_zoomOutButton setImage:[UIImage imageNamed:@"zoomOut"] forState:UIControlStateNormal];
    }
    
    [self.mapView addSubview:_zoomOutButton];
    
    [_zoomOutButton addTarget:self
                       action:@selector(zoomOutRegion)
             forControlEvents:UIControlEventTouchUpInside];
    
    return _zoomOutButton;
}


- (UIButton *) zoomInButton {
    
    if (!_zoomInButton) {
         _zoomInButton = [[UIButton alloc] initWithFrame:
                                           CGRectMake(VIEW_W-40, VIEW_H*0.7-70, 30, 30)];
        
        [_zoomInButton setImage:[UIImage imageNamed:@"zoomIn"] forState:UIControlStateNormal];
    }
    
    [self.mapView addSubview:_zoomInButton];
    
    [_zoomInButton addTarget:self
                      action:@selector(zoomInRegion)
            forControlEvents:UIControlEventTouchUpInside];
    
    return _zoomInButton;
}


#pragma mark 通过 optionView 的代理实现点击 slider 选择档位后,地图大头针同时更新
- (void) transferClickedPosition: (int)position {
    
    switch (position) {
        case 0:
            [self loadHourCarAnnotations];
            break;
        case 1:
            [self loadDayCarAnnotations];
            break;
        default: //只做了前两档(按照老师建议)
            [self loadOtherCarAnnotations];
            break;
    }
}


#pragma mark 实现定位按钮的方法
- (void) positionToCenter {
    [_mapView setCenterCoordinate: _locationManager.location.coordinate animated:YES];
}


#pragma mark 设置放大按钮功能, span 越大, 地图越小, 反之适应缩小的功能.
- (void) zoomOutRegion {
    
    _regionDistance -= 100; //地图视野跨度-100米
    
    if (_regionDistance < 0) {
        _regionDistance = 100;
        return;
    
    } else {
        CLLocationCoordinate2D currentCenter = [_mapView convertPoint:_mapView.center
                                                 toCoordinateFromView:_mapView];
        
        [_mapView setRegion:MKCoordinateRegionMakeWithDistance(currentCenter,
                                                               _regionDistance,
                                                               _regionDistance) animated:YES];
    }
}


- (void) zoomInRegion {
    
    _regionDistance += 100; //地图视野跨度+100米
    
    CLLocationCoordinate2D currentCenter = [_mapView convertPoint:_mapView.center
                                             toCoordinateFromView:_mapView];
    
    [_mapView setRegion: MKCoordinateRegionMakeWithDistance(currentCenter,
                                                            _regionDistance,
                                                            _regionDistance) animated:YES];
}


#pragma mark 开启跟踪定位
- (void) startPositioning {
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus]; //开启授权
    
    if (status == 0) {
        [_locationManager requestAlwaysAuthorization];
    }
    
    _mapView.userTrackingMode  = MKUserTrackingModeFollow; //定位模式:保持跟踪
    _mapView.showsUserLocation = NO;                       //不显示用户位置(不显示蓝色圆圈)
    
    [_locationManager startUpdatingLocation]; //开启追踪
    
    [_mapView setCenterCoordinate:_locationManager.location.coordinate animated:YES];//地图中心设置
    
    _regionDistance = 100.0; //地图视野跨度100米
    
    [_mapView setRegion: MKCoordinateRegionMakeWithDistance(_locationManager.location.coordinate,
                                                            _regionDistance,
                                                            _regionDistance) animated:YES];
}


#pragma mark 代理方法, 位置更新时会调用, 地图开启定位时也会调用
- (void) locationManager:(CLLocationManager *)manager
      didUpdateLocations:(NSArray<CLLocation *> *)locations{
    
    _userAnnotation            = [AppAnnotation new];               //初始化用户位置大头针
    _userAnnotation.coordinate = [locations lastObject].coordinate; //获取当前经纬度
    _userAnnotation.title      = @"You are here";                   //设置用户位置大头针 title
    _userAnnotation.icon       = @"currentPosition";                //设置用户位置大头针自定义图标
    [_mapView addAnnotation:_userAnnotation];                       //添加用户位置大头针到 mapView
}



#pragma mark 车种选择 sliderView 懒加载
- (OptionView *) optionView {
    
    if (!_optionView) {
        _optionView = [OptionView initWithFrame:CGRectMake(0, VIEW_H*0.7, VIEW_W, VIEW_H*0.3)];
    }
    
    [self addSubview:_optionView];
    
    _optionView.delegate = self;
    
    [self loadOtherCarAnnotations];
    
    [_optionView.optionSlider addTarget:self
                                 action:@selector(sliderValueChanged)
                       forControlEvents:UIControlEventTouchUpInside];
    
    return _optionView;
}


#pragma mark 显示所选档位对应的车的自定义大头针
- (void) sliderValueChanged {
    
    //把 slider 的值归整, 四舍五入
    int transferredSliderValue = _optionView.optionSlider.value * 10;
    int sliderValue            = transferredSliderValue % 10;
    int finalChoice            = _optionView.optionSlider.value;
    if (sliderValue < 5) {
        finalChoice = finalChoice;
    } else {
        finalChoice += 1;
    }
    
    //调用相应的方法, 显示相应档位的车大头针(月租和试驾按老师要求未实现,因为原理一样)
    switch (finalChoice)
    {
        case 0:
            [self loadHourCarAnnotations];
            break;
        case 1:
            [self loadDayCarAnnotations];
            break;
        default:
            [self loadOtherCarAnnotations];
            break;
    }
}


#pragma mark 载入时租车辆的信息和大头针们
/*  逻辑:
    1. 获取该档位的 plist
    2. 判断_carArray(用来存储本档位的车辆信息的数组)是否余有数据, 清除干净
    3. 判断_annoArray(用来存储本档位的大头针的数组)是否余有数据, 删除所有非本档位的大头针
    4. 遍历本档位的 plist 内容,挨个添加 annotation,并分类添加到_carArray 和_annoArray
 */
- (void) loadHourCarAnnotations {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"hourCar.plist" ofType:nil];
    
    if (!_carArray) {
        _carArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
        
    }else{
        [_carArray removeAllObjects];
        _carArray  = [NSMutableArray arrayWithContentsOfFile:path];
    }
    
    
    if (!_annoArray) {
        _annoArray = [NSMutableArray array];
    
    } else {
        [_mapView removeAnnotations:_annoArray];
        [_annoArray removeAllObjects];
    }
    
    
    for (NSDictionary *dict in _carArray) {

        AppAnnotation *anno    = [AppAnnotation new];
        anno.title             = dict[@"name"];
        
        //subtitle 的编号是用来反向找出该大头针所在其数组的 index
        anno.subtitle          = [NSString stringWithFormat:@"编号%lu",
                                 (unsigned long)[_carArray indexOfObject:dict]];
        
        anno.icon              = @"hourCar";
        
        anno.coordinate = [self generateRandomCoordinate2D];
        
        [_annoArray addObject:anno]; //添加到这个档位的数组, 方便批量显示 or 删除
        
        [self.mapView addAnnotation:anno];
    }
    
}


- (void) loadDayCarAnnotations {
    
    NSString *path = [[NSBundle mainBundle] pathForResource : @"dayCar.plist" ofType: nil];
    
    if (!_carArray) {
        _carArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
        
    }else{
        [_carArray removeAllObjects];
        _carArray  = [NSMutableArray arrayWithContentsOfFile:path];
    }
    
    
    if (!_annoArray) {
        _annoArray = [NSMutableArray array];
        
    } else {
        [_mapView removeAnnotations:_annoArray];
        [_annoArray removeAllObjects];
    }
    
    for (NSDictionary *dict in _carArray) {
        
        AppAnnotation *anno   = [AppAnnotation new];
        anno.title            = dict[@"name"];
        anno.subtitle         = [NSString stringWithFormat: @"编号%lu",
                                (unsigned long)[_carArray indexOfObject: dict]];
        anno.icon             = @"dayCar";

        anno.coordinate = [self generateRandomCoordinate2D]; //获取随机坐标
        
        [_annoArray addObject:anno];
        
        [self.mapView addAnnotation:anno];
    }
}


//当选到后两个档位时, 清除地图上的车大头针
- (void) loadOtherCarAnnotations {
    
    NSString *path = @"";

    if (!_carArray) {
        _carArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
        
    }else{
        [_carArray removeAllObjects];
        _carArray  = [NSMutableArray arrayWithContentsOfFile:path];
    }
    
    
    if (!_annoArray) {
        _annoArray = [NSMutableArray array];
        
    } else {
        [_mapView removeAnnotations:_annoArray];
        [_annoArray removeAllObjects];
    }
}


//生成用户当前位置周边的随机坐标
- (CLLocationCoordinate2D)generateRandomCoordinate2D {

    float randomNumber1 = 0.0;
    float randomNumber2 = 0.0;
    
    do {
        randomNumber1 =  (arc4random()%10 - 5.0)/3000; //取出一定小范围的正负随机数
        randomNumber2 =  (arc4random()%10 - 5.0)/3000;
        
    } while(randomNumber1 == 0.0 && randomNumber2 == 0.0); //不能和用户当前位置重合
    
    
    float annoLatitude = _userAnnotation.coordinate.latitude + randomNumber1;
    float annoLongitude = _userAnnotation.coordinate.longitude + randomNumber2;
    
    return CLLocationCoordinate2DMake(annoLatitude, annoLongitude);
}


#pragma mark 自定义大头针显示图标的方法
- (MKAnnotationView *) mapView: (MKMapView *)mapView
             viewForAnnotation: (id<MKAnnotation>)annotation {
    
    static NSString *annoID    = @"anno"; //复用 ID
    
    MKAnnotationView *annoView = [mapView dequeueReusableAnnotationViewWithIdentifier:annoID];
    
    if (annoView == nil) {
        annoView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annoID];
        annoView.canShowCallout = YES;
    }
    
    annoView.annotation = annotation;
    AppAnnotation *anno = annotation;
    annoView.image      = [UIImage imageNamed:anno.icon];
    
    return annoView;
}


#pragma mark 点击选中某个大头针时触发
/*  逻辑:
    1. 去除 subview: slider, 不让它显示
    2. 利用 annotation 的 subtitle 的编号取出其的其他信息, 赋值给详情 class
    3. 添加 sunview: 详情 view, 使其显示
 */
- (void) mapView: (MKMapView *)mapView didSelectAnnotationView: (MKAnnotationView *)view {
    
    if (view.annotation.subtitle) { //如果 subtitle 有内容再继续执行, 避免点击用户的位置也弹出车详情 view
        
        [_optionView removeFromSuperview];
        
        NSInteger index = [view.annotation.subtitle substringFromIndex:2].integerValue;//获得 index
        
        if (!_carDetailView) {
            
            _carDetailView = [CarDetailView initWithFrame:
                              CGRectMake(0, VIEW_H*0.7, VIEW_W, VIEW_H*0.3)];
            
            self.delegate = (id<AppViewDelegate>)_carDetailView; //为 self 指定代理
        }
        
#pragma mark 计算距离
        AppAnnotation *anno = view.annotation;
        CLLocation *annoLocation    = [[CLLocation alloc]
                                        initWithLatitude: anno.coordinate.latitude
                                               longitude: anno.coordinate.longitude];

        CLLocation *userLocation    = [[CLLocation alloc]
                                        initWithLatitude: _userAnnotation.coordinate.latitude
                                               longitude: _userAnnotation.coordinate.longitude];

        double distanceText         = [userLocation distanceFromLocation: annoLocation];
        _carDetailView.distanceText = [NSString stringWithFormat: @"距离%.f米", distanceText];
        
        //其他需要展示的详情信息使用 KVC 一次输入
        _carDetailView.annotationCarModel = [carModel carInitWithDict:_carArray[index]];
        
#pragma mark 反地理编码地点, 通过代理传给 CarDetailView
        [_coder reverseGeocodeLocation: annoLocation
                     completionHandler: ^(NSArray<CLPlacemark *> * _Nullable placemarks,
                                          NSError * _Nullable error)
                     {
                         if (error == nil) {
                             _locationText = placemarks[0].name;
                             
                         }else{
                             _locationText = @"获取地址失败";
                         }
                         
                         if (self.delegate && [self.delegate respondsToSelector:@selector(transferLocationText:)]) {
                             [self.delegate transferLocationText:_locationText];
                         }
                         
                     }];
        
        [self addSubview:_carDetailView];
    }
}


#pragma mark 取消选中大头针时触发
- (void) mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    [_carDetailView removeFromSuperview];
    
    [self addSubview:_optionView];
}

@end
