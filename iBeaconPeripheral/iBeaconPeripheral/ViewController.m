//
//  ViewController.m
//  iBeaconPeripheral
//
//  Created by Roan Hong on 2017/10/23.
//  Copyright (c) 2017年 kenkou All rights reserved.
//

#import "ViewController.h"

#define PROXIMITY_UUID @"05EC5ED2-300C-4ED9-A204-F4C3FC7DB7A1"
#define BEACON_IDENTIFER @"com.kenkou.ibeaconcentral"
#define MAJOR 1
#define MINER 1
#define MEASURED_POWER -51.0f

@interface ViewController() {
    CGFloat displayWidth;
    CGFloat displayHeight;
    
    UIScrollView *contentsView;
    CGFloat tempScrollTop;
    UITextField *activeTextField;
    
    UILabel *icon;
    
    UILabel *beaconStatusLabel;
    
    UIButton *proximityUUIDButton;
    UITextField *majorTextField;
    UITextField *minorTextField;
    UITextField *measuredPowerTextField;
}

@property (nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) NSString *identifier;
@property (nonatomic) CLBeaconMajorValue major;
@property (nonatomic) CLBeaconMinorValue minor;
@property (nonatomic) NSNumber *measuredPower;
@property (nonatomic) BOOL noticeEnabled;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"ViewController :: viewDidLoad");
    
    displayWidth = self.view.frame.size.width;
    displayHeight = self.view.frame.size.height;
    
    // キーボード表示/非表示通知登録
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // ユーザデフォルト取得
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:@{@"localNotificationEnabled":@YES}];
    
    // 初期設定
    self.view.backgroundColor = [UIColor colorWithRed:0.255 green:0.412 blue:0.882 alpha:1.0];
    self.noticeEnabled = [userDefaults boolForKey:@"localNotificationEnabled"];
    NSLog(@"self.noticeEnabled = %@", [userDefaults boolForKey:@"localNotificationEnabled"] ? @"True" : @"False");
    
    // iBeacon機能が利用可能かどうか (シミュレータは不可)
    BOOL iBeaconAvailable = [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]];
    NSLog(@"iBeaconAvailable = %@", iBeaconAvailable ? @"True" : @"False");
    
    // Beacon情報初期設定
    self.proximityUUID = [[NSUUID alloc] initWithUUIDString:PROXIMITY_UUID];
    self.identifier = BEACON_IDENTIFER;
    self.major = (CLBeaconMajorValue)MAJOR;
    self.minor = (CLBeaconMinorValue)MINER;
    self.measuredPower = [NSNumber numberWithFloat:MEASURED_POWER];
    
    contentsView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, displayWidth, displayHeight)];
    [self.view addSubview:contentsView];
    
    UILabel *label;
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, displayWidth, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"iBeacon Peripheral";
    label.font = [UIFont systemFontOfSize:32];
    label.textColor = [UIColor whiteColor];
    [contentsView addSubview:label];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, displayWidth, 40)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = iBeaconAvailable ? @"iBeacon is Available" : @"iBeacon is Unavailable";
    label.textColor = [UIColor whiteColor];
    [contentsView addSubview:label];
    
    icon = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, displayWidth, 300)];
    icon.center = CGPointMake(displayWidth/2, 140);
    icon.textAlignment = NSTextAlignmentCenter;
    icon.text = @"●";
    icon.textColor = [UIColor whiteColor];
    icon.font = [UIFont systemFontOfSize:icon.frame.size.height];
    icon.alpha = 0;
    icon.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [contentsView addSubview:icon];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, displayWidth, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Send Beacon";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    [contentsView addSubview:label];
    
    UISwitch *enableSwitch = [[UISwitch alloc] init];
    enableSwitch.center = CGPointMake(displayWidth/2, 200);
    enableSwitch.on = YES;
    [enableSwitch addTarget:self action:@selector(toggleBeaconEnabled:) forControlEvents:UIControlEventValueChanged];
    [contentsView addSubview:enableSwitch];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(displayWidth*0.05, 250, displayWidth*0.9, 20)];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = @"Proximity UUID";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    [contentsView addSubview:label];
    proximityUUIDButton = [[UIButton alloc] initWithFrame:CGRectMake(displayWidth*0.05, label.frame.origin.y+label.frame.size.height, displayWidth*0.9, 30)];
    proximityUUIDButton.layer.borderWidth = 1;
    proximityUUIDButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    proximityUUIDButton.layer.cornerRadius = 4.0;
    //[proximityUUIDButton addTarget:self action:@selector(selectProximityUUID:) forControlEvents:UIControlEventTouchUpInside];
    [proximityUUIDButton setTitle:PROXIMITY_UUID forState:UIControlStateNormal];
    proximityUUIDButton.titleLabel.font = [UIFont systemFontOfSize:12];
    proximityUUIDButton.alpha = 0.5;
    proximityUUIDButton.userInteractionEnabled = NO;
    [contentsView addSubview:proximityUUIDButton];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(displayWidth*0.05, proximityUUIDButton.frame.origin.y+proximityUUIDButton.frame.size.height+5, displayWidth*0.9, 20)];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = @"Major";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    [contentsView addSubview:label];
    majorTextField = [[UITextField alloc] initWithFrame:CGRectMake(displayWidth*0.05, label.frame.origin.y+label.frame.size.height, displayWidth*0.9, 30)];
    majorTextField.layer.borderWidth = 1;
    majorTextField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    majorTextField.layer.cornerRadius = 4.0;
    majorTextField.delegate = self;
    majorTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    majorTextField.returnKeyType = UIReturnKeyDone;
    majorTextField.textAlignment = NSTextAlignmentCenter;
    majorTextField.textColor = [UIColor whiteColor];
    majorTextField.font = [UIFont systemFontOfSize:12];
    majorTextField.text = @"1";
    majorTextField.alpha = 0.5;
    majorTextField.userInteractionEnabled = NO;
    [contentsView addSubview:majorTextField];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(displayWidth*0.05, majorTextField.frame.origin.y+majorTextField.frame.size.height+5, displayWidth*0.9, 20)];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = @"Minor";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    [contentsView addSubview:label];
    minorTextField = [[UITextField alloc] initWithFrame:CGRectMake(displayWidth*0.05, label.frame.origin.y+label.frame.size.height, displayWidth*0.9, 30)];
    minorTextField.layer.borderWidth = 1;
    minorTextField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    minorTextField.layer.cornerRadius = 4.0;
    minorTextField.delegate = self;
    minorTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    minorTextField.returnKeyType = UIReturnKeyDone;
    minorTextField.textAlignment = NSTextAlignmentCenter;
    minorTextField.textColor = [UIColor whiteColor];
    minorTextField.font = [UIFont systemFontOfSize:12];
    minorTextField.text = @"1";
    minorTextField.alpha = 0.5;
    minorTextField.userInteractionEnabled = NO;
    [contentsView addSubview:minorTextField];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(displayWidth*0.05, minorTextField.frame.origin.y+minorTextField.frame.size.height+5, displayWidth*0.9, 20)];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = @"Measured Power";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    [contentsView addSubview:label];
    measuredPowerTextField = [[UITextField alloc] initWithFrame:CGRectMake(displayWidth*0.05, label.frame.origin.y+label.frame.size.height, displayWidth*0.9, 30)];
    measuredPowerTextField.layer.borderWidth = 1;
    measuredPowerTextField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    measuredPowerTextField.layer.cornerRadius = 4.0;
    measuredPowerTextField.delegate = self;
    measuredPowerTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    measuredPowerTextField.returnKeyType = UIReturnKeyDone;
    measuredPowerTextField.textAlignment = NSTextAlignmentCenter;
    measuredPowerTextField.textColor = [UIColor whiteColor];
    measuredPowerTextField.font = [UIFont systemFontOfSize:12];
    measuredPowerTextField.text = @"-51";
    measuredPowerTextField.alpha = 0.5;
    measuredPowerTextField.userInteractionEnabled = NO;
    [contentsView addSubview:measuredPowerTextField];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 490, displayWidth, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Local Notification Enabled";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    [contentsView addSubview:label];
    
    UISwitch *noticeSwitch = [[UISwitch alloc] init];
    noticeSwitch.center = CGPointMake(displayWidth/2, 530);
    noticeSwitch.on = self.noticeEnabled;
    [noticeSwitch addTarget:self action:@selector(toggleNoticeEnabled:) forControlEvents:UIControlEventValueChanged];
    [contentsView addSubview:noticeSwitch];
    
    // コンテントサイズ調整
    contentsView.contentSize = CGSizeMake(contentsView.frame.size.width, noticeSwitch.frame.origin.y+noticeSwitch.frame.size.height+20);
    
    // CBPeripheralManager 生成
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
    
    // アドバタイズ開始処理
    NSLog(@"self.peripheralManager.state: %ld", (long)self.peripheralManager.state);
    NSLog(@"CBPeripheralManagerStatePoweredOn: %ld", (long)CBPeripheralManagerStatePoweredOn);
    [self startAdvertising];
}

