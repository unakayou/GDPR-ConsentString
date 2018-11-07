//
//  ConsentStringItem.h
//  GDPR
//
//  Created by unakayou on 11/2/18.
//  Copyright © 2018 unakayou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConsentStringItem : NSObject
@property (nonatomic, assign) NSInteger version;        //许可字符串版本
@property (nonatomic, assign) NSInteger creatTime;      //创建时间
@property (nonatomic, assign) NSInteger updateTime;     //更新时间
@property (nonatomic, strong) NSString * valueString;   //许可字符串值
@end

NS_ASSUME_NONNULL_END
