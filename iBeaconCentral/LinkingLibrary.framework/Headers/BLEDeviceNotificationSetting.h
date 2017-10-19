/**
 * Copyright © 2015-2016 NTT DOCOMO, INC. All Rights Reserved.
 */

#import <Foundation/Foundation.h>

/**
 通知情報を管理するクラス
 @warninng 使用されないメソッドも記載
 */
@interface BLEDeviceNotificationSetting : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) NSString *appNameLocal;
@property (nonatomic, copy) NSString *package;
@property (nonatomic) short notifyId;
@property (nonatomic) short notifyCategoryId;
@property (nonatomic, getter=isLedSetting) BOOL ledSetting;
@property (nonatomic, getter=isVibrationSetting) BOOL vibrationSetting;
@property (nonatomic, getter=isNotifySoundSetting) BOOL notifySoundSetting;
@property (nonatomic, strong) NSMutableDictionary *led;
@property (nonatomic, strong) NSMutableDictionary *vibration;
@property (nonatomic, strong) NSMutableDictionary *notifySound;
@property (nonatomic) int uniqueId;

@property (nonatomic,copy) NSData *content1;
@property (nonatomic,copy) NSData *content2;
@property (nonatomic,copy) NSData *content3;
@property (nonatomic,copy) NSData *content4;
@property (nonatomic,copy) NSData *content5;
@property (nonatomic,copy) NSData *content6;
@property (nonatomic,copy) NSData *content7;
@property (nonatomic,copy) NSData *imageData;
@property (nonatomic,copy) NSString *imageType;
@property (nonatomic,copy) NSData *mediaData;
@property (nonatomic,copy) NSString *mediaType;

@property (nonatomic,copy)   NSString *sender;
@property (nonatomic,copy)   NSString *senderAddress;
@property (nonatomic,strong) NSDate *receiveDate;

@property (nonatomic,strong) NSDate *startDate;
@property (nonatomic,strong) NSDate *endDate;
@property (nonatomic,copy)   NSString *area;
@property (nonatomic,copy)   NSString *person;

@property (nonatomic,assign) unsigned short deviceId;
@property (nonatomic,strong) NSMutableArray *deviceUId;

@end