// アドバタイズ開始処理
- (void)startAdvertising {
    NSLog(@"startAdvertising");
    
    proximityUUIDButton.alpha = 0.5;
    proximityUUIDButton.userInteractionEnabled = NO;
    majorTextField.alpha = 0.5;
    majorTextField.userInteractionEnabled = NO;
    minorTextField.alpha = 0.5;
    minorTextField.userInteractionEnabled = NO;
    measuredPowerTextField.alpha = 0.5;
    measuredPowerTextField.userInteractionEnabled = NO;
    
    majorTextField.text = [NSString stringWithFormat:@"%d", self.major];
    minorTextField.text = [NSString stringWithFormat:@"%d", self.minor];
    measuredPowerTextField.text = [NSString stringWithFormat:@"%@", self.measuredPower];
    
    if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        // CLBeaconRegionを作成してアドバタイズするデータを取得
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID major:self.major minor:self.minor identifier:self.identifier];
        NSDictionary *beaconPeripheralData = [beaconRegion peripheralDataWithMeasuredPower:self.measuredPower];
        
        // アドバタイズ開始
        [self.peripheralManager startAdvertising:beaconPeripheralData];
        
        icon.alpha = 1;
        [UIView animateWithDuration:1.0f
                              delay:0.8f
                            options:UIViewAnimationOptionRepeat|UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             icon.alpha = 0;
                             icon.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         } completion:^(BOOL finished) {
                             
                         }];
    }
}

