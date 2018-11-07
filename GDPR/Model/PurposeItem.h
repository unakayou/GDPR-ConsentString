//
//  PurposeItem.h
//  GDPR
//
//  Created by unakayou on 10/25/18.
//  Copyright © 2018 unakayou. All rights reserved.
//  权限Model

#import <Foundation/Foundation.h>
#import "VendorItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface PurposeItem : NSObject
@property (nonatomic, assign) BOOL bActive;     //是否允许此权限
@property (nonatomic, assign) NSInteger id;     //ID
@property (nonatomic, strong) NSString * name;  //名称
@end

NS_ASSUME_NONNULL_END
