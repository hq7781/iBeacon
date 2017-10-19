/**
 * Copyright © 2015-2016 NTT DOCOMO, INC. All Rights Reserved.
 */

#import <CoreBluetooth/CBPeripheral.h>

@class BLEDeviceSetting;

/**
 ペリフェラル情報のデータクラス
 */
@interface BLEPeripheralDataManager : NSObject

@property (nonatomic, strong) NSMutableArray *deviceArray;

@property (nonatomic, copy)   NSArray<CBUUID*> *serviceUUID;
@property (nonatomic, copy)   NSString *characteristicWriteUUID;
@property (nonatomic, copy)   NSString *characteristicIndicateUUID;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, copy)   NSDictionary *advertisementData;
@property (nonatomic, strong) NSNumber *RSSI;
@property (nonatomic, strong) NSMutableArray *scanResultArray;

/**
 deviceArrayの情報を更新する
 */
- (BOOL)updateDevice;

/**
 BLEDeviceSettingを返却する
 
 @param peripherals 返却するBLEDeviceSettingのperipheral
 @return BLEDeviceSetting
 */
- (BLEDeviceSetting *)getDeviceWithPeripheral:(CBPeripheral *)peripherals;

/**
 保存されていたdeviceArrayの情報を読み込む
 */
- (void)loadDevices;

/**
 インスタンス取得、生成
 
 シングルトンデザインパターン。
 @param     なし
 @return    シングルトンのインスタンス
 */
+ (BLEPeripheralDataManager *)sharedManager;

/**
 サービスUUIDの設定、更新
 
 @param     UUID(NSstring)の配列
*/
- (void)setServiceUUIDWithStringArray:(NSArray<NSString*>*)uuidStringArray;

/**
 サービスUUIDの存在確認
 
 @param     CBUUID
 @return    存在するならYES
 */
- (BOOL)isExistCBUUID:(CBUUID*)uuid;

@end
