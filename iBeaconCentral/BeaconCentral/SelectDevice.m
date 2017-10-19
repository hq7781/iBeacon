//
//  SelectDevice.m
//  iBeaconCentral
//
//  Created by HongQuan on 2017/10/20.
//  Copyright © 2017年 kenkou All rights reserved.
//

#import "SelectDevice.h"

@implementation SelectDevice

+ (SelectDevice *)sharedInstance
{
    static SelectDevice *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

//アドバタイズのデータを保存
-(void)addAdvertisement:(NSDictionary*)advertise {
    
    if(self.advertisementArray.count == 0){
        self.advertisementArray = [[NSMutableArray alloc]init];
        self.advertisementDic = [[NSMutableDictionary alloc]init];
    }
    
    [self.advertisementArray addObject:advertise];
    
    //アドバタイズの受信を通知する
    if ([self.delegate respondsToSelector:@selector(advertisementReceive)]) {
        [self.delegate advertisementReceive];
        
    }
    
}

//アドバタイズのデータを削除
-(void)deleteAdvertise {
    self.advertisementArray = [[NSMutableArray alloc]init];
}
@end
