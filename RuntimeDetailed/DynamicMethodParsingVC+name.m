//
//  DynamicMethodParsingVC+name.m
//  RuntimeDetailed
//
//  Created by 黄 嘉群 on 2023/10/18.
//

#import "DynamicMethodParsingVC+name.h"
#import <objc/runtime.h>
@implementation DynamicMethodParsingVC (name)


//OBJC_ASSOCIATION_ASSIGN    @property (assign) 或 @property (unsafe_unretained)    指定一个关联对象的弱引用。
//OBJC_ASSOCIATION_RETAIN_NONATOMIC    @property (nonatomic, strong)    @property (nonatomic, strong) 指定一个关联对象的强引用，不能被原子化使用。
//OBJC_ASSOCIATION_COPY_NONATOMIC    @property (nonatomic, copy)    指定一个关联对象的copy引用，不能被原子化使用。
//OBJC_ASSOCIATION_RETAIN    @property (atomic, strong)    指定一个关联对象的强引用，能被原子化使用。
//OBJC_ASSOCIATION_COPY    @property (atomic, copy)    指定一个关联对象的copy引用，能被原子化使用。

- (void)setName:(NSString *)name
{
    // 添加关联参数
    objc_setAssociatedObject(self, @selector(name), name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)name
{
    // 隐式参数
    // _cmd == @selector(name)
    // 获取关联参数值
    return objc_getAssociatedObject(self, _cmd);
}
@end
