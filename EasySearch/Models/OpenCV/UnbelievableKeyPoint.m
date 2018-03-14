//
//  UnbelievableKeyPoint.m
//  EasySearch
//
//  Created by l_yq on 2017/12/20.
//  Copyright © 2017年 l_yq. All rights reserved.
//

#import "UnbelievableKeyPoint.h"

@implementation UnbelievableKeyPoint


- (instancetype)initWithKeyPoint:(float)x
                            andY:(float)y
                         andSize:(float)size
                        andAngle:(float)angle
                     andResponse:(float)response
                       andOctave:(int)octave
                      andClassID:(int)class_id {
    if (self = [super init]) {
        self.x = x;
        self.y = y;
        self.size = size;
        self.angle = angle;
        self.response = response;
        self.octave = octave;
        self.class_id = class_id;
    }
    
    return self;
}



@end
