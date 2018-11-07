//
//  VendorItem.h
//  GDPR
//
//  Created by unakayou on 10/25/18.
//  Copyright © 2018 unakayou. All rights reserved.
//  供应商Model

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VendorItem : NSObject
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, strong) NSString * name;
@end

NS_ASSUME_NONNULL_END
