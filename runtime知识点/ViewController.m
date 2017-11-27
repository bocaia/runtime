//
//  ViewController.m
//  runtime知识点
//
//  Created by songqingbo on 2017/11/22.
//  Copyright © 2017年 song. All rights reserved.
//

#import "ViewController.h"
#import "MyObject.h"
#import "UIView+SQBView.h"
#import <objc/runtime.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    1.类相关函数
//    得到类名 ViewController
    NSLog(@"%s",class_getName([self class]));
//    父类类名
//    This is superClass 0x10f426da0  isa指针地址
    NSLog(@"This is superClass %p",class_getSuperclass([self class]));

//    是否是元类
//    Is MateClass 0
    NSLog(@"Is MateClass %d",class_isMetaClass([self class]));
//    实例变量大小
//    848
    size_t a =  class_getInstanceSize([self class]);
    NSLog(@"%ld",a);
    unsigned int outCount = 0;
    MyObject *objtect = [[MyObject alloc] init];
    Class cls = objtect.class;
    
    //类名
    NSLog(@"Class name %s",class_getName(cls));
    //父类名字
    NSLog(@"SuperClass name  %s",class_getName(class_getSuperclass(cls)));
    //是否元类
    NSLog(@"Is MetaClass %@",(class_isMetaClass(cls))?@"":@"NOT");
    //变量大小
    NSLog(@"MyObject size %ld",class_getInstanceSize(cls));
    //变量信息
    Ivar string = class_getInstanceVariable(cls, "_string");
 
    if (string != NULL) {
         NSLog(@"MyObject instance messge %s",ivar_getName(string));
    }
    // 属性操作
    objc_property_t *v = class_copyPropertyList(cls, &outCount);
    for (NSInteger i = 0; i< outCount; i++) {
        objc_property_t property = v[i];
        NSLog(@"property is %s ",property_getName(property));
    }
    free(v);
   
    //成员变量
    Ivar *vars = class_copyIvarList(cls, &outCount);
    for (NSInteger i =0; i< outCount; i++) {
        Ivar ivar = vars[i];
        NSLog(@"copyIvarList is %s is %ld",ivar_getName(ivar),i);
    }
     free(vars);
    //方法操作
    Method *methods = class_copyMethodList(cls, &outCount);
    for (NSInteger i =0; i< outCount; i++) {
        Method met = methods[i];
    #pragma clang diagnostic ignored"-Wformat"
        NSLog(@"Method is %s",method_getName(met));
    }
    free(methods);

    //  Format specifies type 'char *' but the argument has type 'SEL _Nonnull'
    // 获取方法名
    Method method = class_getInstanceMethod(cls,@selector(method1));
    NSLog(@"Method name is %s",method_getName(method));
    //    判断方法是否存在
     #pragma clang diagnostic ignored"-Wundeclared-selector"
    NSLog(@"Have you method %d",class_respondsToSelector(cls, @selector(method3WithArge1:arge2:)));
    //    指向函数实现的指针，相当于方法的实现
    IMP imp = class_getMethodImplementation(cls, @selector(method1));
    imp();
    //动态创建类
     #pragma clang diagnostic ignored" -Wunused-variable"
    // 注:运行时规定,只能在objc_allocateClassPair与objc_registerClassPair两个函数之间为类添加变量
    //  1.添加一个自定义的类 类名是MySubClass
    //  父类class,类名,额外空间
    Class myClass = objc_allocateClassPair(objtect.class, "MySubClass", 0);
    //  2.增加方法，交换方法
    //注:  v@: 意思是 v是void   @:没有返回参数
    if( class_addMethod(myClass, @selector(mysubMethod1),(IMP)mysubMethod1, "v@:")){
        class_replaceMethod(myClass, @selector(method1),  (IMP)mysubMethod1,"v@:");
    }

    /*
     3.增加一个NSSsting类型属性  属性名myString
    变量size sizeof(NSString)
    对齐     指针类型的为log2(sizeof(NSString*))
    类型     @encode(NSString*)
    class_addIvar(class,变量名,变量size,对齐,类型)
    */
    //添加同名属性会失败
    BOOL isd =  class_addIvar(myClass, "_myString", sizeof(NSString *),  log(sizeof(NSString *)), @encode(NSString *));
    NSLog(@"属性是否添加成功 %d",isd);
    /*
    特性相关编码
    属性的特性字符串 以 T@encode(type) 开头, 以 V实例变量名称 结尾,中间以特性编码填充,通过property_getAttributes即可查看
    特性编码 具体含义
    R readonly
    C copy
    & retain ARC strong
    N nonatomic
    G(name) getter=(name)
    S(name) setter=(name)
    D @dynamic
    W weak
    P 用于垃圾回收机制
    */
    //@T
    objc_property_attribute_t type;
    type.name = "T";
    type.value = @encode(NSString *);
    //copy
    objc_property_attribute_t owership = {"C",""};
    //nonatomic
    objc_property_attribute_t oeership2 = {"N",""};
    //V_属性名
    objc_property_attribute_t var = {"V","_myString"};
    //特性数组
    objc_property_attribute_t attributes[] = {type,owership,oeership2,var};
    //向类中添加名为myString的属性,属性的特性包含在attributes中
    class_addProperty(myClass, "myString", attributes, 4);
    unsigned int propertyCount;
    objc_property_t * properties = class_copyPropertyList(myClass, &propertyCount);
    for (int i = 0; i<propertyCount; i++) {
        NSLog(@"属性的名称为 : %s",property_getName(properties[i]));
        NSLog(@"属性的特性字符串为: %s",property_getAttributes(properties[i]));
    }
    //释放属性列表数组
    free(properties);
    
    //在应用中注册由objc_allocateClassPair创建的类
    objc_registerClassPair(myClass);
    
    id instance = [[myClass alloc] init];
    [instance performSelector:@selector(mysubMethod1)];
    [instance performSelector:@selector(method1)];
    
    // 销毁一个类及相关联的类
    //    不过需要注意的是，如果程序运行中还存在类或其子类的实例，则不能调用针对类调用该方法
    //objc_disposeClassPair(myClass);
    
    //关联对象
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    view.backgroundColor = [UIColor redColor];
    [view setTapActionWithBlock:^{
        NSLog(@"saAS");
    }];
    [self.view addSubview:view];
//    SEL
//    Objective-C在编译时，会依据每一个方法的名字、参数序列，生成一个唯一的整型标识(Int类型的地址)，这个标识就是SEL
//    SEL只是一个指向方法的指针（准确的说，只是一个根据方法名hash化了的KEY值，能唯一代表一个方法
//  而对于字符串的比较仅仅需要比较他们的地址就可以了，可以说速度上无语伦比
//    sel : 0x104dd7735
    /*
    三种方法来获取SEL:
    
    sel_registerName函数
    Objective-C编译器提供的@selector()
    NSSelectorFromString()方法
    */

    SEL sel1 = @selector(method1);
    NSLog(@"sel : %p", sel1);
}

static void mysubMethod1(id self,SEL _cmd){
    NSLog(@"这是添加的方法");
}



@end
