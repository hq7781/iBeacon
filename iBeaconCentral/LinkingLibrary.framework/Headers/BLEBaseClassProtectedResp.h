/**
 * Copyright © 2015-2016 NTT DOCOMO, INC. All Rights Reserved.
 */

#import "BLEBaseClassResp.h"

@class BLEDeviceSetting;

@interface BLEBaseClassResp()

@property (nonatomic,assign) int countParse;
@property (nonatomic,copy)   NSData *responseData;
@property (nonatomic,assign) char resultCode;
@property (nonatomic,assign) NSInteger allDataLength;
@property (nonatomic,strong) BLEDeviceSetting *findDevice;

/**
 データ初期化
 */
- (void)clear;

@end
