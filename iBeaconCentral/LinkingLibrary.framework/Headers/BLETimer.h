/**
 * Copyright © 2015-2016 NTT DOCOMO, INC. All Rights Reserved.
 */

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLESensorGyroscope.h"
#import "BLESensorAccelerometer.h"
#import "BLESensorOrientation.h"
#import "BLESensorBatteryPower.h"
#import "BLESensorTemperature.h"
#import "BLESensorHumidity.h"
#import "BLESensorAtmosphericPressure.h"

/**
 タイマーのデリゲート
 @warninng 使用されないデリゲートも記載
 */
@protocol BLETimerDelegate <NSObject>

// 各サービスのレスポンスをアプリ側に返す
/**
 設定された間隔でのジャイロセンサーの取得を通知
 
 @param peripheral 取得したデバイスのペリフェラル
 @param gyroscope 取得したデバイスのセンサーデータ
 */
- (void)gyroscopeDidUpDateWithInterval:(CBPeripheral *)peripheral gyroscope:(BLESensorGyroscope *)gyroscope;

/**
 設定された間隔での加速センサーの取得を通知
 
 @param peripheral 取得したデバイスのペリフェラル
 @param accelerometer 取得したデバイスのセンサーデータ
 */
- (void)accelerometerDidUpDateWithInterval:(CBPeripheral *)peripheral accelerometer:(BLESensorAccelerometer *)accelerometer;

/**
 設定された間隔での方位センサーの取得を通知
 
 @param peripheral 取得したデバイスのペリフェラル
 @param orientation 取得したデバイスのセンサーデータ
 */
- (void)orientationDidUpDateWithInterval:(CBPeripheral *)peripheral orientation:(BLESensorOrientation *)orientation;

/**
 設定された間隔での電池残量の取得を通知
 
 @param peripheral 取得したデバイスのペリフェラル
 @param batteryPower 取得したデバイスのセンサーデータ
 */
- (void)batteryPowerDidUpDateWithInterval:(CBPeripheral *)peripheral batteryPower:(BLESensorBatteryPower *)batteryPower;

/**
 設定された間隔での温度センサーの取得を通知
 
 @param peripheral 取得したデバイスのペリフェラル
 @param temperature 取得したデバイスのセンサーデータ
 */
- (void)temperatureDidUpDateWithInterval:(CBPeripheral *)peripheral temperature:(BLESensorTemperature *)temperature;

/**
 設定された間隔での湿度センサーの取得を通知
 
 @param peripheral 取得したデバイスのペリフェラル
 @param humidity 取得したデバイスのセンサーデータ
 */
- (void)humidityDidUpDateWithInterval:(CBPeripheral *)peripheral humidity:(BLESensorHumidity *)humidity;

/**
 設定された間隔での気圧センサーの取得を通知
 
 @param peripheral 取得したデバイスのペリフェラル
 @param atmosphericPressure 取得したデバイスのセンサーデータ
 */
- (void)atmosphericPressureDidUpDateWithInterval:(CBPeripheral *)peripheral atmosphericPressure:(BLESensorAtmosphericPressure *)atmosphericPressure;

/**
 設定時間超過の為,ジャイロセンサーの取得終了を通知
 @param peripheral 終了したデバイスのペリフェラル
 */
- (void)gyroscopeObservationEnded:(CBPeripheral *)peripheral;

/**
 設定時間超過の為,加速センサーの取得終了を通知
 @param peripheral 終了したデバイスのペリフェラル
 */
- (void)accelerometerObservationEnded:(CBPeripheral *)peripheral;

/**
 設定時間超過の為,方位センサーの取得終了を通知
 @param peripheral 終了したデバイスのペリフェラル
 */
- (void)orientationObservationEnded:(CBPeripheral *)peripheral;

/**
 設定時間超過の為,電池残量の取得終了を通知
 @param peripheral 終了したデバイスのペリフェラル
 */
- (void)batteryPowerObservationEnded:(CBPeripheral *)peripheral;

/**
 設定時間超過の為,温度センサーの取得終了を通知
 @param peripheral 終了したデバイスのペリフェラル
 */
- (void)temperatureObservationEnded:(CBPeripheral *)peripheral;

/**
 設定時間超過の為,湿度センサーの取得終了を通知
 @param peripheral 終了したデバイスのペリフェラル
 */
- (void)humidityObservationEnded:(CBPeripheral *)peripheral;

/**
 設定時間超過の為,気圧センサーの取得終了を通知
 @param peripheral 終了したデバイスのペリフェラル
 */
- (void)atmosphericPressureObservationEnded:(CBPeripheral *)peripheral;

/**
 接続がタイムアウトした場合の通知
 @param peripheral タイムアウトしたデバイスのペリフェラル
 */
