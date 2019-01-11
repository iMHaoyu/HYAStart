//
//  HYAStartCalculate.h
//  HYAStart
//
//  Created by 徐浩宇 on 2019/1/11.
//  Copyright © 2019 徐浩宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

//NS_ASSUME_NONNULL_BEGIN

@interface HYAStartCalculate : NSObject

/** 开始计算所有符合的点 */
+ (void)beginCalculateAllPointsWithSatarPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint mapSize:(CGSize)mapSize pathForResource:(nullable NSString *)name complete:(void(^)(NSArray *resultArray))complete;
@end

//NS_ASSUME_NONNULL_END
