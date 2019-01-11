//
//  HYAStartCalculate.m
//  HYAStart
//
//  Created by 徐浩宇 on 2019/1/11.
//  Copyright © 2019 徐浩宇. All rights reserved.
//

#import "HYAStartCalculate.h"
#import <UIKit/UIGeometry.h>

/** 可用点 */
#define kCZR_MAP_EMPTY   0
/** 障碍点 */
#define kCZR_MAP_BLOCK   1
/** 起点 */
#define kCZR_MAP_START   2
/** 终点 */
#define kCZR_MAP_END     3

/** 点的结构体 */
struct CZRPoint {
    NSInteger x;  //坐标 X
    NSInteger y;  //坐标 Y
    NSInteger g;  //实际代价(距离上一格的距离)
    NSInteger f;  //总估价(距离终点的距离)
};


@interface HYAStartCalculate () {
    //在循环中当前计算的点
    struct CZRPoint currentPoint;
    //起点
    struct CZRPoint startPoint;
    //终点
    struct CZRPoint endPoint;
}

/** 地图的实际宽度 */
@property (nonatomic, assign) NSInteger mapWidth;
/** 地图的实际长度s */
@property (nonatomic, assign) NSInteger mapHeight;
/** 定义地图上所有大点 */
@property (nonatomic, copy) NSMutableArray *mapArray;
/** 数组中该点到终点的距离 */
@property (nonatomic, copy) NSMutableArray *gArray;
/** 当前有效的点 */
@property (nonatomic, copy) NSMutableArray *listPoints;

@end
@implementation HYAStartCalculate

+ (void)beginCalculateAllPointsWithSatarPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint mapSize:(CGSize)mapSize pathForResource:(nullable NSString *)name complete:(void (^)(NSArray * _Nonnull))complete {
    
    HYAStartCalculate *aStarCalculate = [[HYAStartCalculate alloc]init];
    
    aStarCalculate.mapWidth = mapSize.width;
    aStarCalculate.mapHeight = mapSize.height;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //生成地图
        NSArray *resultArray = [aStarCalculate generateMapStartPoint:startPoint endPoint:endPoint pathForResource:name];
        dispatch_async(dispatch_get_main_queue(), ^{
            //所有完成完成
            if (resultArray) {
                NSLog(@"路径点个数%ld",(long)resultArray.count);
                if (complete) {
                    complete(resultArray);
                }
            }
            
        });
    });
}
/** 生成地图 */
- (NSArray *)generateMapStartPoint:(CGPoint)startP endPoint:(CGPoint)endP pathForResource:(nullable NSString *)name {
    NSLog(@"地图坐标初始化开始");
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSData *mapData = [NSData dataWithContentsOfFile:path];
    NSArray *pointArray = [NSJSONSerialization JSONObjectWithData:mapData options:kNilOptions error:nil];
    
    startPoint.x = startP.x;
    startPoint.y = startP.y;
    endPoint.x   = endP.x;
    endPoint.y   = endP.y;
    
    //设置地图上所有的点都为障碍点
    for (int x = 0; x < _mapWidth; x++) {
        NSMutableArray *tempMapArray = [NSMutableArray array];
        NSMutableArray *tempGArray = [NSMutableArray array];
        for (int y = 0; y < _mapHeight; y++) {
            [tempMapArray addObject:@(kCZR_MAP_BLOCK)];
            [tempGArray addObject:@(-1)];
        }
        [self.mapArray addObject:tempMapArray];
        [self.gArray addObject:tempGArray];
    }
    
    //把地图上的起点、终点、空点(有效的的点)给添加进去
    for (NSDictionary *tempDic in pointArray) {
        NSInteger x = [tempDic[@"x"] integerValue];
        NSInteger y = [tempDic[@"y"] integerValue];
        
        if(startPoint.x == x && startPoint.y == y) {
            self.mapArray[x][y] = @(kCZR_MAP_START);
        }else if(endPoint.x == x && endPoint.y == y) {
            self.mapArray[x][y] = @(kCZR_MAP_END);
        }else {
            self.mapArray[x][y] = @(kCZR_MAP_EMPTY);
        }
    }
    NSLog(@"地图坐标初始化完成");
    return [self calculateBestPath];
}

