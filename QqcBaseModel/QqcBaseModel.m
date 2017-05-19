//
//  QqcBaseModel.m
//  QqcRequestFramework
//
//  Created by mahailin on 15/8/10.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import "QqcBaseModel.h"
#import <objc/runtime.h>

#ifdef DEBUG

static NSMutableDictionary *ivarDictionay = nil;

#endif

@implementation QqcBaseModel

#ifdef DEBUG

/**
 *  将实体转成字符串描述
 *
 *  @return 返回NSString实例
 */
- (NSString *)description
{
    Class cls = [self class];
    NSString *className = NSStringFromClass(cls);
    
    if (ivarDictionay == nil)
    {
        ivarDictionay = [[NSMutableDictionary alloc] init];
    }
    
    if ([ivarDictionay objectForKey:className] == nil)
    {
        NSMutableArray *ivarArray = [[NSMutableArray alloc] init];
        unsigned int count = 0;
        
        do
        {
            Ivar *ivars = class_copyIvarList(cls, &count);
            
            for (uint i = 0; i < count; i++)
            {
                NSString *ivar = [[NSString alloc] initWithUTF8String:ivar_getName(ivars[i])];
                [ivarArray addObject:ivar];
            }
            
            free(ivars);
        }
        while ((cls = class_getSuperclass(cls))!= [QqcBaseModel class]);
        
        [ivarDictionay setObject:ivarArray forKey:className];
    }
    
    NSArray *ivarArray = [ivarDictionay objectForKey:className];
    NSMutableDictionary *ivarDictionary = [[NSMutableDictionary alloc] initWithCapacity:ivarArray.count];
    
    for (NSString *ivar in ivarArray)
    {
        id value = [self valueForKey:ivar];
        [ivarDictionary setValue:(value ? value : [NSNull null]) forKey:ivar];
    }
    
    NSString *_description = [ivarDictionary description];
    return _description;
}

#endif

#pragma mark -
#pragma mark ==== BaseModel协议 ====
#pragma mark -

/**
 *  使用JSON对象，字典，数组，转换为实体，或实体数组
 *
 *  @param jsonData 字典或数组的JSON对象
 *
 *  @return BaseModel实例或者BaseModel数组
 */
+ (id)instanceWithJSON:(id)jsonData
{
    if ([jsonData isKindOfClass:[NSArray class]]) {
        return [self modelArrayWithDictionaryArray:jsonData];
    }else if ([jsonData isKindOfClass:[NSDictionary class]]) {
        return [self instanceWithDictionary:jsonData];
    }else if ([jsonData isKindOfClass:[NSString class]]){
        
        if ([jsonData respondsToSelector:@selector(qwt_JSONObject)]) {
            
            return [self instanceWithJSON:[jsonData performSelector:@selector(qwt_JSONObject)]];
        }
    }
    
    return nil;
}

/**
 *  使用字典初始化一个实例
 *
 *  @param dictionary 包含初始化数据的字典
 *
 *  @return BaseModel实例
 */
+ (instancetype)instanceWithDictionary:(NSDictionary *)dictionary
{
    return [dictionary isKindOfClass:[NSDictionary class]] ? [[self alloc] initWithDictionary:dictionary] : nil;
}

/**
 *  使用字典初始化一个实例
 *
 *  @param dictionary 包含初始化数据的字典
 *
 *  @return BaseModel实例
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (![dictionary isKindOfClass:[NSDictionary class]])
    {
        return nil;
    }
    
    self = [self init];
    
    if (self)
    {
        id key;
        static SEL selector = NULL;
        static NSString *setMethodString = @"set%@:";
        NSEnumerator *enumerator = [dictionary keyEnumerator];
        
        while ((key = [enumerator nextObject]))
        {
            if (![key isKindOfClass:[NSString class]])
            {
                continue;
            }
            
            id obj = [dictionary objectForKey:key];
            
            if ([[NSNull null] isEqual:obj] || !obj)
            {
                continue;
            }
            
            if ([obj isKindOfClass:[NSArray class]]) {
                obj = [[NSMutableArray alloc] initWithArray:obj];
            }
            
            selector = NSSelectorFromString([NSString stringWithFormat:setMethodString, [self capitalize:key]]);
            
            if (selector != NULL && [self respondsToSelector:selector])
            {
                [self setValue:obj forKey:key];
            }
        }
        
        selector = NULL;
    }
    
    return self;
}

/**
 *  传入指定的dictionary数组，生成对应实体的数组
 *
 *  @param dictionaryArray dictionary数组
 *
 *  @return 实体数组
 */
