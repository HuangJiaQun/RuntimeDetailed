//
//  ViewController.m
//  RuntimeDetailed
//
//  Created by 黄 嘉群 on 2023/10/18.
//

#import "ViewController.h"
#import "DynamicMethodModel.h"

#import <objc/runtime.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    Runtime简直就是做大型框架的利器。它的应用场景非常多，下面就介绍一些常见的应用场景。
//    1关联对象(Objective-C Associated Objects)给分类增加属性
    //关联对象
    //void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy)
    //获取关联的对象
    //id objc_getAssociatedObject(id object, const void *key)
    //移除关联的对象
    //void objc_removeAssociatedObjects(id object)
    
    
//    2方法魔法(Method Swizzling)方法添加和替换和KVO实现
    /*
    class_addMethod([self class], sel, (IMP)fooMethod, "v@:");
    cls 被添加方法的类
    name 添加的方法的名称的SEL
    imp 方法的实现。该函数必须至少要有两个参数，self,_cmd
    类型编码
    KVO实现

    全称是Key-value observing，翻译成键值观察。提供了一种当其它对象属性被修改的时候能通知当前对象的机制。再MVC大行其道的Cocoa中，KVO机制很适合实现model和controller类之间的通讯。
     
     KVO的实现依赖于 Objective-C 强大的 Runtime，当观察某对象 A 时，KVO 机制动态创建一个对象A当前类的子类，并为这个新的子类重写了被观察属性 keyPath 的 setter 方法。setter 方法随后负责通知观察对象属性的改变状况。

     Apple 使用了 isa-swizzling 来实现 KVO 。当观察对象A时，KVO机制动态创建一个新的名为：NSKVONotifying_A的新类，该类继承自对象A的本类，且 KVO 为 NSKVONotifying_A 重写观察属性的 setter 方法，setter 方法会负责在调用原 setter 方法之前和之后，通知所有观察对象属性值的更改情况。
     
     NSKVONotifying_A 类剖析
     NSLog(@"self->isa:%@",self->isa);
     NSLog(@"self class:%@",[self class]);
     在建立KVO监听前，打印结果为：

     self->isa:A
     self class:A
     在建立KVO监听之后，打印结果为：

     self->isa:NSKVONotifying_A
     self class:A
     在这个过程，被观察对象的 isa 指针从指向原来的 A 类，被KVO 机制修改为指向系统新创建的子类NSKVONotifying_A 类，来实现当前类属性值改变的监听； 所以当我们从应用层面上看来，完全没有意识到有新的类出现，这是系统“隐瞒”了对 KVO 的底层实现过程，让我们误以为还是原来的类。但是此时如果我们创建一个新的名为“NSKVONotifying_A”的类，就会发现系统运行到注册 KVO 的那段代码时程序就崩溃，因为系统在注册监听的时候动态创建了名为 NSKVONotifying_A 的中间类，并指向这个中间类了。

     子类setter方法剖析
     KVO 的键值观察通知依赖于 NSObject 的两个方法:willChangeValueForKey:和 didChangeValueForKey: ，在存取数值的前后分别调用 2 个方法： 被观察属性发生改变之前，willChangeValueForKey:被调用，通知系统该 keyPath 的属性值即将变更； 当改变发生后， didChangeValueForKey: 被调用，通知系统该keyPath 的属性值已经变更；之后， observeValueForKey:ofObject:change:context:也会被调用。且重写观察属性的setter 方法这种继承方式的注入是在运行时而不是编译时实现的。
     - (void)setName:(NSString *)newName {
           [self willChangeValueForKey:@"name"];    //KVO 在调用存取方法之前总调用
           [super setValue:newName forKey:@"name"]; //调用父类的存取方法
           [self didChangeValueForKey:@"name"];     //KVO 在调用存取方法之后总调用
     }
     
     KVO 只能用于 NSObject 的子类。
     被观察的属性必须通过属性的setter方法来改变，而不是直接修改成员变量。
     观察者需要实现一个特定的方法，observeValueForKeyPath:ofObject:change:context:以接收属性变化的通知。
    */
    
