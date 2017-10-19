/**
 * Copyright © 2015-2016 NTT DOCOMO, INC. All Rights Reserved.
 */

#import <Foundation/Foundation.h>
/**
 温度センサーのモデルクラス
 */
@interface BLESensorTemperature : NSObject

@property (nonatomic,assign) float xValue;
@property (nonatomic,assign) float yValue;
@property (nonatomic,assign) float zValue;
@property (nonatomic,copy)   NSData *originalData;

@end
