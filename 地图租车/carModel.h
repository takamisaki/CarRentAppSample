#import <Foundation/Foundation.h>

@interface carModel : NSObject

@property (nonatomic, copy  ) NSString *name;
@property (nonatomic, copy  ) NSString *price;
@property (nonatomic, copy  ) NSString *latitude;
@property (nonatomic, copy  ) NSString *longitude;
@property (nonatomic, copy  ) NSString *photo;
@property (nonatomic, copy  ) NSString *requirement;
@property (nonatomic, assign) NSNumber *rate;


-(instancetype)initWithDict:(NSDictionary*)dict;

+(instancetype)carInitWithDict:(NSDictionary*)dict;

@end
