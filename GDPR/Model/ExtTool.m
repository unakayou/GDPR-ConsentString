//
//  ExtTool.m
//  GDPR
//
//  Created by unakayou on 10/30/18.
//  Copyright © 2018 unakayou. All rights reserved.
//

#import "ExtTool.h"

@implementation ExtTool

+ (NSString *)consentStringFromVendors:(NSArray <VendorItem *> *)vendorArray purposes:(NSArray <PurposeItem *> *)purposeArray
{
    NSString * consentBinaryString = [self finallConsentBinaryStringFromVendors:vendorArray purposes:purposeArray];
    NSString * consentString = [self consentStringFromConsentBinaryString:consentBinaryString];
    return consentString;
}

+ (NSString *)bitsFromConsentString:(NSString *)consentString location:(NSInteger)location length:(NSInteger)length
{
    if (consentString == nil) return nil;
    NSString * bitString = [self binaryStringFromBase64String:consentString];
    
    length = (length > 0) && (length < bitString.length - location) ? length : bitString.length - location;    //length纠错
    return [bitString substringWithRange:NSMakeRange(location, length)];
}

//参数转二进制许可字符串
+ (NSString *)finallConsentBinaryStringFromVendors:(NSArray <VendorItem *>*)vendorArray purposes:(NSArray <PurposeItem *> *)purposeArray
{
    ConsentManager * manager = [ConsentManager shareInstance];
    NSMutableArray * binaryArray = [NSMutableArray new];
    
    NSInteger creatTime = [[[ConsentManager shareInstance] consentStringItem] creatTime];
    creatTime = creatTime ? creatTime : [[NSDate date] timeIntervalSince1970];

    [binaryArray addObject:[self value:[self binaryFromDecimal:[ConsentManager shareInstance].consentStringItem.version + 1] needLength:VERSION_BIT_LENGTH]];
    [binaryArray addObject:[self value:[self binaryFromDecimal:creatTime] needLength:CREATED_BIT_LENGTH]];
    [binaryArray addObject:[self value:[self binaryFromDecimal:[[NSDate date] timeIntervalSince1970]] needLength:LAST_UPDATED_BIT_LENGTH]];
    [binaryArray addObject:[self value:[self binaryFromDecimal:7] needLength:CMP_ID_BIT_LENGTH]];
    [binaryArray addObject:[self value:[self binaryFromDecimal:1] needLength:CMP_VERSION_BIT_LENGTH]];
    [binaryArray addObject:[self value:[self binaryFromDecimal:3] needLength:CONSENT_SCREEN_BIT_LENGTH]];
    [binaryArray addObject:[self value:[self binaryFromLetters:@"EN"] needLength:CONSENT_LANGUAGE_BIT_LENGTH]];
    [binaryArray addObject:[self value:[self binaryFromDecimal:[manager vendroListVersion].integerValue] needLength:VENDOR_LIST_BIT_LENGTH]];
    [binaryArray addObject:[self value:[self PurposesAllowed:purposeArray] needLength:PURPOSES_ALLOWED_BIT_LENGTH]];
    [binaryArray addObject:[self value:[self binaryFromDecimal:vendorArray.lastObject.id] needLength:MAX_VENDOR_ID_BIT_LENGTH]];
    
    
    //bitField、bitRange 谁短要谁
    NSString * bitFieldStr = [self bitFieldFromVenderList:vendorArray];
    NSString * bitRangeStr = [self bitRangeFromVendorList:vendorArray];
    NSString * finalStr = bitFieldStr.length > bitRangeStr.length ? bitRangeStr : bitFieldStr;
    NSString * EncodingType = bitFieldStr.length > bitRangeStr.length ? @"1" : @"0";
    [binaryArray addObject:[self value:EncodingType needLength:ENCODING_BIT_LENGTH]];
    [binaryArray addObject:finalStr];
    
    //拼接返回字符串
    NSMutableString * retString = [[NSMutableString alloc] initWithCapacity:binaryArray.count];
    for (NSString * parameter in binaryArray)
    {
        [retString appendString:parameter];
    }
    
    //补满8位
    retString = (NSMutableString *)[self binaryValue8BitFormat:retString];
    
    return retString;
}

//二进制转许可字符串(base64编码后，结尾不包含=号)
+ (NSString *)consentStringFromConsentBinaryString:(NSString *)consentBinaryString
{
    NSString * consentString = [self base64StringFromBinaryString:consentBinaryString];
    consentString = [consentString stringByReplacingOccurrencesOfString:@"=" withString:@""];
    return consentString;
}

