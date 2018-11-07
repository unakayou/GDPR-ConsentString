//
//  ConsentManager.m
//  GDPR
//
//  Created by unakayou on 10/25/18.
//  Copyright © 2018 unakayou. All rights reserved.
//

#import "ConsentManager.h"

@interface ConsentManager()
@property (nonatomic, strong) NSDictionary * jsonDict;  //VendorList.json
@end

@implementation ConsentManager
@synthesize vendorArray = _vendorArray;
@synthesize purposeItemArray = _purposeItemArray;
@synthesize consentStringItem = _consentStringItem;

+ (ConsentManager *)shareInstance
{
    static ConsentManager * networkStatuskManager;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^
                  {
                      networkStatuskManager = [[[self class] alloc] init];
                  });
    return networkStatuskManager;
}

- (NSString *)makeNewConsentString:(ConsentStringSaveType)type
{
    switch (type)
    {
        case ConsentStringSave_Purpose:
            self.consentStringItem.valueString = [ExtTool consentStringFromVendors:self.vendorArray purposes:_purposeItemArray];
            break;
        case ConsentStringSave_Vendor:
            self.consentStringItem.valueString = [ExtTool consentStringFromVendors:_vendorArray purposes:self.purposeItemArray];
            break;
        case ConsentStringSave_All:
            self.consentStringItem.valueString = [ExtTool consentStringFromVendors:_vendorArray ? _vendorArray : self.vendorArray purposes:_purposeItemArray ? _purposeItemArray : self.purposeItemArray];
            break;
        default:
            break;
    }
    return self.consentStringItem.valueString;
}

- (ConsentStringItem *)consentStringItem
{
    if (!_consentStringItem)
    {
        _consentStringItem = [[ConsentStringItem alloc] init];
    }
    return _consentStringItem;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.jsonDict = [self readLocalFileWithName:@"VendorList"];
    }
    return self;
}

- (NSString *)vendroListVersion
{
    return [self.jsonDict objectForKey:@"vendorListVersion"];
}

//从consentString重新获取purpose设置
- (NSArray<PurposeItem *> *)purposeItemArray
{
    NSString * purposeBitString = [ExtTool bitsFromConsentString:_consentStringItem.valueString location:PURPOSES_ALLOWED_BIT_OFFSET length:PURPOSES_ALLOWED_BIT_LENGTH];
    NSArray * purpose = [self sortModelInArray:[self.jsonDict objectForKey:@"purposes"]];
    NSMutableArray * retArray = [[NSMutableArray alloc] initWithCapacity:purpose.count];
    for (int i = 0; i < purpose.count; i++)
    {
        PurposeItem * purposeItem = [[PurposeItem alloc] init];
        purposeItem.id = [purpose[i][@"id"] integerValue];
        purposeItem.name = purpose[i][@"name"];
        purposeItem.bActive = purposeBitString ? [[purposeBitString substringWithRange:NSMakeRange(i, 1)] boolValue] : YES;
        [retArray addObject:purposeItem];
        _purposeItemArray = retArray;
    }
    return _purposeItemArray;
}