- (void)didTimeout:(CBPeripheral *)peripheral;

@end
/**
 タイマーを管理しているクラス
 */
@interface BLETimer : NSObject

@property (nonatomic)NSTimer *gyroscopeIntervalTimer;
@property (nonatomic)NSTimer *gyroscopeAutoStopTimer;
@property (nonatomic)NSTimer *accelerometerIntervalTimer;
@property (nonatomic)NSTimer *accelerometerAutoStopTimer;
@property (nonatomic)NSTimer *orientationIntervalTimer;
@property (nonatomic)NSTimer *orientationAutoStopTimer;
@property (nonatomic)NSTimer *batteryPowerIntervalTimer;
@property (nonatomic)NSTimer *batteryPowerAutoStopTimer;
@property (nonatomic)NSTimer *temperatureIntervalTimer;
@property (nonatomic)NSTimer *temperatureAutoStopTimer;
@property (nonatomic)NSTimer *humidityIntervalTimer;
@property (nonatomic)NSTimer *humidityAutoStopTimer;
@property (nonatomic)NSTimer *atmosphericPressureIntervalTimer;
@property (nonatomic)NSTimer *atmosphericPressureAutoStopTimer;
@property (nonatomic)NSTimer *disconnectTimer;

@property (nonatomic)NSTimer *timeOutTimer;

@property (nonatomic)CBPeripheral *gyroscopePeripheral;
@property (nonatomic)CBPeripheral *accelerometerPeripheral;
@property (nonatomic)CBPeripheral *orientationPeripheral;
@property (nonatomic)CBPeripheral *disconnectPeripheral;
@property (nonatomic)CBPeripheral *timeOutPeripheral;
@property (nonatomic)CBPeripheral *batteryPowerPeripheral;
@property (nonatomic)CBPeripheral *temperaturePeripheral;
@property (nonatomic)CBPeripheral *humidityPeripheral;
@property (nonatomic)CBPeripheral *atmosphericPressurePeripheral;

@property (nonatomic)float gyroscopeInterval;
@property (nonatomic)float gyroscopeStopTime;
@property (nonatomic)float accelerometerInterval;
@property (nonatomic)float accelerometerStopTime;
@property (nonatomic)float orientationInterval;
@property (nonatomic)float orientationStopTime;
@property (nonatomic)float batteryPowerInterval;
@property (nonatomic)float batteryPowerStopTime;
@property (nonatomic)float temperatureInterval;
@property (nonatomic)float temperatureStopTime;
@property (nonatomic)float humidityInterval;
@property (nonatomic)float humidityStopTime;
@property (nonatomic)float atmosphericPressureInterval;
@property (nonatomic)float atmosphericPressureStopTime;

@property (nonatomic)float disconnectTime;

@property (nonatomic)float timeOutTime;


/**
 BLETimerDelegate インスタンス
 通知先のインスタンスが入ります。
 */
@property (nonatomic, weak) id<BLETimerDelegate> delegate;

/**
 BLETimerDelegate インスタンス
 通知先のインスタンスが入ります。
 */
@property (nonatomic, weak) id<BLETimerDelegate> connecterDelegate;

// ジャイロ
/**
 ジャイロセンサーの開始
 @param peripheral 開始するデバイスのペリフェラル
 */
- (void)startGyroscopeIntervalTimer:(CBPeripheral *)peripheral;

/**
 ジャイロセンサーの停止
 @param peripheral 停止するデバイスのペリフェラル
 */
- (void)stopGyroscopeIntervalTimer:(CBPeripheral *)peripheral;

/**
 ジャイロセンサーの停止時間を設定
 @param peripheral 設定するデバイスのペリフェラル
 */
- (void)startGyroscopeAutoStopTimer:(CBPeripheral *)peripheral;

/**
 設定時間超過によるジャイロセンサーの停止
 @param peripheral 停止するデバイスのペリフェラル
 */
- (void)stopGyroscopeAutoStopTimer:(CBPeripheral *)peripheral;

// 加速
/**
 加速センサーの開始
 @param peripheral 開始するデバイスのペリフェラル
 */
- (void)startAccelerometerIntervalTimer:(CBPeripheral *)peripheral;

/**
 加速センサーの停止
 @param peripheral 停止するデバイスのペリフェラル
 */
- (void)stopAccelerometerIntervalTimer:(CBPeripheral *)peripheral;

/**
 加速センサーの停止時間を設定
 @param peripheral 設定するデバイスのペリフェラル
 */
- (void)startAccelerometerAutoStopTimer:(CBPeripheral *)peripheral;

/**
 設定時間超過による加速センサーの停止
 @param peripheral 停止するデバイスのペリフェラル
 */
- (void)stopAccelerometerAutoStopTimer:(CBPeripheral *)peripheral;

