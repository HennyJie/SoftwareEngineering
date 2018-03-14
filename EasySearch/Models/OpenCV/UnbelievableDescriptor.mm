//
//  UnbelievableDescriptor.m
//  EasySearch
//
//  Created by l_yq on 2017/12/23.
//  Copyright © 2017年 l_yq. All rights reserved.
//

#import "UnbelievableDescriptor.h"

@implementation UnbelievableDescriptor

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt: self.row forKey: @"row"];
    [coder encodeInt: self.col forKey: @"col"];
    
//    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
//
//    for(int i = 0; i < self.col; i++) {
//        for(int j = 0; j < self.row; j++) {
//            [array addObject:[NSNumber numberWithFloat:self.des[i][j]]];
//        }
//    }++++++
    
    [coder encodeObject:self.des forKey:@"des"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.row = [coder decodeIntForKey: @"row"];
        self.col = [coder decodeIntForKey: @"col"];
        
//        self.des = new float*[self.col];++++++
        
        self.des = [coder decodeObjectForKey:@"des"];
        
//        for(int i = 0; i < self.col ; i++) {
//            self.des[i] = new float[self.row];
//            for(int j = 0; j < self.row; j++) {
//                NSNumber *index = [array objectAtIndex: i * self.row + j];
//                self.des[i][j] = [index floatValue];
//            }
//        }++++++
    }
    return self;
}

@end
