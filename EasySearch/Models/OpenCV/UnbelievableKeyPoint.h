//
//  UnbelievableKeyPoint.h
//  EasySearch
//
//  Created by l_yq on 2017/12/20.
//  Copyright © 2017年 l_yq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnbelievableKeyPoint : NSObject
 @property float x;
 @property float y;
 @property float size;
 @property float angle;
 @property float response;
 @property int octave;
 @property int class_id;

- (instancetype)initWithKeyPoint:(float)x
                            andY:(float)y
                            andSize:(float)size
                            andAngle:(float)angle
                            andResponse:(float)response
                            andOctave:(int)octave
                            andClassID:(int)class_id;

@end