// 方位
/**
 方位センサーの開始
 @param peripheral 開始するデバイスのペリフェラル
 */
- (void)startOrientationIntervalTimer:(CBPeripheral *)peripheral;

/**
 方位センサーの停止
 @param peripheral 停止するデバイスのペリフェラル
 */
- (void)stopOrientationIntervalTimer:(CBPeripheral *)peripheral;

/**
 方位センサーの停止時間を設定
 @param peripheral 設定するデバイスのペリフェラル
 */
- (void)startOrientationAutoStopTimer:(CBPeripheral *)peripheral;

/**
 設定時間超過による方位センサーの停止
 @param peripheral 停止するデバイスのペリフェラル
 */
- (void)stopOrientationAutoStopTimer:(CBPeripheral *)peripheral;

// 電池残量
/**
 電池残量の開始
 @param peripheral 開始するデバイスのペリフェラル
 */
- (void)startBatteryPowerIntervalTimer:(CBPeripheral *)peripheral;

/**
 電池残量の停止
 @param peripheral 停止するデバイスのペリフェラル
 */
- (void)stopBatteryPowerIntervalTimer:(CBPeripheral *)peripheral;

/**
 電池残量の停止時間を設定
 @param peripheral 設定するデバイスのペリフェラル
 */
- (void)startBatteryPowerAutoStopTimer:(CBPeripheral *)peripheral;

/**
 設定時間超過による電池残量の停止
 @param peripheral 停止するデバイスのペリフェラル
 */
- (void)stopBatteryPowerAutoStopTimer:(CBPeripheral *)peripheral;

// 温度
/**
 温度センサーの開始
 @param peripheral 開始するデバイスのペリフェラル
 */
- (void)startTemperatureIntervalTimer:(CBPeripheral *)peripheral;

/**
 温度センサーの停止
 @param peripheral 停止するデバイスのペリフェラル
 */
- (void)stopTemperatureIntervalTimer:(CBPeripheral *)peripheral;

/**
 温度センサーの停止時間を設定
 @param peripheral 設定するデバイスのペリフェラル
 */
- (void)startTemperatureAutoStopTimer:(CBPeripheral *)peripheral;

/**
 設定時間超過による温度センサーの停止
 @param peripheral 停止するデバイスのペリフェラル
 */
- (void)stopTemperatureAutoStopTimer:(CBPeripheral *)peripheral;

// 湿度
/**
 湿度センサーの開始
 @param peripheral 開始するデバイスのペリフェラル
 */
- (void)startHumidityIntervalTimer:(CBPeripheral *)peripheral;

/**
 湿度センサーの停止
 @param peripheral 停止するデバイスのペリフェラル
 */
- (void)stopHumidityIntervalTimer:(CBPeripheral *)peripheral;

/**
 湿度センサーの停止時間を設定
 @param peripheral 設定するデバイスのペリフェラル
 */
- (void)startHumidityAutoStopTimer:(CBPeripheral *)peripheral;

/**
 設定時間超過による湿度センサーの停止
 @param peripheral 停止するデバイスのペリフェラル
 */
- (void)stopHumidityAutoStopTimer:(CBPeripheral *)peripheral;

// 気圧
/**
 気圧センサーの開始
 @param peripheral 開始するデバイスのペリフェラル
 */
- (void)startAtmosphericPressureIntervalTimer:(CBPeripheral *)peripheral;

/**
 気圧センサーの停止
 @param peripheral 停止するデバイスのペリフェラル
 */
- (void)stopAtmosphericPressureIntervalTimer:(CBPeripheral *)peripheral;

/**
 気圧センサーの停止時間を設定
 @param peripheral 設定するデバイスのペリフェラル
 */
- (void)startAtmosphericPressureAutoStopTimer:(CBPeripheral *)peripheral;

/**
 設定時間超過による気圧センサーの停止
 @param peripheral 停止するデバイスのペリフェラル
 */
- (void)stopAtmosphericPressureAutoStopTimer:(CBPeripheral *)peripheral;

/**
 接続を切断するタイマーの開始
 @param peripheral 開始するデバイスのペリフェラル
 */
- (void)startDisconnectTimer:(CBPeripheral *)peripheral;

/**
 接続を切断するタイマーの停止
 @param peripheral 停止するデバイスのペリフェラル
 */
- (void)stopDisconnectTimer:(CBPeripheral *)peripheral;

/**
 タイムアウトを設定するタイマーの開始
 @param peripheral 開始するデバイスのペリフェラル
 */
- (void)startTimeOutTimer:(CBPeripheral *)peripheral;

/**
 タイムアウトを設定するタイマーの停止
 @param peripheral 停止するデバイスのペリフェラル
 */
- (void)stopTimeOutTimer:(CBPeripheral *)peripheral;

@end
