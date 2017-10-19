/**
 * Copyright © 2015-2016 NTT DOCOMO, INC. All Rights Reserved.
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
#import "BLETimer.h"

static NSString * const DEV_STAT_CONNECTED    = @"CONNECTED";
static NSString * const DEV_STAT_DISCONNECTED = @"DISCONNECTED";
static NSUInteger const kNumberOfRSSIsForMeasuringBeaconMode  = 3;
static NSUInteger const kNumberOfRSSIsForMeasuringPairingMode = 20;

@class BLEDeviceSetting;

@protocol BLEDeviceSettingDelegate <NSObject>
@optional

/**
 距離調整APIの完了通知
 @param average 調整後の距離
 */
- (void)startCalibrationSuccessDelegate:(NSNumber *)average;

/**
 概算距離の計算の完了通知
 @param distanceInformation 概算距離
 */
- (void)calculatedDistanceSuccessDelegate:(NSNumber *)distanceInformation;

/**
 距離調整APIのエラー通知
 @param error エラー
 */
- (void)startCalibrationError:(NSError *)error;

@end

/**
 デバイス情報を管理するクラス
 @warninng 使用されないメソッドも記載
 */
extern NSTimeInterval const kReadRSSIInBackgroundStateInterval;
extern NSTimeInterval const kReadRSSIInForegroundStateInterval;
extern NSTimeInterval const kReconnectInBackgroundStateInterval;
extern NSTimeInterval const kReconnectInForegroundStateInterval;
extern NSTimeInterval const kReconnectInterval;

extern NSUInteger const kNumberOfRSSIsForMeasuring;
extern float const kAttenuationRate;

@interface BLEDeviceSetting : NSObject

/**
 *  BLEDeviceSettingDelegate インスタンス
 *  通知先のインスタンスが入ります。
 */
@property (nonatomic, weak) id<BLEDeviceSettingDelegate> delegateDeviceSetting;

// デバイス情報
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *connectionStatus;
@property (nonatomic, strong) CBCharacteristic *gCharacteristicWrite;
@property (nonatomic, strong) CBCharacteristic *gCharacteristicNotify;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;
@property (nonatomic, strong, readonly) NSNumber *estimatedDistance;
@property (nonatomic, strong) NSTimer *readingRSSITimer;
@property (nonatomic, getter=isUserSettingOFF) BOOL userSettingOFF;
@property (nonatomic, strong) NSTimer *reconnectTimer;
@property (nonatomic) float latestDistance;
@property (nonatomic) float distanceThreshold;
@property (nonatomic, getter=isInDistanceThreshold) BOOL inDistanceThreshold; // 現在値（current value）<= 閾値（threshold） ? YES : NO
@property (nonatomic) float kRSSIPerMeterBeaconMode;
@property (nonatomic) float kRSSIPerMeterPairingMode;
// 初回シーケンス中
@property (nonatomic, getter=isNotifyDeviceInitial) BOOL notifyDeviceInitial;

// 初回シーケンス完了
@property (nonatomic, getter=isInitialDeviceSettingFinished) BOOL initialDeviceSettingFinished;

//データ更新フラグ
@property (nonatomic, getter=isSaved) BOOL saved;

// PeripheralDevicePropertyInformationService
// ServiceList : サービス
@property (nonatomic, getter=isHasPeripheralDevicePropertyInformation) BOOL hasPeripheralDevicePropertyInformation;
@property (nonatomic, getter=isHasPeripheralDeviceNotification)        BOOL hasPeripheralDeviceNotification;
@property (nonatomic, getter=isHasPeripheralDeviceOperation)           BOOL hasPeripheralDeviceOperation;
@property (nonatomic, getter=isHasPeripheralDeviceSensorInformation)   BOOL hasPeripheralDeviceSensorInformation;
@property (nonatomic, getter=isHasPeripheralDeviceSettingOperation)    BOOL hasPeripheralDeviceSettingOperation;
@property (nonatomic, getter=isHasPeripheralDeviceServiceListReserved) BOOL hasPeripheralDeviceServiceListReserved;