+ (NSMutableArray *)modelArrayWithDictionaryArray:(NSArray *)dictionaryArray
{
    if (![dictionaryArray isKindOfClass:[NSArray class]] || dictionaryArray.count == 0)
    {
        return [NSMutableArray array];
    }
    
    NSMutableArray *modelArray = [NSMutableArray arrayWithCapacity:dictionaryArray.count];
    
    for (NSDictionary *dictionary in dictionaryArray)
    {
        if ([dictionary isKindOfClass:[NSDictionary class]])
        {
            id model = [[[self class] alloc] initWithDictionary:dictionary];
            [modelArray addObject:model];
        }
    }
    
    return modelArray;
}

/**
 *  将实体转为字典类型
 *
 *  @return 返回字典类型实例
 */
- (NSDictionary *)dictionaryValue
{
    Class baseModelClass = [QqcBaseModel class];
    
    if ([self isMemberOfClass:baseModelClass])
    {
        return nil;
    }
    
    Class cls = [self class];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    do
    {
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList(cls, &count);
        
        for (unsigned int i=0; i<count; i++)
        {
            NSString *prop = [[NSString alloc] initWithUTF8String:property_getName(properties[i])];
            id value = [self valueForKey:prop];
            
            if (!value)
            {
                continue;
            }
            
            if ([value isKindOfClass:baseModelClass])//处理值为basemodel子类
            {
                [dictionary setValue:[(QqcBaseModel *)value dictionaryValue] forKey:prop];
            }
            else if ([value isKindOfClass:[NSArray class]])//处理值为数组
            {
                NSArray *valueArray = (NSArray *)value;
                NSMutableArray *modelArray = [[NSMutableArray alloc] initWithCapacity:valueArray.count];
                
                for (QqcBaseModel *model in valueArray)
                {
                    if ([model isKindOfClass:baseModelClass])
                    {
                        [modelArray addObject:[model dictionaryValue]];
                    }
                    else
                    {
                        [modelArray addObject:model];
                    }
                }
                
                [dictionary setValue:modelArray forKey:prop];
            }
            else
            {
                [dictionary setValue:value forKey:prop];
            }
        }
        
        free(properties);
    }
    while ((cls = class_getSuperclass(cls))!= baseModelClass);
    
    return dictionary;
}


#pragma mark -
#pragma mark ==== 内部使用方法 ====
#pragma mark -

/**
 *  将字符串首字母处理为大写字母
 *
 *  @return 返回处理后的字符串
 */
- (NSString *)capitalize:(NSString *)string
{
    if (!string || string.length == 0 || islower([string characterAtIndex:0]) == 0)
    {
        return string;
    }
    
    return [[string substringToIndex:1].uppercaseString stringByAppendingString:[string substringFromIndex:1]];
}

#pragma mark -
#pragma mark ==== NSKeyValueCoding Protocol ====
#pragma mark -

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"%@ is not in %@", key, NSStringFromClass([self class]));
}

- (void)setNilValueForKey:(NSString *)key
{
    NSLog(@"set nil value for %@ in %@", key, NSStringFromClass([self class]));
}

#pragma mark -
#pragma mark ==== NSCoding Protocol ====
#pragma mark -

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    
    if (self)
    {
        static SEL selector = NULL;
        Class baseModelClass = [QqcBaseModel class];
        static NSString *setMethodString = @"set%@:";
        
        if (![self isMemberOfClass:baseModelClass])
        {
            Class cls = [self class];
            
            do
            {
                unsigned int count = 0;
                objc_property_t *properties = class_copyPropertyList(cls, &count);
                
                for (unsigned int i = 0; i < count; i++)
                {
                    NSString *key = [[NSString alloc] initWithUTF8String:property_getName(properties[i])];
                    id obj = [decoder decodeObjectForKey:key];
                    
                    if ([[NSNull null] isEqual:obj] || !obj)
                    {
                        continue;
                    }
                    
                    selector = NSSelectorFromString([NSString stringWithFormat:setMethodString, [self capitalize:key]]);
                    
                    if (selector != NULL && [self respondsToSelector:selector])
                    {
                        [self setValue:obj forKey:key];
                    }
                }
                
                free(properties);
            }
            while ((cls = class_getSuperclass(cls))!= baseModelClass);
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    Class baseModelClass = [QqcBaseModel class];
    
    if ([self isMemberOfClass:baseModelClass])
    {
        return;
    }
    
    Class cls = [self class];
    
    do
    {
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList(cls, &count);
        
        for (unsigned int i = 0; i < count; i++)
        {
            NSString *prop = [[NSString alloc] initWithUTF8String:property_getName(properties[i])];
            id value = [self valueForKey:prop];
            
            if (!value)
            {
                continue;
            }
            
            [encoder encodeObject:value forKey:prop];;
        }
        
        free(properties);
    }
    while ((cls = class_getSuperclass(cls))!= baseModelClass);
}

@end
