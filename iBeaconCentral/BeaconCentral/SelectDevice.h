//
//  SelectDevice.h
//  iBeaconCentral
//
//  Created by HongQuan on 2017/10/20.
//  Copyright © 2017年 kenkou All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LinkingLibrary/LinkingLibrary.h>

@protocol SelectDeviceDelegate <NSObject>

@optional
//アドバタイズの受信を通知する
-(void)advertisementReceive;
@end

@interface SelectDevice : NSObject<BLEConnecterDelegate>

@property (nonatomic)BLEDeviceSetting *device;
@property (nonatomic,)CBPeripheral *peripheral;
@property (nonatomic) BOOL beaconMode;
@property (nonatomic) NSMutableArray *advertisementArray;
@property (nonatomic) NSMutableDictionary *advertisementDic;
@property (nonatomic, weak) id<SelectDeviceDelegate> delegate;

+ (SelectDevice *)sharedInstance;
-(void)deleteAdvertise;
-(void)addAdvertisement:(NSDictionary*)advertise;

@end

