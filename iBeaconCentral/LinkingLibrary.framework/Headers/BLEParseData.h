/**
 * Copyright © 2015-2016 NTT DOCOMO, INC. All Rights Reserved.
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBCentralManager.h>
#import <CoreBluetooth/CBPeripheral.h>

@interface BLEParseData : NSObject

typedef NS_ENUM(NSInteger, BLEAdvertisementDataServiceId) {
    BLEAdvertisementDataServiceIdGeneral             = 0,
    BLEAdvertisementDataServiceIdTemperature         = 1, // 温度
    BLEAdvertisementDataServiceIdHumidity            = 2, // 湿度
    BLEAdvertisementDataServiceIdAtmosphericPressure = 3, // 気圧
    BLEAdvertisementDataServiceIdBatteryPower        = 4, // 電池残量
    BLEAdvertisementDataServiceIdButtonId            = 5, // ボタン押下情報
    BLEAdvertisementDataServiceIdOpenSensor          = 6, // 開閉センサー
    BLEAdvertisementDataServiceIdHumanSensor         = 7, // 人感センサー
    BLEAdvertisementDataServiceIdVibrationSensor     = 8, // 振動センサー
    BLEAdvertisementDataServiceIdGeneral1            = 9, // 汎用1
    BLEAdvertisementDataServiceIdGeneral2            = 10,// 汎用2
    BLEAdvertisementDataServiceIdGeneral3            = 11,// 汎用3
    BLEAdvertisementDataServiceIdGeneral4            = 12,// 汎用4
    BLEAdvertisementDataServiceIdGeneral5            = 13,// 汎用5
    BLEAdvertisementDataServiceIdTimerCounter        = 14,// 同期タイマーカウンタ
    BLEAdvertisementDataServiceIdGeneralPurpose      = 15 // 汎用6
};

/**
 インスタンス取得、生成
 
 シングルトンデザインパターン。
 @param     なし
 @return    シングルトンのインスタンス
 */
+ (BLEParseData *)sharedInstance;

/**
 アドバタイズデータをパースするメソッド
 
 @param peripheral  受信したデバイスのペリフェラル
 @param advertisementData  アドバタイズデータ
 @param rssi        rssi値
 @param delegateArray  通知先のArray
 */
- (BOOL)parseAdvertisementDataWithPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)rssi  delegateArray:(NSMutableArray *)delegateArray ;

/**
 受信データを分解するメソッド
 
 @param peripheral  受信したデバイスのペリフェラル
 @param receiveData  受信データ
 @param delegateArray  通知先のArray
 */
- (void)dataConverter:(CBPeripheral *)peripheral receiveData:(NSData *)receiveData delegateArray:(NSMutableArray *)delegateArray;

@end
