/**
 * Copyright © 2015-2016 NTT DOCOMO, INC. All Rights Reserved.
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBCentralManager.h>
#import <CoreBluetooth/CBPeripheral.h>
#import "BLEDeviceNotificationService.h"
#import "BLEDelegateModel.h"
#import "BLEGetDeviceInformationResp.h"
#import "BLENotifyPdGeneralInformation.h"
#import "BLECommonConsts.h"
#import "BLEStartPdApplication.h"

/**
 CoreBluetooth機能を管理するクラス
 */

@class BLEConnecter;

@protocol BLEConnecterDelegate <NSObject>
@optional

@end

@interface BLEConnecter : NSObject
<
CBCentralManagerDelegate
,CBPeripheralDelegate
>

typedef NS_ENUM(NSInteger, BLEScanIntervalType) {
    BLEScanHighAccurate = 0,
    BLEScanNormalAccurate = 1,
    BLEScanSavingPower = 2
};

/**
 BLEConnecterDelegate インスタンス
 通知先のインスタンスが入ります。
 */
@property (nonatomic, weak) id<BLEConnecterDelegate> delegateBLEConnecter;

/**
 BLEConnecterDelegate インスタンス
 通知先のインスタンスが入ります。
 */
@property (nonatomic, weak) id<BLEDelegateModelDelegate> delegate;

/**
 BLEConnecterDelegate インスタンス
 通知先のインスタンスが入ります。
 */
@property (nonatomic, weak) id<BLEDelegateModelDelegate> timerDelegate;
@property (strong,nonatomic)CBPeripheral *targetPeripheral;

@property (nonatomic) float disconnectTime;
@property (nonatomic) float timeOutTime;
@property (nonatomic, readonly, getter=isSetLED) BOOL setLED;
@property (nonatomic) float threshold;
@property (nonatomic) BLEDeviceSetting *device;
@property (nonatomic) BLEDeviceSetting *deviceCalib;
@property (nonatomic, getter=isSendCancelFlg) BOOL sendCancelFlg;
@property (nonatomic) Byte serviceID;
@property (nonatomic) unsigned short messageId;
@property (nonatomic, readonly, getter=isCanDiscovery) BOOL canDiscovery;
@property (nonatomic, getter=isCalibrating) BOOL calibrating;
@property (nonatomic, strong) NSMutableArray *rssiArrayForCalib;
@property (nonatomic, getter=isBluetoothAvailable) BOOL bluetoothAvailable;
@property (nonatomic, getter=isSequenceOver) BOOL sequenceOver;
@property (nonatomic, strong) NSMutableArray *payloadArray;

/**
 インスタンス取得、生成
 
 シングルトンデザインパターン。
 @param     なし
 @return    シングルトンのインスタンス
 */
+ (BLEConnecter *)sharedInstance;

/**
 BLEDeviceSettingを返却する
 @param peripherals 返却するBLEDeviceSettingのperipheral
 @return BLEDeviceSetting
 */
- (BLEDeviceSetting *)getDeviceByPeripheral:(CBPeripheral *)pPeripheral;

/**
 デバイス検索を行う
 */
- (void)scanDevice;

/**
 接続済みデバイスを含めたデバイス検索を行う
 
 @param isRetrieveConnectedPeripherals  YESの場合は接続済みデバイス情報を検索結果に含める
 */
- (void)scanDevice:(BOOL)isRetrieveConnectedPeripherals;

/**
 アドバタイズの検出を開始する
 */
- (void)startPartialScanDevice;

/**
 デバイス検索を行う
 
 @param serviceUUIDs  サービスのUUID
 @param writeUUIDs    キャラクタリスティクスWriteのUUID
 @param indicateUUIDs キャラクタリスティクスIndicateのUUID
 */
- (void)scanDevice:(NSArray<NSString*> *)serviceUUIDs writeUUIDs:(NSString *)writeUUIDs indicateUUIDs:(NSString *)indicateUUIDs;

/**
 デバイス検索を停止する
 */
- (void)stopScan;

/**
 アドバタイズの検出を停止する
 */
- (void)stopPartialScanDevice;

/**
 スキャン状況を返却する
 @return YES = 検索中 NO = 検索を行っていない
 */
//- (BOOL)isScanning;

/**
 デバイス接続
 
 @param peripheral 接続するデバイスのペリフェラル
 */
- (void)connectDevice:(CBPeripheral *)peripheral;

/**
 デバイスの切断
 
 @param uuidOfPeripheral 接続するデバイスのUUID
 */
- (void)disconnectByDeviceUUID:(NSString *)uuidOfPeripheral;

/**
 すべてのデバイスの切断
 */
- (void)disconnectAll;

/**
 Linkingデバイスへメッセージ送信を行う
 
 @param data 送信するデータ
 @param peripheral 送信するデバイスのperipheral
 @param characteristic キャラクタリスティック
 @param disconnect YESの場合は即時切断、NOの場合は一定間隔をおいて切断する(disconnectTimeが0の場合は切断されない)
 */
- (void)sendRequestWithData:(NSData *)data
                peripheral:(CBPeripheral *)peripheral
            characteristic:(CBCharacteristic *)characteristic
                disconnect:(BOOL)disconnect;

/**
 Linkingデバイスへ分割メッセージ送信を行う
 
 @param data 送信するデータ
 @param deviceId 送信するデバイスのdeviceId
 @param deviceUId 送信するデバイスのdeviceUId
 @param peripheral 送信するデバイスのperipheral
 @param disconnect YESの場合は即時切断、NOの場合は一定間隔をおいて切断する(disconnectTimeが0の場合は切断されない)
 */
- (void)sendRequestWithMultiData:(NSMutableArray *)multiData
                        deviceId:(unsigned short)deviceId
                       deviceUId:(NSMutableArray *)deviceUId
                      peripheral:(CBPeripheral *)peripheral
                      disconnect:(BOOL)disconnect;

/**
 デリゲートの登録を行う
 
 @param delegate デリゲートを登録
 @param deviceUUID デリゲートを登録するデバイスのUUID
 */
- (void)addListener:(id<BLEDelegateModelDelegate>)delegate deviceUUID:(NSString *)deviceUUID;

/**
 デリゲートの削除を行う
 
 @param delegate デリゲートを削除
 @param deviceUUID デリゲートを削除するデバイスのUUID
 */
- (void)removeListener:(id<BLEDelegateModelDelegate>)delegate deviceUUID:(NSString *)deviceUUID;

/**
 タイマーのデリゲートの登録を行う
 
 @param delegate デリゲートを登録
 @param deviceUUID デリゲートを登録するデバイスのUUID
 */
- (void)addTimerListener:(id<BLEDelegateModelDelegate>)delegate deviceUUID:(NSString *)deviceUUID;

/**
 デバイス情報取得シーケンス完了メソッド

 @param peripheral 情報を更新したデバイスのペリフェラル
 @param isFirst YES = 初回シーケンス　NO = 初回ではない
 */
- (void)notifyDeviceInitialFinish:(CBPeripheral *)peripheral firstInitial:(BOOL)isFirst;

/**
 キャリブレーション開始メソッド
 @param formType 指定タイプ
 @param device デバイスの設定情報クラスのインスタンス
 */
- (void)startCalibration:(NSUInteger)formType device:(BLEDeviceSetting *)device;

/**
 キャリブレーション停止メソッド
 */
- (void)stopCalibration;

/**
 ビーコンスキャン間隔変更メソッド
 @param scanIntervalType スキャン間隔タイプ
 */
- (void)changePartialScanInterval:(BLEScanIntervalType)scanIntervalType;

@end
