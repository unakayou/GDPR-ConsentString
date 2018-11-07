//
//  ConsentManager.h
//  GDPR
//
//  Created by unakayou on 10/25/18.
//  Copyright © 2018 unakayou. All rights reserved.
//  用于生成、解析、读取、持久化许可字符串

#import <Foundation/Foundation.h>
#import "ConsentStringItem.h"
#import "PurposeItem.h"
#import "VendorItem.h"

typedef enum : NSUInteger {
    ConsentStringSave_Purpose,  //保存purpose设置到consentString
    ConsentStringSave_Vendor,   //保存vendor设置到consentString
    ConsentStringSave_All       //保存两者到consentString
} ConsentStringSaveType;

NS_ASSUME_NONNULL_BEGIN

@interface ConsentManager : NSObject
@property (nonatomic, strong, readonly) NSString * vendroListVersion;               //供应商列表版本
@property (nonatomic, strong, readonly) NSArray <VendorItem *>* vendorArray;        //供应商模型数组
@property (nonatomic, strong, readonly) NSArray <PurposeItem *>* purposeItemArray;  //用途模型数组
@property (nonatomic, strong, readonly) ConsentStringItem * consentStringItem;      //许可字符串

/**
 持有ConsentManager

 @return ConsentManager对象
 */
+ (ConsentManager *)shareInstance;

/**
 根据UI生成新的许可字符串

 @return consentString
 */
- (NSString *)makeNewConsentString:(ConsentStringSaveType)type;
@end

NS_ASSUME_NONNULL_END
