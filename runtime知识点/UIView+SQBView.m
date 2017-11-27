





//
//  UIView+SQBView.m
//  runtime知识点
//
//  Created by songqingbo on 2017/11/23.
//  Copyright © 2017年 song. All rights reserved.
//

#import "UIView+SQBView.h"
#import <objc/runtime.h>

static char SQBTap;// 设置的key
@implementation UIView (SQBView)

- (void)setTapActionWithBlock:(void (^)(void))block{
    /*
    关联对象 关联对象可以是通过给定的key关联到类的实例上
    同时也要指定一个内存管理策略
     */
//    获取关联对象 
    UITapGestureRecognizer *tap = objc_getAssociatedObject(self, &SQBTap);
    if(!tap){
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionForTap:)];
        [self addGestureRecognizer:tap];
        /*
         设置关联对象 
         object 关联
         key  设置的key  注:key要用这种写法static char SQBTap
         value 关联的对象
         objc_AssociationPolicy 内存策略
         OBJC_ASSOCIATION_ASSIGN = 0, //弱引用，对象销毁不会造成关联对象的引用计数变化
         OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1, //强引用，不支持多线程安全
         OBJC_ASSOCIATION_COPY_NONATOMIC = 3, //深拷贝，不支持多线程安全
         OBJC_ASSOCIATION_RETAIN = 01401, //强引用支持线程安全
         OBJC_ASSOCIATION_COPY = 01403  //深拷贝，支持线程安全
         注: ，如果我们使用同一个key来关联另外一个对象时，也会自动释放之前关联的对象，这种情况下，先前的关联对象会被妥善地处理掉，并且新的对象会使用它的内存。
         我们可以使用objc_removeAssociatedObjects函数来移除一个关联对象，或者使用objc_setAssociatedObject函数将key指定的关联对象设置为nil。
        // void objc_setAssociatedObject ( id object, const void *key, id value, objc_AssociationPolicy policy );
         */
        //设置关联对象
        objc_setAssociatedObject(self, &SQBTap, tap,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    //设置的关联对象与block相关联
    objc_setAssociatedObject(self, &SQBTap, block, OBJC_ASSOCIATION_COPY);
    
}

- (void)actionForTap:(UITapGestureRecognizer *)tap{
    if (tap.state == UIGestureRecognizerStateRecognized) {
        void(^action)(void) = objc_getAssociatedObject(self, &SQBTap);
        if (action) {
            action();
        }
    }
}

@end
