//
//  ConsentConstant.h
//  GDPR
//

#ifndef CMPConsentConstant_h
#define CMPConsentConstant_h

//版本位
static int VERSION_BIT_OFFSET = 0;
static int VERSION_BIT_LENGTH = 6;

//创建时间位
static int CREATED_BIT_OFFSET = 6;
static int CREATED_BIT_LENGTH = 36;

//最后更新时间位
static int LAST_UPDATED_BIT_OFFSET = 42;
static int LAST_UPDATED_BIT_LENGTH = 36;

//Consent Manager Provider ID 位
static int CMP_ID_BIT_OFFSET = 78;
static int CMP_ID_BIT_LENGTH = 12;

//CMP版本位
static int CMP_VERSION_BIT_OFFSET = 90;
static int CMP_VERSION_BIT_LENGTH = 12;

//ConsentScreen位
static int CONSENT_SCREEN_BIT_OFFSET = 102;
static int CONSENT_SCREEN_BIT_LENGTH = 6;

//语言位 - "EN"
static int CONSENT_LANGUAGE_BIT_OFFSET = 108;
static int CONSENT_LANGUAGE_BIT_LENGTH = 12;

//供应商列表版本位
static int VENDOR_LIST_BIT_OFFSET = 120;
static int VENDOR_LIST_BIT_LENGTH = 12;

//权限许可位 一个purpose占一位
static int PURPOSES_ALLOWED_BIT_OFFSET = 132;
static int PURPOSES_ALLOWED_BIT_LENGTH = 24;

//最大供应商ID位
static int MAX_VENDOR_ID_BIT_OFFSET = 156;
static int MAX_VENDOR_ID_BIT_LENGTH = 16;

//编码类型 0 = BitField; 1 = Range
static int ENCODING_TYPE_BIT = 172;
static int ENCODING_BIT_LENGTH = 1;

//一个供应商占1位。0 = 未许可; 1 = 许可。分别表示各个供应商是否获得许可 173....N
static int BIT_FIELD_BIT_OFFSET = 173;
static int BIT_FIELD_BIT_LENGTH = INT_MAX;

//默认许可值的位
static int DEFAULT_CONSENT_BIT = 173;
static int DEFAULT_CONSENT_LENGTH = 1;

//要遵从的条目数
static int NUM_ENTRIES_BIT_OFFSET = 174;
static int NUM_ENTRIES_BIT_LENGTH = 12;

//0 = 单个VendorId，1 = 一系列VendorIds
static int SINGLE_OR_RANGE = 1;

//一个单独的VendorId
static int SINGLE_VENDOR_ID_BIT_LENGTH = 16;

//VendorIds的起始
static int START_VENDOR_ID_BIT_LENGTH = 16;

//VendorIds的结尾
static int END_VENDOR_ID_BIT_LENGTH = 16;

#endif /* CMPConsentConstant_h */
