//
//  ExtTool.h
//  GDPR
//
//  Created by unakayou on 10/30/18.
//  Copyright © 2018 unakayou. All rights reserved.
//  处理ConsentString 转换

#import <Foundation/Foundation.h>
@class VendorItem, PurposeItem;

NS_ASSUME_NONNULL_BEGIN

@interface ExtTool : NSObject


/**
 十进制转二进制

 @param decimal 十进制
 @return 二进制
 */
+ (NSString *)binaryFromDecimal:(NSInteger)decimal;

/**
 二进制转十进制

 @param binary 二进制
 @return 十进制
 */
+ (NSInteger)decimalFromBinary:(NSString *)binary;


/**
 通过供应商列表、许可列表生成许可字符串

 @param vendorArray 供应商列表
 @param purposeArray 许可列表
 @return 许可字符串
 */
+ (NSString *)consentStringFromVendors:(NSArray <VendorItem *>*)vendorArray purposes:(NSArray <PurposeItem *>*)purposeArray;


/**
 查找位于许可字符串的二进制字符串上的某位的值(用于解析许可字符串)

 @param consentString 许可字符串
 @param location 起始位置
 @param length 长度
 @return 二进制字符串片段
 */
+ (NSString *)bitsFromConsentString:(NSString *)consentString location:(NSInteger)location length:(NSInteger)length;
@end

NS_ASSUME_NONNULL_END
