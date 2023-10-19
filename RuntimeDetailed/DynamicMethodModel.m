//
//  DynamicMethodModel.m
//  RuntimeDetailed
//
//  Created by 黄 嘉群 on 2023/10/19.
//

#import "DynamicMethodModel.h"
#import <objc/runtime.h>
#import <objc/message.h>
//实现NSCoding的自动归档和自动解档
//
//原理描述：用runtime提供的函数遍历Model自身所有属性，并对属性进行encode和decode操作。 核心方法：在Model的基类中重写方法：
@implementation DynamicMethodModel
//归档
- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]){
        unsigned int outCount;
        Ivar *ivars = class_copyIvarList([self class], &outCount);
        for (int i = 0; i < outCount; i ++) {
            Ivar ivar = ivars[i];
            NSString*key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
        }
    }
    
    return self;
}


- (void)encodeWithCoder:(NSCoder*)aCoder{
    unsigned int outCount;
    Ivar *ivars = class_copyIvarList([self class], &outCount);
    for (int i = 0; i < outCount; i++) {
        Ivar ivar = ivars[i];
        //将获取到的C字符串转换为NSString对象，以便后续使用。
        NSString*key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        //用KVC（Key-Value Coding）来获取对象key为名称的属性的值
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
}

@end
