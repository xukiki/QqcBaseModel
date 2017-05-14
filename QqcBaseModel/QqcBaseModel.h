//
//  QqcBaseModel.h
//  QqcRequestFramework
//
//  Created by mahailin on 15/8/10.
//  Copyright (c) 2015年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  QqcBaseModelProtocol要实现的协议
 */
@protocol QqcBaseModelProtocol <NSObject>

@required

/**
 *  使用JSON对象，字典，数组，转换为实体，或实体数组
 *
 *  @param jsonData 字典或数组的JSON对象
 *
 *  @return BaseModel实例或者BaseModel数组
 */
+ (id)instanceWithJSON:(id)jsonData;
//- (id)instanceWithJSON:(id)jsonData;

/**
 *  使用字典初始化一个实例
 *
 *  @param dictionary 包含初始化数据的字典
 *
 *  @return BaseModel实例
 */
+ (instancetype)instanceWithDictionary:(NSDictionary *)dictionary;

/**
 *  使用字典初始化一个实例
 *
 *  @param dictionary 包含初始化数据的字典
 *
 *  @return BaseModel实例
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;


/**
 *  传入指定的dictionary数组，生成对应实体的数组
 *
 *  @param dictionaryArray dictionary数组
 *
 *  @return 实体数组
 */
+ (NSMutableArray *)modelArrayWithDictionaryArray:(NSArray *)dictionaryArray;

/**
 *  将实体转为字典类型
 *
 *  @return 返回字典类型实例
 */
- (NSDictionary *)dictionaryValue;


@end

/**
 *  所有实体类的基类
 */
@interface QqcBaseModel : NSObject<QqcBaseModelProtocol, NSCoding>

@end
