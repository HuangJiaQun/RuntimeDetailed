//
//  DynamicMethodParsingVC.m
//  RuntimeDetailed
//
//  Created by 黄 嘉群 on 2023/10/18.
//

#import "DynamicMethodParsingVC.h"
#import <objc/runtime.h>
@implementation Person
- (void)foo{
    NSLog(@"Doing foo");//Person的foo函数
}
@end




@interface DynamicMethodParsingVC ()

@end

@implementation DynamicMethodParsingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //前文介绍了进行一次发送消息会在相关的类对象中搜索方法列表，如果找不到则会沿着继承树向上一直搜索知道继承树根部（通常为NSObject），如果还是找不到并且消息转发都失败了就回执行doesNotRecognizeSelector:方法报unrecognized selector错。那么消息转发到底是什么呢？接下来将会逐一介绍最后的三次机会。
    
   //1 动态方法解析
    //首先，Objective-C运行时会调用 +resolveInstanceMethod:或者 +resolveClassMethod:，让你有机会提供一个函数实现。如果你添加了函数并返回YES， 那运行时系统就会重新启动一次消息发送的过程。
    //执行foo函数
    //2 备用接收者
    //3 完整消息转发
    [self performSelector:@selector(foo:)];
    // Do any additional setup after loading the view.
}

//动态方法解析的例子
//实例方法 ,resolve方法返回 NO ，运行时就会移到下一步：forwardingTargetForSelector。

+ (BOOL)resolveInstanceMethod:(SEL)sel{
#if 0
    return YES;//返回YES，进入下一步转发备用接收者
#else
    if(sel==@selector(foo:)){
        //如果是执行foo函数，就动态解析，指定新的IMP,实现foo:这个函数，但是我们通过class_addMethod动态添加fooMethod函数，并执行fooMethod这个函数的IMP
        class_addMethod([self class], sel, (IMP)fooMethod, @"v@:");
        return YES;
    }
    return  [super resolveInstanceMethod:sel];
#endif
}

void fooMethod(id obj, SEL _cmd) {
    NSLog(@"Doing foo");//新的foo函数
}

static void myDynamicClassMethodImplementation(id self, SEL _cmd) {
    NSLog(@"Dynamic class method called!");
}

+ (BOOL)resolveClassMethod:(SEL)sel {
    if (sel == @selector(myDynamicClassMethod)) {
        // Provide the implementation for the dynamic class method
        Class metaClass = object_getClass(self);
        class_addMethod(metaClass, sel, (IMP)myDynamicClassMethodImplementation, "v@:");
        return YES; // Indicates a successful implementation
    }

    return [super resolveClassMethod:sel]; // Call the default implementation of the superclass
}

+ (void)myDynamicClassMethod {
    NSLog(@"Dynamic class method called!");
}



///备用接收者,如果目标对象实现了-forwardingTargetForSelector:，Runtime 这时就会调用这个方法，给你把这个消息转发给其他对象的机会

- (id)forwardingTargetForSelector:(SEL)aSelector {
    
#if 0
    return nil;//返回nil，进入下一步转发完整消息转发
#else
    if (aSelector == @selector(foo)) {
        return [Person new];//返回Person对象，让Person对象接收这个消息
    }
    
    return [super forwardingTargetForSelector:aSelector];
#endif
    
}


//2.12 完整消息转发
//如果在上一步还不能处理未知消息，则唯一能做的就是启用完整的消息转发机制了。 首先它会发送-methodSignatureForSelector:消息获得函数的参数和返回值类型。如果-methodSignatureForSelector:返回nil ，Runtime则会发出 -doesNotRecognizeSelector: 消息，程序这时也就挂掉了。
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    //消息获得函数的参数和返回值类型
    
#if 0
    if ([NSStringFromSelector(aSelector) isEqualToString:@"foo"]) {
        //如果返回了一个函数签名，Runtime就会创建一个NSInvocation 对象并发送 -forwardInvocation:消息给目标对象。
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];//签名，进入forwardInvocation
    }
    
    return [super methodSignatureForSelector:aSelector];
#else
    return  nil;
#endif
    
}


- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL sel = anInvocation.selector;
    Person *p = [Person new];
    if([p respondsToSelector:sel]) {
        [anInvocation invokeWithTarget:p];
    }
    else {
        [self doesNotRecognizeSelector:sel];
    }
}

- (void)doesNotRecognizeSelector:(SEL)aSelector{
    
}
@end