/** 计算最佳路径 */
- (NSArray *)calculateBestPath {
    NSLog(@"开始计算");
    currentPoint.x = startPoint.x;
    currentPoint.y = startPoint.y;
    currentPoint.g = 0;
    currentPoint.f = 0;
    
    self.gArray[currentPoint.x][currentPoint.y] = @(0);
    
    while (currentPoint.x != endPoint.x ||  currentPoint.y != endPoint.y ) {
        if(currentPoint.g <= [self.gArray[currentPoint.x][currentPoint.y] integerValue]) {
            struct CZRPoint voisin;
            //这里进行设置是否允许斜对角进行取点 YES:只能平移（上下移动），NO:上下移动，斜对角移动
            if (/* DISABLES CODE */ (NO)) {
                
                for(int i = -1; i < 2; i++) {// 移动 x
                    for(int j = -1; j < 2; j++) {// 移动 y
                        // 判断是不是在同一点(i=0,j=0 表示没有移动所以就是在同一个点上)
                        if(i != 0 || j != 0) {
                            voisin.x = currentPoint.x+i;
                            voisin.y = currentPoint.y+j;
                            // 判断是否是在地图边缘，是否是障碍
                            if(voisin.x >= 0 && voisin.x < self.mapWidth   &&
                               voisin.y >= 0 && voisin.y < self.mapHeight  &&
                               [self.mapArray[voisin.x][voisin.y] integerValue] != kCZR_MAP_BLOCK) {
                                
                                voisin.f = currentPoint.g + 1 + Manhattan(voisin, endPoint);
                                
                                if ([self.gArray[voisin.x][voisin.y] integerValue] == -1 ||
                                    [self.gArray[voisin.x][voisin.y] integerValue] > (currentPoint.g + 1)) {
                                    
                                    self.gArray[voisin.x][voisin.y] = @(currentPoint.g + 1);
                                    voisin.g = currentPoint.g + 1;
                                    NSLog(@"%@",NSStringFromCGPoint(CGPointMake(voisin.x, voisin.y)));
                                    
                                    [self.listPoints addObject:[NSValue value:&voisin withObjCType:@encode(struct CZRPoint)]];
                                }
                            }
                        }
                    }
                }
            }else {
                for(int i = -1; i < 2; i++) {// 移动 x
                    for(int j = -1; j < 2; j++) {// 移动 y
                        // 判断是不是在同一点(i=0,j=0 表示没有移动所以就是在同一个点上)
                        if((i !=  0 || j !=  0) &&
                           (i != -1 || j != -1) &&
                           (i != -1 || j !=  1) &&
                           (i !=  1 || j != -1) &&
                           (i !=  1 || j !=  1)) {
                            voisin.x = currentPoint.x+i;
                            voisin.y = currentPoint.y+j;
                            // 判断是否是在地图边缘，是否是障碍
                            if(voisin.x >= 0 && voisin.x < self.mapWidth   &&
                               voisin.y >= 0 && voisin.y < self.mapHeight  &&
                               [self.mapArray[voisin.x][voisin.y] integerValue] != kCZR_MAP_BLOCK) {
                                voisin.f = currentPoint.g + 1 + Manhattan(voisin, endPoint);
                                if ([self.gArray[voisin.x][voisin.y] integerValue] == -1 ||
                                    [self.gArray[voisin.x][voisin.y] integerValue] > (currentPoint.g + 1)
                                    ) {
                                    self.gArray[voisin.x][voisin.y] = @(currentPoint.g + 1);
                                    voisin.g = currentPoint.g + 1;
                                    
                                    [self.listPoints addObject:[NSValue value:&voisin withObjCType:@encode(struct CZRPoint)]];
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if([self.listPoints count] > 0) {
            struct CZRPoint point;
            [[self.listPoints objectAtIndex:0] getValue:&point];
            currentPoint = point;
            for (int index = 0; index < [self.listPoints count]; index++) {
                struct CZRPoint tmpPoint;
                [[self.listPoints objectAtIndex:index] getValue:&tmpPoint];
                
                if(currentPoint.f > tmpPoint.f) {
                    currentPoint = tmpPoint;
                }
            }
            
            [self.listPoints removeObject:[NSValue value:&currentPoint withObjCType:@encode(struct CZRPoint)]];
        } else {
            NSLog(@"没有点 没有点 没有点 没有点 没有点 没有点 没有点 没有点 没有点 没有点！！！！！！");
            return nil;
        }
    }
    NSLog(@"结束计算");
    //所有符合的点
    NSArray *allMatchPoints = [self drawPathOnMap];
    return allMatchPoints;
}

- (NSArray *)drawPathOnMap {
    
    struct CZRPoint current;
    struct CZRPoint voisin;
    BOOL next;
    
    current = endPoint;
    
    NSMutableArray *tempMutArr = [NSMutableArray array];
    for (NSInteger g = [self.gArray[endPoint.x][endPoint.y] integerValue]; g > 0; g--) {
        next = NO;
        // 移动 x
        for(int i = -1; i < 2; i++) {
            //移动 y
            for(int j = -1; j < 2; j++) {
                // 我们不是在同一点上做的。
                if((i != 0 || j != 0) && !next) {
                    voisin.x = current.x+i;
                    voisin.y = current.y+j;
                    voisin.g = [self.gArray[current.x+i][current.y+j] integerValue];
                    if( voisin.g == g-1 ) {
                        CGPoint tempPoint = CGPointMake(voisin.x, voisin.y);
                        [tempMutArr addObject:NSStringFromCGPoint(tempPoint)];
                        //                        NSLog(@"路径点:%@\n",NSStringFromCGPoint(tempPoint));
                        current = voisin;
                        next = YES;
                    }
                }
            }
        }
    }
    //    NSLog(@"路径点个数%ld",(long)tempMutArr.count);
    NSLog(@"起点%@",NSStringFromCGPoint(CGPointMake(startPoint.x, startPoint.y)));
    NSLog(@"终点%@",NSStringFromCGPoint(CGPointMake(endPoint.x, endPoint.y)));
    return [tempMutArr copy];
}

/** 计算曼哈顿距离 */
NSInteger Manhattan(struct CZRPoint voisin, struct CZRPoint end) {
    return (NSInteger)(abs((int)(voisin.x-end.x)) + (int)abs((int)(voisin.y-end.y)));
}
#pragma mark - ⬅️⬅️⬅️⬅️ Getter & Setter ➡️➡️➡️➡️
#pragma mark -
/** 定义地图上所有大点 */
- (NSMutableArray *)mapArray {
    if (!_mapArray) {
        _mapArray = [NSMutableArray array];
    }
    return _mapArray;
}
/** 数组中改点到终点的距离 */
- (NSMutableArray *)gArray {
    if (!_gArray) {
        _gArray = [NSMutableArray array];
    }
    return _gArray;
}
/** 有效的点 */
- (NSMutableArray *)listPoints {
    if (!_listPoints) {
        _listPoints = [NSMutableArray array];
    }
    return _listPoints;
}

@end