//从consentString重新获取vendor设置
- (NSArray<VendorItem *> *)vendorArray
{
    NSString * consentString = _consentStringItem.valueString;

    NSString * EncodingType = [ExtTool bitsFromConsentString:consentString location:ENCODING_TYPE_BIT length:ENCODING_BIT_LENGTH];
    NSMutableArray * retArray = [NSMutableArray new];
    NSArray * vendors = [self sortModelInArray:[self.jsonDict objectForKey:@"vendors"]];

    if (consentString == nil)
    {
        for (int i = 0; i < vendors.count; i++)
        {
            VendorItem * item = [[VendorItem alloc] init];
            item.id = [vendors[i][@"id"] integerValue];
            item.name = vendors[i][@"name"];
            item.selected = YES;
            [retArray addObject:item];
        }
    }
    else if (EncodingType.intValue == 0) //bitField
    {
        NSString * vendorBitString = [ExtTool bitsFromConsentString:consentString location:BIT_FIELD_BIT_OFFSET length:BIT_FIELD_BIT_LENGTH];
        for (int i = 0; i < vendors.count; i++)
        {
            VendorItem * item = [[VendorItem alloc] init];
            item.id = [vendors[i][@"id"] integerValue];
            item.name = vendors[i][@"name"];
            item.selected = vendorBitString ? [[vendorBitString substringWithRange:NSMakeRange(i, 1)] boolValue] : YES;
            [retArray addObject:item];
        }
    }
    else    //bitRange
    {
        NSString * DefaultConsent = [ExtTool bitsFromConsentString:consentString location:DEFAULT_CONSENT_BIT length:DEFAULT_CONSENT_LENGTH];
        NSString * NumEntries = [ExtTool bitsFromConsentString:consentString location:NUM_ENTRIES_BIT_OFFSET length:NUM_ENTRIES_BIT_LENGTH];
        NSInteger NumEntriesInt = [ExtTool decimalFromBinary:NumEntries];
        
        for (int i = 0; i < vendors.count; i++)
        {
            VendorItem * item = [[VendorItem alloc] init];
            item.id = [vendors[i][@"id"] integerValue];
            item.name = vendors[i][@"name"];
            item.selected = DefaultConsent.boolValue;
            [retArray addObject:item];
        }
        
        NSInteger SigleOrRange_Bit_Offset = NUM_ENTRIES_BIT_OFFSET + NUM_ENTRIES_BIT_LENGTH;
        for (int i = 0; i < NumEntriesInt; i++)
        {
            NSString * SingleOrRange = [ExtTool bitsFromConsentString:consentString location:SigleOrRange_Bit_Offset length:SINGLE_OR_RANGE];
            if (SingleOrRange.integerValue == 0)    //Single
            {
                NSString * singleVendorId = [ExtTool bitsFromConsentString:consentString location:SigleOrRange_Bit_Offset + 1 length:SINGLE_VENDOR_ID_BIT_LENGTH];
                NSInteger vendorId = [ExtTool decimalFromBinary:singleVendorId];
                for (VendorItem * item in retArray)
                {
                    if (item.id == vendorId)
                    {
                        item.selected = !DefaultConsent.boolValue;
                        break;
                    }
                }
                SigleOrRange_Bit_Offset += SINGLE_VENDOR_ID_BIT_LENGTH + 1;
            }
            else
            {
                NSString * StartVendorId = [ExtTool bitsFromConsentString:consentString location:SigleOrRange_Bit_Offset + 1 length:START_VENDOR_ID_BIT_LENGTH];
                NSString * EndVendorId = [ExtTool bitsFromConsentString:consentString location:SigleOrRange_Bit_Offset + START_VENDOR_ID_BIT_LENGTH + 1  length:END_VENDOR_ID_BIT_LENGTH];
                
                NSInteger startVendorId = [ExtTool decimalFromBinary:StartVendorId];
                NSInteger endVendorId = [ExtTool decimalFromBinary:EndVendorId];
                for (VendorItem * item in retArray)
                {
                    if (item.id >= startVendorId && item.id <= endVendorId)
                    {
                        item.selected = !DefaultConsent.boolValue;
                    }
                }
                SigleOrRange_Bit_Offset += (START_VENDOR_ID_BIT_LENGTH + END_VENDOR_ID_BIT_LENGTH + 1);
            }
        }
    }
    _vendorArray = retArray;
    return _vendorArray;
}

- (NSArray *)sortModelInArray:(NSMutableArray *)array
{
    NSSortDescriptor * idSD = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];    //ascending:YES 代表升序 如果为NO 代表降序
    NSArray * retArray = [array sortedArrayUsingDescriptors:@[idSD]];
    return retArray;
}

- (void)setPurposeItemArray:(NSArray<PurposeItem *> *)purposeItemArray
{
    _purposeItemArray = purposeItemArray;
}

- (NSDictionary *)readLocalFileWithName:(NSString *)name
{
    NSString * path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData * data = [[NSData alloc] initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}
@end
