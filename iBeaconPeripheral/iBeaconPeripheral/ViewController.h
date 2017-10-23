//
//  ViewController.h
//  iBeaconPeripheral
//
//  Created by Roan Hong on 2017/10/23.
//  Copyright (c) 2017年 kenkou All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController : UIViewController <CBPeripheralManagerDelegate, UITextFieldDelegate>


@end

