//
//  VendorTableViewCell.m
//  GDPR
//
//  Created by unakayou on 10/24/18.
//  Copyright © 2018 unakayou. All rights reserved.
//

#import "VendorTableViewCell.h"

@implementation VendorTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return self;
}
@end
