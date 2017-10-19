/**
 * Copyright © 2015-2016 NTT DOCOMO, INC. All Rights Reserved.
 */
/* !!COMMON_MODULE_VERSION_INFO */

#ifndef COMMON_MODULE_VERSION_INFO
#define COMMON_MODULE_VERSION_INFO @"3.0.0"
#endif

#import <Foundation/Foundation.h>

/**
 Device Service UUID(128bit/16bit)
 */
static NSString * const kUUIDDeviceLinkService = @"b3b36901-50d3-4044-808d-50835b13a6cd";
static NSString * const kUUID16DeviceLinkService = @"FE4E";

/**
 Characteristic UUID
 */
static NSString * const kUUIDCharacteristicWriteMessage = @"b3b39101-50d3-4044-808d-50835b13a6cd";
static NSString * const kUUIDCharacteristicIndicateMessage = @"b3b39102-50d3-4044-808d-50835b13a6cd";

/**
 定数クラス
 */
@interface BLECommonConsts : NSObject

/**
 Packet structure[20byte]
 */
// length of packet
extern int const BLEPacketLength;

// length of packet header
extern int const BLEPacketHeaderLength;

// length of packet payload
extern int const BLEPacketPayloadLength;

/**
 Packet header structure[1byte]
 */
// source flag.
extern const char BLEPacketHeaderSourceClient;
extern const char BLEPacketHeaderSourceServer;

// cancel flag.
extern const char BLEPacketHeaderCancelOff;
extern const char BLEPacketHeaderCancelOn;

// default sequnece number.
extern const char BLEPacketHeaderDefaultSeqNum;

// terminal flag.
extern const char BLEPacketHeaderExecuteOff;
extern const char BLEPacketHeaderExecuteOn;

// bit mask of source flag.
extern const char BLEBitMaskOfPacketHeaderSource;

// bit mask of cancel flag.
extern const char BLEBitMaskOfPacketHeaderCancel;

// bit mask of sequence number.
extern const char BLEBitMaskOfPacketHeaderSequence;

// bit mask of terminal flag.
extern const char BLEBitMaskOfPacketExecute;

/**
 Packet payload structure[4byte + nbyte]
 */
// length of payload header
extern int const BLEPayloadHeaderLength;

// length of service id
extern int const BLEPayloadHeaderServiceIdLength;

// length of message id
extern int const BLEPayloadHeaderMessageIdLength;

// length of parameters number
extern int const BLEPayloadHeaderParametersLength;

/**
 data parameter structure[1byte + 3byte + nbyte]
 */
// length of parameter id
extern int const BLEPayloadParameterIdLength;

// length of parameter length
extern int const BLEPayloadParameterlenLength;

/**
 service id, category id definition
 */
// Service ID definition
extern const char BLEServiceIdPropertyInformation;
extern const char BLEServiceIdNotification;
extern const char BLEServiceIdOperation;
extern const char BLEServiceIdSensorInformation;
extern const char BLEServiceIdSettingOperation;

// general
extern const char BLEZeroPadding;
extern int const BLEWorkBufferSize;
extern int const BLEParameterLength;
extern int const BLEPayloadSize;
extern int const BLEResultCodeSize;
extern int const BLEButtonIdSize;
extern int const BLEFileVerSize;
extern const char BLEInitResultCode;
extern int const BLEDataDigit100;
extern int const BLEDataDigit10000;
extern int const BLEDataDigit1000000;
extern const float BLEOneDayToSeconds;

extern int const BLEDataRange4;
extern int const BLEDataRange5;
extern int const BLEDataRange7;
extern int const BLEDataRange8;
extern int const BLEValueRange4;
extern int const BLEValueRange5;
extern int const BLEDataLength4;
extern int const BLEDataLength5;
extern int const BLEDataLength6;
extern int const BLEDataLength8;
extern int const BLEValueLength4;
extern int const BLEValueLength5;
extern int const BLEValueR4;
extern int const BLEXYZ3;
extern int const BLEInt0;

extern const char BLEChar0x00;
extern const char BLEChar0x01;
extern const char BLEChar0x02;
extern const char BLEChar0x03;
extern const char BLEChar0x04;
extern const char BLEChar0x05;
extern const char BLEChar0x06;
extern const char BLEChar0x07;
extern const char BLEChar0x08;
extern const char BLEChar0x09;
extern const char BLEChar0x10;
extern const char BLEChar0x20;
extern const char BLEChar0x40;
extern const char BLEChar0x80;

extern const char BLEBit0x01;
extern const char BLEBit0x02;
extern const char BLEBit0x04;
extern const char BLEBit0x08;
extern const char BLEBit0x10;
extern const char BLEBit0x20;
extern const char BLEBit0x40;
extern const char BLEBit0x80;
extern const char BLEBit0x3E;
extern const char BLEBit0x7F;
extern const char BLEBit0xBF;
extern const char BLEBit0xFE;
extern const char BLEBit0xFF;
extern const char BLEBit0x0F;
extern const char BLEBit0xF0;
extern const char BLEBitNone;
extern const int BLEBit4Shift;
extern const int BLEBit8Shift;
extern const int BLESequenceOver;
extern int const BLEGetSensorInfoRespMinDataLength;
extern int const BLENotifyPdSensorInfoValueRangePayloadLength;
extern int const BLENotifyPdSensorInfoOriginalDataLength;
extern int const BLENotifyPdSensorInfoSensorDataRange;
extern NSInteger const BLEAdvServiceDataFirstMask;
extern NSInteger const BLEAdvServiceDataOtherFirstMask;
extern const int BLECalibrationFormTypePairing;
extern const int BLECalibrationFormTypeBeacon;

/**
 各種文字列定数(エラー情報)
 */

// 端末のBluetoothはOFFになっています
extern const NSString* BLEErrMsgOfBluetoothOff;

// ペアリング方式でキャリブレーション中の状態のため、他の要求は受信できません。
extern const NSString* BLEErrMsgOfMidstPairingCalibration;

// ビーコン方式でキャリブレーション中の状態のため、他の要求は受信できません。
extern const NSString* BLEErrMsgOfMidstBeaconCalibration;

// Linkingデバイスとの接続が切断されました。
extern const NSString* BLEErrMsgOfDisconnected;

// 端末のBluetoothはOFFになっています
extern const NSString* BLEErrMsgOfOffBluetooth;

// キャリブレーション中の状態のため、他の要求は受信できません。
extern const NSString* BLEErrMsgOfMidstCalibration;

// Calculating Calibration
extern const NSString* BLEErrMsgOfCalculatingCalibration;

// 規定外の値が指定されたため、通常10sが設定されました。
extern const NSString* BLEErrMsgOfUnexpectedNumberChg10Sec;

// スキャン間隔の設定は失敗しました。
extern const NSString* BLEErrMsgOfFailedScanInterval;

/**
 各種文字列定数(他)
 */
// 受信データ:
extern const NSString* BLEReceivedData;

/**
 バージョン情報取得メソッド
 
 @return    現在のバージョンを返却
 */
+ (NSString*)versionInfo;

@end
