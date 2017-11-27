//
//  UIView+SQBView.h
//  runtime知识点
//
//  Created by songqingbo on 2017/11/23.
//  Copyright © 2017年 song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SQBView)
- (void)setTapActionWithBlock:(void (^)(void))block;
@end