// DeviceId : デバイスID(周辺機器の商品毎に固有)
// DeviceUid : デバイス固有ID(個々の機器に固有のID)
@property (nonatomic) unsigned short deviceId;
@property (nonatomic) unsigned int deviceUid;

// DeviceCapability : 機能
@property (nonatomic, getter=isHasLED)                                BOOL hasLED;
@property (nonatomic, getter=isHasGyroscope)                          BOOL hasGyroscope;
@property (nonatomic, getter=isHasAccelerometer)                      BOOL hasAccelerometer;
@property (nonatomic, getter=isHasOrientation)                        BOOL hasOrientation;
@property (nonatomic, getter=isHasPeripheralDeviceCapabilityReserved) BOOL hasPeripheralDeviceCapabilityReserved;
@property (nonatomic, getter=isHasBatteryPower)                       BOOL hasBatteryPower;
@property (nonatomic, getter=isHasTemperature)                        BOOL hasTemperature;
@property (nonatomic, getter=isHasHumidity)                           BOOL hasHumidity;
@property (nonatomic, getter=isHasAtmosphericPressure)                BOOL hasAtmosphericPressure;

// OriginalInformation : デバイス独自情報
@property (nonatomic,copy) NSMutableArray *originalInformation;

// ExSensorType : 拡張センサータイプ情報
@property (nonatomic,copy) NSData *exSensorType;
@property (nonatomic,copy) NSData *exSensorType2;
@property (nonatomic,copy) NSData *exSensorType3;
@property (nonatomic,copy) NSData *exSensorType4;
@property (nonatomic,assign, getter=isHasExVersionLowBit)   BOOL hasExVersionLowBit;
@property (nonatomic,assign, getter=isHasExVersionHighBit)  BOOL hasExVersionHighBit;
@property (nonatomic,assign, getter=isHasExNext)            BOOL hasExNext;
@property (nonatomic,assign, getter=isHasExButton)          BOOL hasExButton;
@property (nonatomic,assign, getter=isHasExOpen)            BOOL hasExOpen;
@property (nonatomic,assign, getter=isHasExHuman)           BOOL hasExHuman;
@property (nonatomic,assign, getter=isHasExReservedLowBit)  BOOL hasExReservedLowBit;
@property (nonatomic,assign, getter=isHasExReservedHighBit) BOOL hasExReservedHighBit;
@property (nonatomic,assign, getter=isHasExVersionLowBit2)  BOOL hasExVersionLowBit2;
@property (nonatomic,assign, getter=isHasExVersionHighBit2) BOOL hasExVersionHighBit2;
@property (nonatomic,assign, getter=isHasExNext2)           BOOL hasExNext2;
@property (nonatomic,assign, getter=isHasEx2Reserved3)      BOOL hasEx2Reserved3;
@property (nonatomic,assign, getter=isHasEx2Reserved4)      BOOL hasEx2Reserved4;
@property (nonatomic,assign, getter=isHasEx2Reserved5)      BOOL hasEx2Reserved5;
@property (nonatomic,assign, getter=isHasEx2Reserved6)      BOOL hasEx2Reserved6;
@property (nonatomic,assign, getter=isHasEx2Reserved7)      BOOL hasEx2Reserved7;
@property (nonatomic,assign, getter=isHasExVersionLowBit3)  BOOL hasExVersionLowBit3;
@property (nonatomic,assign, getter=isHasExVersionHighBit3) BOOL hasExVersionHighBit3;
@property (nonatomic,assign, getter=isHasExNext3)           BOOL hasExNext3;
@property (nonatomic,assign, getter=isHasEx3Reserved3)      BOOL hasEx3Reserved3;
@property (nonatomic,assign, getter=isHasEx3Reserved4)      BOOL hasEx3Reserved4;
@property (nonatomic,assign, getter=isHasEx3Reserved5)      BOOL hasEx3Reserved5;
@property (nonatomic,assign, getter=isHasEx3Reserved6)      BOOL hasEx3Reserved6;
@property (nonatomic,assign, getter=isHasEx3Reserved7)      BOOL hasEx3Reserved7;
@property (nonatomic,assign, getter=isHasExVersionLowBit4)  BOOL hasExVersionLowBit4;
@property (nonatomic,assign, getter=isHasExVersionHighBit4) BOOL hasExVersionHighBit4;
@property (nonatomic,assign, getter=isHasExNext4)           BOOL hasExNext4;
@property (nonatomic,assign, getter=isHasEx4Reserved3)      BOOL hasEx4Reserved3;
@property (nonatomic,assign, getter=isHasEx4Reserved4)      BOOL hasEx4Reserved4;
@property (nonatomic,assign, getter=isHasEx4Reserved5)      BOOL hasEx4Reserved5;
@property (nonatomic,assign, getter=isHasEx4Reserved6)      BOOL hasEx4Reserved6;
@property (nonatomic,assign, getter=isHasEx4Reserved7)      BOOL hasEx4Reserved7;
@property (nonatomic,assign) int exSensorCount;