//    3消息转发(热更新)解决Bug(JSPatch)
//    4实现NSCoding的自动归档和自动解档
    DynamicMethodModel *de = [[DynamicMethodModel alloc]init];
    de.name = @"huangjaiqun";
    de.sex = @"男";
    de.age = 27;
    de.favorite = [NSArray arrayWithObjects:@"化学",@"滑雪",@"看书", nil];
    
    NSLog(@"%@,%@,%d",de.name,de.sex,de.age);
//    5实现字典和模型的自动转换(MJExtension)
    //原理描述：用runtime提供的函数遍历Model自身所有属性，如果属性在json中有对应的值，则将其赋值。 核心方法：在NSObject的分类中添加方法
    
    // Do any additional setup after loading the view.
}

+ (void)initialize{
    NSLog(@"initialize的方法");
}

//方法交换
+ (void)load{
//    swizzling应该只在+load中完成。 在 Objective-C 的运行时中，每个类有两个方法都会自动调用。+load 是在一个类被初始装载时调用，+initialize 是在应用第一次调用该类的类方法或实例方法前调用的。两个方法都是可选的，并且只有在方法被实现的情况下才会被调用。
//
//    swizzling应该只在dispatch_once 中完成,由于swizzling 改变了全局的状态，所以我们需要确保每个预防措施在运行时都是可用的。原子操作就是这样一个用于确保代码只会被执行一次的预防措施，就算是在不同的线程中也能确保代码只执行一次。Grand Central Dispatch 的 dispatch_once满足了所需要的需求，并且应该被当做使用swizzling 的初始化单例方法的标准。
#if 0
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        Class class = [self class];
        ///原始选择器
        SEL originalSelector = @selector(viewDidLoad);
        SEL swizzledSelector = @selector(jkviewDidLoad);
        //原始方法名
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        //判断名为 swizzledMethod 的方法已经存在
        //method_getTypeEncoding(swizzledMethod)：这将检索方法的类型编码。类型编码描述了方法的返回类型和参数类型
        
        //该代码检查是否swizzledMethod已添加到类中。如果不是，它将添加swizzledMethod到类中。如果已经添加，您可以使用此检查来确定是否继续进行调整
        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        
        if(didAddMethod){
            //方法添加成功
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        }else{
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        
    });
#endif
    
    
}

- (void)jkviewDidLoad {
    NSLog(@"替换的方法");
    [self jkviewDidLoad];
}

//Runtime的特性主要是消息(方法)传递，如果消息(方法)在对象中找不到，就进行转发。

/*1、Runtime介绍
 
 Objective-C 扩展了 C 语言，并加入了面向对象特性和 Smalltalk 式的消息传递机制。而这个扩展的核心是一个用 C 和 编译语言 写的 Runtime 库。它是 Objective-C 面向对象和动态机制的基石。
 
 Objective-C 是一个动态语言，这意味着它不仅需要一个编译器，也需要一个运行时系统来动态得创建类和对象、进行消息传递和转发。理解 Objective-C 的 Runtime 机制可以帮我们更好的了解这个语言，适当的时候还能对语言进行扩展，从系统层面解决项目中的一些设计或技术问题。了解 Runtime ，要先了解它的核心 - 消息传递 （Messaging）。
    Runtime 基本是用 C 和汇编写的。 我们现在用的 Objective-C 2.0 采用的是现行 (Modern) 版的 Runtime 系统，只能运行在 iOS 和 macOS 10.5 之后的 64 位程序中。
*/

//2、Runtime消息传递

