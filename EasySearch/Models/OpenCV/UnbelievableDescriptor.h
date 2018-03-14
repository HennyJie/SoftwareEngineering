//
//  UnbelievableDescriptor.h
//  EasySearch
//
//  Created by l_yq on 2017/12/23.
//  Copyright © 2017年 l_yq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UnbelievableDescriptor : NSObject<NSCoding>

//@property float **des; ++++++
@property int row;
@property int col;
@property NSArray* des;

@end