//PeripheralDeviceNotification Service
@property (nonatomic, getter=isNotifyCategoryNotNotify)         BOOL notifyCategoryNotNotify;
@property (nonatomic, getter=isNotifyCategoryAll)               BOOL notifyCategoryAll;
@property (nonatomic, getter=isNotifyCategoryPhoneIncomingCall) BOOL notifyCategoryPhoneIncomingCall;
@property (nonatomic, getter=isNotifyCategoryPhoneInCall)       BOOL notifyCategoryPhoneInCall;
@property (nonatomic, getter=isNotifyCategoryPhoneIdle)         BOOL notifyCategoryPhoneIdle;
@property (nonatomic, getter=isNotifyCategoryMail)              BOOL notifyCategoryMail;
@property (nonatomic, getter=isNotifyCategorySchedule)          BOOL notifyCategorySchedule;
@property (nonatomic, getter=isNotifyCategoryGeneral)           BOOL notifyCategoryGeneral;
@property (nonatomic, getter=isNotifyCategoryEtc)               BOOL notifyCategoryEtc;

// GetAppVersion
@property (nonatomic,copy) NSDictionary *fileversion;

// SettingInformationData : 設定情報データ
@property (nonatomic,copy) NSMutableArray *settingInformationData;
@property (nonatomic,strong) NSMutableDictionary *settingInformationDataLED;
@property (nonatomic,strong) NSMutableDictionary *settingInformationDataVibration;
@property (nonatomic,strong) NSMutableDictionary *settingInformationDataNotificationDuration;
@property (nonatomic,strong) NSMutableDictionary *settingInformationDataNotifySound;

// SettingNameData : 設定名称データ
@property (nonatomic,copy) NSMutableArray *settingNameData;
@property (nonatomic,copy) NSMutableDictionary *lEDColorName;
@property (nonatomic,copy) NSMutableArray *lEDColorNameArray;
@property (nonatomic,copy) NSMutableDictionary *lEDPatternName;
@property (nonatomic,copy) NSMutableArray *lEDPatternArray;
@property (nonatomic,copy) NSMutableDictionary *vibrationPatternName;
@property (nonatomic,copy) NSMutableArray *vibrationPatternArray;
@property (nonatomic,copy) NSMutableDictionary *notifySoundPatternName;
@property (nonatomic,copy) NSMutableArray *notifySoundPatternArray;

@property (nonatomic,copy) NSMutableDictionary *notificationDurationName;
@property (nonatomic,copy) NSMutableArray *notificationDurationArray;
@property (nonatomic,copy) NSMutableDictionary *settingNameDataReserved;

typedef NS_ENUM(NSUInteger, SettingNameType) {
    LEDColorName           = 0x00,
    LEDPatternName         = 0x01,
    VibrationPatternName   = 0x02,
    NotifySoundPatternName = 0x03,
};

@property (nonatomic) SettingNameType settingNameType;

