# GDPR-ConsentString
Like smatto GDPR demo.Make ConsentString from Purposes and Vendors.

#### 供应商许可字符串格式

> 以下字段以高位优先格式存储。下面提供了示例，bits是左对齐。

|Vendor Consent String Field Name|Number of bits (bit offsets)|Value(s)|Notes|
|----|----|----|----|
|Version|6 bits (0-5)|"1" for this version|版本随许可字符串改变增加|
|Created|36 bits (6-41)|许可字符串首次创建的Deciseconds|Deciseconds FITS放入36位，有足够的精度记录用户许可行为的时间。Javascript: Math.round((new Date()).getTime()/100)|
|LastUpdated|36 bits (42-77)|许可字符串最后一次更新时间的Deciseconds|----|
|CmpId|12 bits (78-89)|上次更新许可字符串的Consent Manager Provider ID|每个Consent Manager Provider有唯一ID|
|CmpVersion|12 bits (90-101)|Consent Manager Provider version版本|对CMP的每次更改都应收到一个新的版本号，用于记录许可证明|
|ConsentScreen|6 bits (102-107)|CMP中已经许可的screen number|screen number是CMP和CmpVersion确定的，是记录许可的凭证|
|ConsentLanguage|12 bits (108-119)|CMP请求许可的两个字母的ISO639-1 language code|每个字母编码成6位，A = 0...Z = 25。这样可以让base64url-encoded bytes拼写出language code(大写的)|
|VendorListVersion|12 bits (120-131)|大多数最近更新的许可字符串中使用的供应商列表版本|供应商列表将定期更新，12位可以容纳每周更新一次，更新78年。|
|PurposesAllowed|24 bits (132-155)|对于每个```Purpose```,1个bit 未许可 = 0，许可 = 1|```Purposes```被列在全球供应商列表中。因而在这个范围适当的bits上产生许可值是 “AND”，以及 一个 供应商的特有的bits。``` Purpose #1```映射到第一个bit上(最高有效bit)，```purpose #24```映射到最后一个bit上(最低有效bit)。|
|⬆️|⬆️|⬆️|以上这些字段是6位的倍数，以适应Base64 URL编码的字节。|
|MaxVendorId|16 bits (156-171)|许可值给出的最大``` VendorId ```|```VendorIds```编号为1到```MaxVendorId```。允许解释许可字符串，而无需等待获取供应商列表。|
|EncodingType|1 bit (172)|0=BitField 1=Range|使用许可编码类型。要么是```BitFieldSection```要么是```RangeSection```，许可字符串编码逻辑应该选择编码后字符串长度较短的编码。|
|BitFieldSection|||每个```VendorId```编码成一个许可bit。|
|BitField|MaxVendorId bits (173-...)|每个供应商，占一个bit: 0 = 未许可，1 = 许可。|每个VendorId的许可值，从```1``` - ```MaxVendorId```|
|RangeSection|||单个或者范围覆盖条目，编码一个默认许可值和任意数字|
|DefaultConsent|1 bit (173)|0 = 未许可，1 = 许可|默认的```VendorIds```许可,没有被```RangeEntry```覆盖。被```RangeEntry```覆盖的```VendorIds```有一个与DefaultConsent相反的许可值。(比如:DefaultConsent = 1,所以Range[N][M] = 0,Range里所有的许可值都与默认值相反)|
|NumEntries|12 bits (174-185)|入口数量|NumEntries instances of RangeEntry follow.|
|RangeEntry (repeated NumEntries times, indicated by [idx])|----|----|单个或若干```VendorIds```其许可值与DefaultConsent相反。所有```VendorIds```必须介于```1```和```MaxVendorId```之间。|
|SingleOrRange[idx]	|1 bit|0 = 单个```VendorId```，1 = 一系列```VendorIds```|下一个与默认值不同的Range是单个```VendorId```或若干个```VendorIds```的开始/结束范围|
|SingleVendorId[idx]|16 bits|一个单独的```VendorId```|唯一的```Start / EndVendorId```|
|StartVendorId[idx]|16bits|包含```VendorIds```的范围的起始。|SingleVendorId是唯一的。必须与EndVendorId配对|
|EndVendorId[idx]|16 bits|包含```VendorIds```的范围的结尾|```SingleVendorId```唯一。 必须与```StartVendorId```配对。|

> 个人理解:

- 假设用户许可了id = 1,2,3,10,12,13,14,15的供应商.
- EncodingType(第172位)肯定选择 = 1才能使得最后的string最短。
- 因为在第173位上的DefaultConsent，1代表许可，0代表不许可，且DefaultConsent应该选择遵从多数，以便让段落NumEntries数量最少，所以DefaultConsent = 0。
- 这样，段落为{1,3},{10},{12,15},总数3个。
- bit(172) = 1, bit(173) = 0, bit(174 - 256) =
- 100000000000000010000000000000011(代表{1,3}) 
- 00000000000001010(代表{10}，因为是单独一个vendorid，所以最高位是0)
- 100000000000011000000000000001111(代表{12,15})
- 最终10000000000000001000000000000001100000000000001010100000000000011000000000000001111,然后与前面的bit都拼接到一起。最后左base64编码。

#### 供应商许可字符串例子:
> 案例的示例许可字符串字段值：
- 给出所有```VendorIds```的许可，除了```VendorId``` = ```9```
- 采用```VendorListVersion``` = ```8```版本，内部定义了2011个```VendorIds```
- ```Consent Manager Provider Id```采用```#7```

|Field|Decimal Value|Meaning|Binary Value|
|----|----|----|----|
|Version|1|Consent String Format Version #1|000001|
|Created|15100821554|2017-11-07T19:15:55.4Z|001110000100000101000100000000110010|
|LastUpdated|15100821554|2017-11-07T19:15:55.4Z|001110000100000101000100000000110010|
|CmpId|7|The ID assigned to the CMP|000000000111|
|CmpVersion|1|Consent Manager Provider version for logging|000000000001|
|ConsentScreen|3|Screen number in the CMP where consent was given|000011|
|ConsentLanguage|"EN" (E=4, N=13)|Two-letter ISO639-1 language code that CMP asked for consent in|000100 001101|
|VendorListVersion|8|The vendor list version at the time this consent string value was set|000000001000|
|PurposesAllowed|14680064|Purposes #1, 2, and 3 are allowed|111000000000000000000000|
|MaxVendorId|2011|Number of VendorIds in that vendor list|0000011111011011|
|EncodingType|1|Range encoding (not bitfield)|1|
|DefaultConsent|1|Default is "Consent"|1|
|NumEntries|1|One "range or single" entry|000000000001|
|SingleOrRange[0]|0|A single VendorId (which is "No Consent")|0|
|SingleVendorId[0]|9|VendorId=9 has No Consent (opposite of Default Consent)|0000000000001001|
|fillbits||The binary bits should be padded at the end with zeroes to the nearest multiple of 8 bits|00000|

#### 把cookie值范围的bits连接起来:

> 前面显示的示例的完整的面向字节的许可字符串表示形式为：

```
00000100 11100001 00000101 00010000 00001100 10001110
00010000 01010001 00000000 11001000 00000001 11000000
00000100 00110001 00001101 00000000 10001110 00000000
00000000 00000000 01111101 10111100 00000000 01000000
00000001 00100000 
```

#### 构建Base64描述:

> 此字符串是使用前面描述的串联Cookie值字段位的base64url编码表示构建的。 注意：应省略填充'='字符。

> 此示例的计算值为：

```
BOEFEAyOEFEAyAHABDENAI4AAAB9vABAASA
```
