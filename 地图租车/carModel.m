#import "carModel.h"

@implementation carModel

- (instancetype)initWithDict: (NSDictionary*)dict {
    
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    
    return self;
}


+ (instancetype) carInitWithDict: (NSDictionary*)dict {
    
    return [[carModel alloc] initWithDict:dict];
}

@end
