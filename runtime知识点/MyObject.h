//
//  MyObject.h
//  runtime知识点
//
//  Created by songqingbo on 2017/11/22.
//  Copyright © 2017年 song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyObject : NSObject
@property(strong,nonatomic) NSString *string;
@property(strong,nonatomic) NSArray  *array;

- (void)method1;
- (void)method2;
- (void)classMethod1;
@end
