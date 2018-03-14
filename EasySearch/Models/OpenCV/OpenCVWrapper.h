//
//  OpenCVWrapper.h
//  OpenCvTest
//
//  Created by l_yq on 2017/11/27.
//  Copyright © 2017年 linyiqun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UnbelievableKeyPoint.h"
#import "UnbelievableDescriptor.h"


@interface OpenCVWrapper : NSObject

// Interfaces:

// return a image tailered from a set of images
+(UIImage *) tailerImage:(NSArray<UIImage *> *) imageArray;

// resize image to ...(row, col)
+(UIImage *) resizeImage:(UIImage *)image toSize:(int) row andCol:(int)col;

// encode a image to a 64 bit bool array
+(long long) encodeImage:(UIImage *)image;

// compare two image code is the same or not
+(bool) compareImageCode:(bool *)code1 with:(bool *)code2;

// match image with image
+(int) getMatchedPairsFromImage:(UIImage *)image1 toMatchImage:(UIImage *) image2;

// lighting image
+(UIImage *) lightingImage:(UIImage *)image;


// =========================maybe private========================= \\

// return opencv version
+(NSString *) openCVVersionString;

// return a gray scale image of the input
+(UIImage *) makeGrayFromImage:(UIImage *) image;

// return the list of keypoint of a image (need to test)
+(NSArray<UnbelievableKeyPoint *> *) getKeyPointsFrom:(UIImage *) image;

// return the number of matched key points (to do and test)
+(int) match2KeyPointSets:(UnbelievableKeyPoint *) set1 toMatch:(UnbelievableKeyPoint *) set2;

// return the descriptor from a image(without a kps set)
+(UnbelievableDescriptor *) getDescriptorsFromImage:(UIImage *) image;

// return a int: the number of matched desp
+(int) getMatchedPairsFromDesciptor:(UnbelievableDescriptor *)desp toMatch:(UnbelievableDescriptor *)mDesp;

// compare two image is the same or not
+(bool) compareImage:(UIImage *)image with:(UIImage *)image2;

// apply cv::adaptiveThreshold to image
+(UIImage *) adaptiveThreshold:(UIImage *)image;

// match image with desp
+(int) getMatchedPairsFromImage:(UIImage *)image toMatchDescriptor:(UnbelievableDescriptor *)mDesp;

+(UIImage *) defog:(UIImage *)image;

// apply cv::bitwise_not to image
+(UIImage *) bitwiseNot:(UIImage *)image;

+(UIImage *) justATest:(UIImage *) image;



@end
