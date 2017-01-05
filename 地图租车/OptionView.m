#import "OptionView.h"

@interface OptionView ()

@property (weak, nonatomic) IBOutlet UILabel *hourCar;
@property (weak, nonatomic) IBOutlet UILabel *dayCar;
@property (weak, nonatomic) IBOutlet UILabel *monCar;
@property (weak, nonatomic) IBOutlet UILabel *traiCar;

@end


@implementation OptionView

+ (instancetype) initWithFrame: (CGRect)frame {
    
    OptionView *view = [[[NSBundle mainBundle] loadNibNamed:@"OptionView" owner:nil options:nil] lastObject];

    view.frame = frame;  //设置大小
    [view optionSlider]; //设置 slider
    [view addPinch];     //设置手势
    
    return view;
}


#pragma mark slider设置
- (OptionSlider *) optionSlider {
    
    [_optionSlider configSlider];
    
    //设定初始对应档位的颜色
    [self sliderTouched];
    
    //滑动完成后触发的事件
    [_optionSlider addTarget:self
                      action:@selector(sliderTouched)
            forControlEvents:UIControlEventTouchUpInside];

    return _optionSlider;
}


#pragma mark slider thumb 变化位置时, 确认最终的选择
- (void) sliderTouched {
    
    //四舍五入取整
    int transferredSliderValue = _optionSlider.value * 10;
    int sliderValue            = transferredSliderValue % 10;
    int finalChoice            = _optionSlider.value;
    
    if (sliderValue < 5) {
        finalChoice = finalChoice;
    
    } else {
        finalChoice += 1;
    }
    
    [_optionSlider setValue: (float)finalChoice animated:YES];
    
    //设置滑块位置的文字亮
    switch ((int)_optionSlider.value) {
            
        case 0:
            //时租文字亮
            _hourCar.textColor = [UIColor redColor];
            _dayCar .textColor = [UIColor blackColor];
            _monCar .textColor = [UIColor blackColor];
            _traiCar.textColor = [UIColor blackColor];
            break;
        case 1:
            //日租文字亮
            _dayCar .textColor = [UIColor redColor];
            _hourCar.textColor = [UIColor blackColor];
            _monCar .textColor = [UIColor blackColor];
            _traiCar.textColor = [UIColor blackColor];
            break;
        case 2:
            //月租文字亮
            _monCar .textColor = [UIColor redColor];
            _hourCar.textColor = [UIColor blackColor];
            _dayCar .textColor = [UIColor blackColor];
            _traiCar.textColor = [UIColor blackColor];
            break;
        case 3:
            //xx 文字亮
            _traiCar.textColor = [UIColor redColor];
            _hourCar.textColor = [UIColor blackColor];
            _dayCar .textColor = [UIColor blackColor];
            _monCar .textColor = [UIColor blackColor];
            break;
    }
}


#pragma mark 实现 slider 可点击
/*  逻辑:
    1. 添加 tap 手势
    2. 设置tap 手势的响应方法, 通过点击的位置, 计算出 slider 应该切换到的值.
 */
- (void) addPinch {
    
    UITapGestureRecognizer *clickSlider = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(sliderClicked:)];
    
    [self.optionSlider addGestureRecognizer:clickSlider];
}

- (void) sliderClicked: (UITapGestureRecognizer*) clickSlider {
    
    CGPoint point = [clickSlider locationInView:self.optionSlider]; //取得点击位置
    
    float sliderWidth  = clickSlider.view.frame.size.width;
    float sliderHeight = clickSlider.view.frame.size.width;
    
    float x = point.x;
    float y = point.y;
    
    if (x <0 || y <0 || x>sliderWidth || y>sliderHeight) { //如果点击位置在 slider 外,忽视
        return;
    
    }else{
        int preResult = (int)(x / (sliderWidth-24)/3 * 10);//根据计算调整点击精度
        if (preResult == _optionSlider.value) {
            return;
        }
        self.optionSlider.value = preResult; //赋值给 slider
        [self sliderTouched];//实时调整上方文字高亮
        
        
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(transferClickedPosition:)])
        {
            [self.delegate transferClickedPosition:preResult];
        }
    }
}



@end
