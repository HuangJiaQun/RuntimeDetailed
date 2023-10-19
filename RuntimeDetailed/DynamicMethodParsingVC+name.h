//
//  DynamicMethodParsingVC+name.h
//  RuntimeDetailed
//
//  Created by 黄 嘉群 on 2023/10/18.
// Category(objc_category)

#import "DynamicMethodParsingVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface DynamicMethodParsingVC (name)
//不是说分类不能添加属性,是因为分类可以添加属性,但是由于系统不会自动帮分类的属性实现getter和setter方法,也不会帮其生成_TCName,无论你重写settet或者getter还是,你不能通过self.TCName去访问属性,重写了setter,这么访问就会发生递归,直接导致程序闪退。 根本原因是程序在运行期,对象的内存布局已经确定,如果添加实例变量就会破坏类的内部布局,因此 Category 中不能添加属性!
@property (copy, nonatomic) NSString *name;
@end

NS_ASSUME_NONNULL_END