// センサー情報
@property (nonatomic) BLESensorGyroscope *gyroscope;
@property (nonatomic) BLESensorAccelerometer *accelerometer;
@property (nonatomic) BLESensorOrientation *orientation;
@property (nonatomic) BLESensorBatteryPower *batteryPower;
@property (nonatomic) BLESensorTemperature *temperature;
@property (nonatomic) BLESensorHumidity *humidity;
@property (nonatomic) BLESensorAtmosphericPressure *atmosphericPressure;

// タイマー
@property (nonatomic) BLETimer *sensorTimer;
@property (nonatomic) BLETimer *disconnectTimer;
@property (nonatomic) BLETimer *timeOutTimer;

@property (nonatomic, getter=isNotDisconnect) BOOL notDisconnect;

// Timer scan
@property (nonatomic) float scanTimer;
@property (nonatomic) float pauseScanTimer;

// タイマカウンタを使用した同期処理関連（アドバタイズ）
@property (nonatomic, getter=isEncryption) BOOL encryption; // アプリ独自暗号・復号化要不要
@property (nonatomic) NSInteger vendorIdentifier;           // ベンダ識別子
@property (nonatomic) NSInteger individualNumber;           // 個別番号
@property (nonatomic, getter=isSyncing) BOOL syncing;       // タイマーカウンタ0を受信済か(同期開始済か)
@property (nonatomic) NSDate* syncStartTime;                // 同期開始時間(ライブラリ参照用(サービスアプリでは使用しない))
@property (nonatomic) NSInteger syncStartCounter;           // 同期開始時のタイマカウンタ値(ライブラリ参照用(サービスアプリでは使用しない))
@property (nonatomic, getter=isFirstSyncDataRecv) BOOL firstSyncDataRecv; // 同期開始後、1～2046のタイマカウンタを一度でも受信済みか(ライブラリ参照用(サービスアプリでは使用しない))
@property (nonatomic) NSDate* receivedTime;                 // データ受信時間(ライブラリ参照用(サービスアプリでは使用しない))
@property (nonatomic) NSInteger receivedCounter;            // データ受信時のタイマカウンタ値(ライブラリ参照用(サービスアプリでは使用しない))

// 受信データ（アドバタイズ）
@property (nonatomic) float scanBatteryPower;           // 電池残量
@property (nonatomic) float scanTemperature;            // 温度
@property (nonatomic) float scanHumidity;               // 湿度
@property (nonatomic) float scanAtmosphericPressure;    // 気圧
@property (nonatomic) float scanButtonPush;             // ボタン押下情報
@property (nonatomic) NSInteger scanHuman;              // 人感センサー
@property (nonatomic) NSInteger scanOpen;               // 開閉センサー
@property (nonatomic) NSInteger scanVibration;          // 振動センサー
@property (nonatomic) NSInteger scanGeneral1;           // 汎用1
@property (nonatomic) NSInteger scanGeneral2;           // 汎用2
@property (nonatomic) NSInteger scanGeneral3;           // 汎用3
@property (nonatomic) NSInteger scanGeneral4;           // 汎用4
@property (nonatomic) NSInteger scanGeneral5;           // 汎用5
@property (nonatomic) NSInteger scanGeneral6;           // 汎用6
@property (nonatomic) NSData*   scanRawData;            // 受信生データ(isEncryption:YES時のみ)

/**
 RSSIより概算距離を算出するメソッド
 
 @param RSSI 受信したRSSiの値
 @param TxPowerLevel 受信したtxPowerLebelの値
 */
- (void)updateEstimatedDistanceWithRSSIValue:(NSNumber *)RSSI TxPowerLevel:(float)txPowerLvl;

/**
 概算距離をリセットするメソッド
 */
- (void)resetEstimatedDistance;

/**
 平均距離返却
 
 @return    平均距離を返却
 */
- (NSNumber *)calculateEstimatedAve1;

/**
 rssi平均値算出メソッド
 
 @param    rssiValues RSSIのArray
 */
- (void)calculateEstimatedRSSIAverage:(NSMutableArray *)rssiValues;

/**
 閾値設定
 
 @param    distanceThreshold 閾値
 */
- (void)setDistanceThreshold:(float)distanceThreshold;

/**
　アドバタイズ時の受信データをクリア
 */
- (void)clearScanData;

@end
