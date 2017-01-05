#import "ViewController.h"
#import "AppView.h"


//  本案例需要不需要设置模拟器坐标, 会自动生成周围车辆
//  强烈推荐测试模拟器/手机设置为中文, 这样显示地址的效果最好

@interface ViewController ()

@property (nonatomic, strong) AppView *appView; //显示全部内容的 View

@end



@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self appView];

}


-(AppView *)appView{
    
    if (!_appView) {
        
        _appView = [[AppView alloc] initWithFrame: self.view.frame];

        [self.view addSubview:_appView];
    }
    return _appView;
}

@end