//二进制字符串转base64字符串
+ (NSString *)base64StringFromBinaryString:(NSString *)binaryString
{
    char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    //补0
    int fillCount = binaryString.length / 8 % 3;
    for (int i = 0; i < fillCount; i++)
    {
        binaryString = [NSString stringWithFormat:@"%@0",binaryString];
    }
    
    NSMutableString * retString = [[NSMutableString alloc] initWithCapacity:binaryString.length / 6];
    for (int i = 0; i < binaryString.length / 6; i++)
    {
        NSString * tmpBinaryString = [binaryString substringWithRange:NSMakeRange(i * 6, 6)];
        int letterNumber = (int)[self decimalFromBinary:tmpBinaryString];
        char tmpLetter = base64[letterNumber];
        [retString appendString:[NSString stringWithFormat:@"%c",tmpLetter]];
    }
    
    if (fillCount)
    {
        for (int i = 0; i < 3 - fillCount; i++)
        {
            [retString appendString:@"="];
        }
    }
    return retString;
}

//base64字符串转二进制
+ (NSString *)binaryStringFromBase64String:(NSString *)base64String
{
    NSMutableArray * binaryArray = [NSMutableArray new];

    
    char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    base64String = [base64String stringByReplacingOccurrencesOfString:@"=" withString:@""];

    for (int i = 0; i < base64String.length; i++)
    {
        NSString * letterString = [base64String substringWithRange:NSMakeRange(i, 1)];
        for (int j = 0; j < sizeof(base64) / sizeof(char) - 1; j++)
        {
            if ([letterString characterAtIndex:0] == base64[j])
            {
                [binaryArray addObject:[self binaryValue6BitFormat:[self binaryFromDecimal:j]]];
                break;
            }
        }
    }
    NSMutableString * retString = [NSMutableString new];
    for (NSString * parameter in binaryArray)
    {
        [retString appendString:parameter];
    }
    return retString;
}

//十进制转二进制
+ (NSString *)binaryFromDecimal:(NSInteger)decimal
{
    if (!decimal) return @"0";
    
    NSString * binary = @"";
    while (decimal)
    {
        binary = [[NSString stringWithFormat:@"%zd", decimal % 2] stringByAppendingString:binary];
        if (decimal / 2 < 1)
        {
            break;
        }
        decimal = decimal / 2;
    }
    return binary;
}

//二转十
+ (NSInteger)decimalFromBinary:(NSString *)binary
{
    NSInteger decimal = 0;
    for (int i = 0; i < binary.length; i++)
    {
        NSString * number = [binary substringWithRange:NSMakeRange(binary.length - i - 1, 1)];
        if ([number isEqualToString:@"1"])
        {
            decimal += pow(2, i);
        }
    }
    return decimal;
}

//二进制值占据多少位。不满足高位补0
+ (NSString *)value:(NSString *)valueString needLength:(NSInteger)needLength
{
    NSAssert(valueString.length <= needLength, @"数据长度错误:%@",valueString);
    
    NSMutableString * retString = [NSMutableString new];
    NSInteger needAddBits = needLength - valueString.length;
    for (int i = 0; i < needAddBits; i++)
    {
        [retString appendString:@"0"];
    }
    [retString appendString:valueString];
    return retString;
}

//语言示转二进制
+ (NSString *)binaryFromLetters:(NSString *)letters
{
    NSAssert(letters.length <= 2, @"数据长度错误:%@",letters);
    letters = letters.uppercaseString;
    char firstLetter = [letters characterAtIndex:0];
    char secondeLetter = [letters characterAtIndex:1];
    NSString * firstBinary = [self binaryValue6BitFormat:[self binaryFromDecimal:firstLetter - 65]];
    NSString * secondBinary = [self binaryValue6BitFormat:[self binaryFromDecimal:secondeLetter - 65]];
    return [NSString stringWithFormat:@"%@%@",firstBinary,secondBinary];
}

//PurposesAllowed参数之前的二进制值不是6位的整数倍的高位补0
+ (NSString *)binaryValue6BitFormat:(NSString *)valueString
{
    NSMutableString * retString = [NSMutableString new];
    NSInteger times = valueString.length % 6 ? 6 - valueString.length % 6 : 0;
    
    if (times)
    {
        for (int i = 0; i < times; i++)
        {
            [retString appendString:@"0"];
        }
        [retString appendString:valueString];
        return retString;
    }
    return valueString;
}