/*一个对象的方法像这样[obj foo]，编译器转成消息发送objc_msgSend(obj, foo)，Runtime时执行的流程是这样的：
 首先，通过obj的isa指针找到class;
 在class的methodList中找到foo;
 如果class没找到,继续往他的superclass找，一直搜索继承树根部（通常为NSObject）；
 一旦找到这个函数，就执行他的实现imp。如果还是找不到并且消息转发都失败了就回执行doesNotRecognizeSelector:方法报unrecognized selector错
 
 
 
 但这种实现有个问题，效率低。但一个class 往往只有 20% 的函数会被经常调用，可能占总调用次数的 80% 。每个消息都需要遍历一次objc_method_list 并不合理。如果把经常被调用的函数缓存下来，那可以大大提高函数查询的效率。这也就是objc_class 中另一个重要成员objc_cache 做的事情，在找到foo后吧foo的method_name作为key，method_imp作为value存起来。当再次收到foo消息的时候，直接在cache中找，
 OBJC_EXPORT id objc_msgSend(id self, SEL op, ...)
 //类
 struct objc_class {
     Class isa  OBJC_ISA_AVAILABILITY;
 #if !__OBJC2__
     Class super_class                                       OBJC2_UNAVAILABLE;
     const char *name                                        OBJC2_UNAVAILABLE;
     long version                                            OBJC2_UNAVAILABLE;
     long info                                               OBJC2_UNAVAILABLE;
     long instance_size                                      OBJC2_UNAVAILABLE;
     struct objc_ivar_list *ivars                            OBJC2_UNAVAILABLE;
     struct objc_method_list **methodLists                   OBJC2_UNAVAILABLE;
     struct objc_cache *cache                                OBJC2_UNAVAILABLE;
     struct objc_protocol_list *protocols                    OBJC2_UNAVAILABLE;
 #endif
 } OBJC2_UNAVAILABLE;
 //方法列表
 struct objc_method_list {
     struct objc_method_list *obsolete                       OBJC2_UNAVAILABLE;
     int method_count                                        OBJC2_UNAVAILABLE;
 #ifdef __LP64__
     int space                                               OBJC2_UNAVAILABLE;
 #endif
     struct objc_method method_list[1]                       OBJC2_UNAVAILABLE;
 }OBJC2_UNAVAILABLE;
 //方法
 struct objc_method {
     SEL method_name                                         OBJC2_UNAVAILABLE;
     char *method_types                                      OBJC2_UNAVAILABLE;
     IMP method_imp                                          OBJC2_UNAVAILABLE;
 }
 
 系统首先找到消息的接收对象，然后通过对象的isa找到它的类。
 在它的类中查找method_list，是否有selector方法。
 没有则查找父类的method_list。
 找到对应的method，执行它的IMP。
 转发IMP的return值。
 下面讲讲消息传递用到的一些概念：

//类对象(objc_class):---------------------------
 struct objc_class结构体定义了很多变量，通过命名不难发现， 结构体里保存了指向父类的指针、类的名字、版本、实例大小、实例变量列表、方法列表、缓存、遵守的协议列表等， 一个类包含的信息也不就正是这些吗？没错，类对象就是一个结构体struct objc_class，这个结构体存放的数据称为元数据(metadata)， 该结构体的第一个成员变量也是isa指针，这就说明了Class本身其实也是一个对象，因此我们称之为类对象，类对象在编译期产生用于创建实例对象，是单例
 
 //实例(objc_object):---------------------------
 struct objc_object {
     Class isa  OBJC_ISA_AVAILABILITY;
 };
 ​
 /// A pointer to an instance of a class.
 typedef struct objc_object *id;
 
 //元类(Meta Class):---------------------------
 类对象中的元数据存储的都是如何创建一个实例的相关信息，那么类对象和类方法应该从哪里创建呢？ 就是从isa指针指向的结构体创建，类对象的isa指针指向的我们称之为元类(metaclass)， 元类中保存了创建类对象以及类方法所需的所有信息
 通过上图我们可以看出整个体系构成了一个自闭环，struct objc_object结构体实例它的isa指针指向类对象， 类对象的isa指针指向了元类，super_class指针指向了父类的类对象， 而元类的super_class指针指向了父类的元类，那元类的isa指针又指向了自己。

 元类(Meta Class)是一个类对象的类。 在上面我们提到，所有的类自身也是一个对象，我们可以向这个对象发送消息(即调用类方法)。 为了调用类方法，这个类的isa指针必须指向一个包含这些类方法的一个objc_class结构体。这就引出了meta-class的概念，元类中保存了创建类对象以及类方法所需的所有信息。 任何NSObject继承体系下的meta-class都使用NSObject的meta-class作为自己的所属类，而基类的meta-class的isa指针是指向它自己。

// Method(objc_method):---------------------------
 
 /// An opaque type that represents a method in a class definition.代表类定义中一个方法的不透明类型
 typedef struct objc_method *Method;
 struct objc_method {
 方法名      SEL method_name                           OBJC2_UNAVAILABLE;
 方法类型    char *method_types                        OBJC2_UNAVAILABLE;
 方法实现    IMP method_imp                            OBJC2_UNAVAILABLE;
 }
 Method和我们平时理解的函数是一致的，就是表示能够独立完成一个功能的一段代码，比如：
 - (void)logName
 {
     NSLog(@"name");
 }
 
 
 //SEL(objc_selector):---------------------------
 typedef struct objc_selector *SEL;
 objc_msgSend函数第二个参数类型为SEL，它是selector在Objective-C中的表示类型（Swift中是Selector类）。selector是方法选择器，可以理解为区分方法的 ID，而这个 ID 的数据结构是SEL:@property SEL selector;可以看到selector是SEL的一个实例。
 其实selector就是个映射到方法的C字符串，你可以用 Objective-C 编译器命令@selector()或者 Runtime 系统的sel_registerName函数来获得一个 SEL 类型的方法选择器。
 selector既然是一个string，我觉得应该是类似className+method的组合，命名规则有两条：
 同一个类，selector不能重复
 不同的类，selector可以重复
 这也带来了一个弊端，我们在写C代码的时候，经常会用到函数重载，就是函数名相同，参数不同，但是这在Objective-C中是行不通的，因为selector只记了method的name，没有参数，所以没法区分不同的method,我们只能通过命名来区别：
 
 
 //IMP:----------------------------------------------------------------------
 typedef id (*IMP)(id, SEL, ...);
 就是指向最终实现程序的内存地址的指针。
 在iOS的Runtime中，Method通过selector和IMP两个属性，实现了快速查询方法及实现，相对提高了性能，又保持了灵活性。
 
 
 //类缓存(objc_cache):---------------------------
 当Objective-C运行时通过跟踪它的isa指针检查对象时，它可以找到一个实现许多方法的对象。然而，你可能只调用它们的一小部分，并且每次查找时，搜索所有选择器的类分派表没有意义。所以类实现一个缓存，每当你搜索一个类分派表，并找到相应的选择器，它把它放入它的缓存。所以当objc_msgSend查找一个类的选择器，它首先搜索类缓存。这是基于这样的理论：如果你在类上调用一个消息，你可能以后再次调用该消息。

 为了加速消息分发， 系统会对方法和对应的地址进行缓存，就放在上述的objc_cache，所以在实际运行中，大部分常用的方法都是会被缓存起来的，Runtime系统实际上非常快，接近直接执行内存地址的程序速度。
 
 
 //Category(objc_category):---------------------------
 Category是表示一个指向分类的结构体的指针，其定义如下：
 struct category_t {
     const char *name;是指 class_name 而不是 category_name。
     classref_t cls;要扩展的类对象，编译期间是不会定义的，而是在Runtime阶段通过name对应到对应的类对象。
     struct method_list_t *instanceMethods;category中所有给类添加的实例方法的列表。
     struct method_list_t *classMethods;category中所有添加的类方法的列表。
     struct protocol_list_t *protocols;category实现的所有协议的列表。
     struct property_list_t *instanceProperties;表示Category里所有的properties，这就是我们可以通过objc_setAssociatedObject和objc_getAssociatedObject增加实例变量的原因，不过这个和一般的实例变量是不一样的。
 };
 属性是对成员变量的高级封装，提供了更灵活的访问方式和控制选项，而成员变量是实际的数据存储，通常位于属性的背后作业
 */



@end
