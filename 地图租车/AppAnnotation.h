#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface AppAnnotation : NSObject<MKAnnotation>

@property (nonatomic        ) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy  ) NSString               *title;
@property (nonatomic, copy  ) NSString               *subtitle; //用来显示编号的
@property (nonatomic, copy  ) NSString               *icon;     //图标

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