// アドバタイズ停止処理
- (void)stopAdvertising {
    NSLog(@"stopAdvertising");
    
    proximityUUIDButton.alpha = 1;
    proximityUUIDButton.userInteractionEnabled = YES;
    majorTextField.alpha = 1;
    majorTextField.userInteractionEnabled = YES;
    minorTextField.alpha = 1;
    minorTextField.userInteractionEnabled = YES;
    measuredPowerTextField.alpha = 1;
    measuredPowerTextField.userInteractionEnabled = YES;
    
    [self.peripheralManager stopAdvertising];
    
    icon.alpha = 0;
    icon.transform = CGAffineTransformMakeScale(0.01, 0.01);
}

// Beacon発信のON/OFF切り替え
- (void)toggleBeaconEnabled:(UISwitch*)_switch {
    NSLog(@"toggleBeaconEnabled: enabled = %@", _switch.on?@"true":@"false");
    
    if (_switch.on) {
        [self startAdvertising];
    } else {
        [self stopAdvertising];
    }
}

// LocalNotification 処理
- (void)sendLocalNotificationForMessage:(NSString *)message {
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

// iBeacon アドバタイズ開始時
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    NSLog(@"Start iBeacon");
    
    if (error) {
        NSLog(@"error: %@", error);
        [self sendLocalNotificationForMessage:[NSString stringWithFormat:@"%@", error]];
    } else {
        [self sendLocalNotificationForMessage:@"Start Advertising"];
    }
}

