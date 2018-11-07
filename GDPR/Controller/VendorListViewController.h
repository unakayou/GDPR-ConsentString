//
//  VendorListViewController.h
//  GDPR
//
//  Created by unakayou on 10/23/18.
//  Copyright © 2018 unakayou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VendorListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView * vendorTableView;                    //供应商列表
@property (nonatomic, strong) NSArray <VendorItem *>* vendorListDataSource;     //供应商数据
@end

NS_ASSUME_NONNULL_END
