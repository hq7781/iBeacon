//
//  SelectDevice.h
//  iBeaconCentral
//
//  Created by HongQuan on 2017/10/20.
//  Copyright © 2017年 kenkou All rights reserved.
//

#import <Foundation/Foundation.h>
#if (SURPPORT_LIKING)
#import <LinkingLibrary/LinkingLibrary.h>
#endif
@protocol SelectDeviceDelegate <NSObject>

@optional
//アドバタイズの受信を通知する
-(void)advertisementReceive;
@end
#if (SURPPORT_LIKING)
@interface SelectDevice : NSObject<BLEConnecterDelegate>
#else
@interface SelectDevice : NSObject
#endif

#if (SURPPORT_LIKING)
@property (nonatomic)BLEDeviceSetting *device;
@property (nonatomic,)CBPeripheral *peripheral;
#endif

@property (nonatomic) BOOL beaconMode;
@property (nonatomic) NSMutableArray *advertisementArray;
@property (nonatomic) NSMutableDictionary *advertisementDic;
@property (nonatomic, weak) id<SelectDeviceDelegate> delegate;

+ (SelectDevice *)sharedInstance;
-(void)deleteAdvertise;
-(void)addAdvertisement:(NSDictionary*)advertise;

@end