// iBeacon ステータス更新時
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    NSLog(@"peripheralManagerDidUpdateState:: status = %d", (int)peripheral.state);
    
    NSString *message;
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOff:
            message = @"PoweredOff";
            break;
        case CBPeripheralManagerStatePoweredOn:
            message = @"PoweredOn";
            [self startAdvertising];
            break;
        case CBPeripheralManagerStateResetting:
            message = @"Resetting";
            break;
        case CBPeripheralManagerStateUnauthorized:
            message = @"Unauthorized";
            break;
        case CBPeripheralManagerStateUnknown:
            message = @"Unknown";
            break;
        case CBPeripheralManagerStateUnsupported:
            message = @"Unsupported";
            break;
            
        default:
            break;
    }
    NSLog(@"%@", message);
    
    [self sendLocalNotificationForMessage:[@"PeripheralManager did update state: " stringByAppendingString:message]];
}

// TextField デリゲートメソッド
// フォーカス時
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeTextField = textField;
}
// メッセージ入力終了処理
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == majorTextField) {
        int tmp_val = [textField.text intValue];
        if (tmp_val < 0) {
            self.major = 0;
        } else if (tmp_val > UINT16_MAX) {
            self.major = UINT16_MAX;
        } else {
            self.major = tmp_val;
        }
        textField.text = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%d", self.major]];
        NSLog(@"changed major: self.major = %d", self.major);
    } else if (textField == minorTextField) {
        int tmp_val = [textField.text intValue];
        if (tmp_val < 0) {
            self.minor = 0;
        } else if (tmp_val > UINT16_MAX) {
            self.minor = UINT16_MAX;
        } else {
            self.minor = tmp_val;
        }
        textField.text = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%d", self.minor]];
        NSLog(@"changed minor: self.minor = %d", self.minor);
    } else if (textField == measuredPowerTextField) {
        self.measuredPower = [NSNumber numberWithFloat:[textField.text floatValue]];
        textField.text = [NSString stringWithFormat:@"%@", self.measuredPower];
        NSLog(@"changed measuredPower: self.measuredPower = %@", self.measuredPower);
    }
    
    [textField resignFirstResponder];
    return YES;
}

// キーボード表示時
- (void)keyboardWillShow:(NSNotification*)notification {
    NSLog(@"keyboardWillShow");
    // スクロール位置一時保存
    tempScrollTop = contentsView.scrollsToTop;
    
    // キーボードサイズ取得
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 最適位置までスクロール
    CGPoint scrollPoint = CGPointMake(0, (activeTextField.frame.origin.y+activeTextField.frame.size.height+5)-(displayHeight-keyboardRect.size.height));
    [contentsView setContentOffset:scrollPoint animated:YES];
}
// キーボード非表示時
- (void)keyboardWillHide:(NSNotification*)notification {
    NSLog(@"keyboardWillHide");
    
    // スクロール位置を戻す
    [contentsView setContentOffset:CGPointMake(0.0, tempScrollTop) animated:YES];
}

// ローカル通知のON/OFF切り替え
- (void)toggleNoticeEnabled:(UISwitch*)_switch {
    self.noticeEnabled = _switch.on;
    NSLog(@"toggleNoticeEnabled: noticeEnabled = %@", self.noticeEnabled?@"true":@"false");
    
    // ローカル通知ON/OFF設定保存
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:self.noticeEnabled forKey:@"localNotificationEnabled"];
    [userDefaults synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
