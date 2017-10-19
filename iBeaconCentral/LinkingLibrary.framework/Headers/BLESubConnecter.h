/**
 * Copyright © 2015-2016 NTT DOCOMO, INC. All Rights Reserved.
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBCentralManager.h>
#import <CoreBluetooth/CBPeripheral.h>

@interface BLESubConnecter : NSObject

/**
 インスタンス取得、生成
 
 シングルトンデザインパターン。
 @param     なし
 @return    シングルトンのインスタンス
 */
+ (BLESubConnecter *)sharedInstance;

/**
 未接続チェック
 */
- (void)disconnectStatusChecker:(CBPeripheral *)peripheral;

/**
 タイムアウトを設定するタイマーの停止
 */
- (void)stopTimeOutTimer:(CBPeripheral *)peripheral;

/**
 すべてのタイムアウトを設定するタイマーの停止
 */
- (void)stopAllTimeOutTimer;

/**
 デバイス情報の保存
 */
- (void)saveAtTheDevice:(CBPeripheral *)peripheral;

/**
 センサーの停止
 */
- (void)stopSensorTimer:(CBPeripheral *)peripheral;

/**
 すべてのセンサーの停止
 */
- (void)stopAllSensorTimer;

/**
 接続を切断するタイマーの停止
 */
- (void)stopDisconnectTimer:(CBPeripheral *)peripheral;

/**
 すべての接続を切断するタイマーの停止
 */
- (void)stopAllDisconnectTimer;

@end
