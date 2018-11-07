//
//  ConsentStringItem.m
//  GDPR
//
//  Created by unakayou on 11/2/18.
//  Copyright © 2018 unakayou. All rights reserved.
//

#import "ConsentStringItem.h"

@implementation ConsentStringItem
@synthesize valueString = _valueString;
@synthesize creatTime = _creatTime;
@synthesize version = _version;
@synthesize updateTime = _updateTime;

- (NSInteger)version
{
    NSString * binaryString = [ExtTool bitsFromConsentString:self.valueString location:VERSION_BIT_OFFSET length:VERSION_BIT_LENGTH];
    _version = [ExtTool decimalFromBinary:binaryString];
    return _version;
}

- (NSInteger)creatTime
{
    if (!_creatTime)
    {
        NSString * binaryString = [ExtTool bitsFromConsentString:self.valueString location:CREATED_BIT_OFFSET length:CREATED_BIT_LENGTH];
        _creatTime = [ExtTool decimalFromBinary:binaryString];
    }
    return _creatTime;
}

- (NSString *)valueString
{
    if (!_valueString)
    {
        _valueString = [[NSUserDefaults standardUserDefaults] objectForKey:CONSENTSTRING_SAVE_KEY];
    }
    return _valueString;
}

- (void)setValueString:(NSString *)valueString
{
    _valueString = valueString;
    [[NSUserDefaults standardUserDefaults] setObject:_valueString forKey:CONSENTSTRING_SAVE_KEY];
}

@end