//字符串拼接完毕时，不够8位，末尾补0
+ (NSString *)binaryValue8BitFormat:(NSString *)valueString
{
    NSMutableString * retString = [NSMutableString new];
    
    NSInteger times = valueString.length % 8 ? 8 - valueString.length % 8 : 0;
    
    if (times)
    {
        [retString appendString:valueString];
        for (int i = 0; i < times; i++)
        {
            [retString appendString:@"0"];
        }
        return retString;
    }
    return valueString;
}

//转为6、8位的公倍数
+ (NSString *)suit8BitAnd6Bit:(NSString *)string
{
    NSMutableString * retString = [NSMutableString stringWithString:string];
    while (retString.length % 6 != 0 || retString.length % 8 != 0)
    {
        [retString appendString:@"0"];
    }
    return retString;
}

//purposeAllow 字段
+ (NSString *)PurposesAllowed:(NSArray <PurposeItem *> *)purposeArray
{
    NSMutableString * allowString = [[NSMutableString alloc] initWithCapacity:24];
    for (PurposeItem * item in purposeArray)
    {
        [allowString appendString:item.bActive ? @"1" : @"0"];
    }
    if (allowString.length < 24)
    {
        NSInteger times = 24 - allowString.length;
        for (int i = 0; i < times; i++)
        {
            [allowString appendString:@"0"];
        }
    }
    return allowString;
}

//将所有的vendory许可值做成bit字符串
+ (NSString *)bitFieldFromVenderList:(NSArray <VendorItem *>*)vendorArray
{
    NSMutableString * retString = [[NSMutableString alloc] initWithCapacity:vendorArray.count];
    for (VendorItem * item in vendorArray)
    {
        [retString appendString:item.selected ? @"1" : @"0"];
    }
    return retString;
}

//查找段落
+ (NSArray *)ranArrayFromVendorBitString:(NSString *)vendorBitString defaultBit:(NSString *)defaultbit
{
    NSString *carNumberPattern = [NSString stringWithFormat:@"%@%@*",defaultbit,defaultbit];
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:carNumberPattern options:NSRegularExpressionDotMatchesLineSeparators error:nil];
    NSArray *  retArray = [regex matchesInString:vendorBitString options:NSMatchingReportProgress range:NSMakeRange(0, vendorBitString.length)];
    return retArray;
}

+ (NSString *)bitRangeFromVendorList:(NSArray <VendorItem *>*)vendorArray
{
    //选择默认值
    int use1ForDefault = 1;
    for (VendorItem * item in vendorArray)
    {
        if (item.selected)
            use1ForDefault++;
        else
            use1ForDefault--;
    }
    //默认许可(保证与默认许可值相反的段落数量最少)
    BOOL DefaultConsent = use1ForDefault;
    //将所有供应商字段处理,按照许可划分段落
    NSArray * RangeEntryArray  = [self ranArrayFromVendorBitString:[self bitFieldFromVenderList:vendorArray] defaultBit:[NSString stringWithFormat:@"%d",!DefaultConsent]];
    NSMutableArray * parameterArray = [NSMutableArray new];
    [parameterArray addObject:[self value:[self binaryFromDecimal:DefaultConsent] needLength:DEFAULT_CONSENT_LENGTH]];
    [parameterArray addObject:[self value:[self binaryFromDecimal:RangeEntryArray.count] needLength:NUM_ENTRIES_BIT_LENGTH]];
    for (NSTextCheckingResult * result in RangeEntryArray)
    {
        NSRange range = result.range;
        [parameterArray addObject:[self value:[self binaryFromDecimal:range.length > 1] needLength:SINGLE_OR_RANGE]];    //SingleOrRange字段
        if (range.length > 1)
        {
            VendorItem * startItem = [vendorArray objectAtIndex:range.location];
            VendorItem * endItem = [vendorArray objectAtIndex:range.location + range.length - 1];
            [parameterArray addObject:[self value:[self binaryFromDecimal:startItem.id] needLength:START_VENDOR_ID_BIT_LENGTH]];
            [parameterArray addObject:[self value:[self binaryFromDecimal:endItem.id] needLength:END_VENDOR_ID_BIT_LENGTH]];
            NSLog(@"range: %@(%zd) - %@(%zd)",startItem.name,startItem.id,endItem.name,endItem.id);
        }
        else
        {
            VendorItem * item = [vendorArray objectAtIndex:range.location];
            [parameterArray addObject:[self value:[self binaryFromDecimal:item.id] needLength:START_VENDOR_ID_BIT_LENGTH]];
            NSLog(@"single: %@(%zd)",item.name,item.id);
        }
    }
    
    NSMutableString * retStrint = [NSMutableString new];
    for (NSString * str in parameterArray)
    {
        [retStrint appendString:str];
    }
    return retStrint;
}
@end
