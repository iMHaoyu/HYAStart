//
//  ViewController.m
//  HYAStart
//
//  Created by 徐浩宇 on 2019/1/11.
//  Copyright © 2019 徐浩宇. All rights reserved.
//

#import "ViewController.h"
#import "HYAStartCalculate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     map_new1 -> W x H:930 × 992 , StartPoint:(187,606)  , EndPoint:(785,379)
     
     map_new2 -> W x H:796 × 981 , StartPoint:(192,703)  , EndPoint:(630,329)
     */
    [HYAStartCalculate beginCalculateAllPointsWithSatarPoint:CGPointMake(187,606) endPoint:CGPointMake(785,379) mapSize:CGSizeMake(930,992) pathForResource:@"map_new1.json" complete:^(NSArray *resultArray) {
        NSLog(@"最终结果:%ld",resultArray.count);
    }];
    
    // Do any additional setup after loading the view, typically from a nib.
}


@end
