//
//  ViewController.m
//  iBeaconCentral
//
//  Created by Takahiro on 2014/04/12.
//  Copyright (c) 2014年 kenkou All rights reserved.
//

#import "ViewController.h"
#import "SelectDevice.h"
#import <LinkingLibrary/LinkingLibrary.h>

#define PROXIMITY_UUID @"913C64F0-9886-4FC3-B11C-78581F21CDB4"
#define BEACON_IDENTIFER @"com.kenkou.ibeaconcentral"

@interface ViewController () <BLEConnecterDelegate, BLEDelegateModelDelegate>{
 BLEConnecter *bleConnecter;
 BOOL isScanning;
}

@property (strong, nonatomic) IBOutlet CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet NSUUID *proximityUUID;
@property (strong, nonatomic) IBOutlet CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) IBOutlet CLBeacon *nearestBeacon;
@property (strong, nonatomic) IBOutlet NSString *str;

// new add
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (nonatomic) NSMutableArray *deviceArray;

@end

@implementation ViewController 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"iBeacon Central";
    self.view.backgroundColor = [UIColor blueColor];
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        self.proximityUUID = [[NSUUID alloc] initWithUUIDString:PROXIMITY_UUID];
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID: self.proximityUUID
                                                               identifier: BEACON_IDENTIFER];
        
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            // requestAlwaysAuthorizationメソッドが利用できる場合(iOS8以上の場合)
            // 位置情報の取得許可を求めるメソッド
            [self.locationManager requestAlwaysAuthorization];
        } else {
            // requestAlwaysAuthorizationメソッドが利用できない場合(iOS8未満の場合)
            [self.locationManager startMonitoringForRegion: self.beaconRegion];
        }
        
    } else {
        //iBeaconが利用できないOS, Deviceの場合
        NSLog(@"お使いの端末ではiBeaconを利用できません。");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"確認"
                                                        message:@"お使いの端末ではiBeaconを利用できません。"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
    // BLEConnecterクラスのインスタンス生成
    bleConnecter = [BLEConnecter sharedInstance];
    // デリゲートの登録 ※ペリフェラルを指定したい場合はdeviceUUIDを指定
    [bleConnecter addListener:self deviceUUID:nil];
}
- (void) dealloc {
    [[BLEConnecter sharedInstance] removeListener:self deviceUUID:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/////////////////////////////////////////
//インデックスパスを取得
- (NSIndexPath *)indexPathForCellContainingView:(UIView *)view {
    while (view != nil) {
        if ([view isKindOfClass:[UITableViewCell class]]) {
            return [self.mTableView indexPathForCell:(UITableViewCell *)view];
        } else {
            view = [view superview];
        }
    }
    return nil;
}
//UIスイッチの変更を監視
-(void)switchChanged:(UISwitch *)switchBtn {
    
    NSIndexPath *indexPath = [self indexPathForCellContainingView:switchBtn];
    if(indexPath.row >= 0 && indexPath.row<self.deviceArray.count){
        BLEDeviceSetting *device = [self.deviceArray objectAtIndex:indexPath.row];
        if(switchBtn.on){
            //デバイスを登録
            [SelectDevice sharedInstance].device = device;
        }else{
            //デバイスを削除
            [bleConnecter disconnectByDeviceUUID:device.peripheral.identifier.UUIDString];
            [SelectDevice sharedInstance].beaconMode = NO;
            [SelectDevice sharedInstance].device = nil;
        }
    }
    
    [self.mTableView reloadData];
}
#pragma mark - <UITableViewDelegate> methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.deviceArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceItemcell"];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1];
    BLEDeviceSetting *device = [self.deviceArray objectAtIndex:indexPath.row];
    NSString *deviceName = device.name;
    if([deviceName length] == 0){
        deviceName = device.peripheral.identifier.UUIDString;
    }
    nameLabel.text = deviceName;
    UISwitch *switchBtn = [cell viewWithTag:2];
    [switchBtn addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    if([[SelectDevice sharedInstance].device.peripheral.identifier.UUIDString isEqualToString:device.peripheral.identifier.UUIDString]){
        switchBtn.on = YES;
    }else{
        switchBtn.on = NO;
        if ([device.connectionStatus isEqualToString:DEV_STAT_CONNECTED]) {
            [bleConnecter disconnectByDeviceUUID:device.peripheral.identifier.UUIDString];
            [SelectDevice sharedInstance].beaconMode = NO;
        }
    }
    
    return cell;
}

#pragma mark - <CLLocationManagerDelegate> methods
// 領域計測が開始した場合
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self sendLocalNotificationForMessage:@"Start Monitoring Region"];
}

// 指定した領域に入った場合
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self sendLocalNotificationForMessage:@"Enter Region"];
    
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
    // set scan Linking device flag
    [self setLinkingScanStart];
}

// 指定した領域から出た場合
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self sendLocalNotificationForMessage:@"Exit Region"];
    
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
    // set scan Linking device flag
    [self setLinkingScanStop];
}

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    switch (state) {
        case CLRegionStateInside:
            if([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]){
                NSLog(@"Enter %@",region.identifier);
                //Beacon の範囲内に入った時に行う処理を記述する
                [self sendLocalNotificationForMessage:@"Already Entering"];
            }
            break;

        case CLRegionStateOutside:
        case CLRegionStateUnknown:
        default:
            break;
    }
}

// Beacon信号を検出した場合
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0) {
        //CLBeacon *nearestBeacon = beacons.firstObject;
        self.nearestBeacon = beacons.firstObject;
        
        NSString *rangeMessage;
        
        switch (self.nearestBeacon.proximity) {
            case CLProximityImmediate:
                rangeMessage = @"Range Immediate";
                break;
            case CLProximityNear:
                rangeMessage = @"Range Near";
                break;
            case CLProximityFar:
                rangeMessage = @"Range Far";
                break;
            default:
                rangeMessage = @"Range Unknown";
                break;
        }
        
        self.str = [[NSString alloc] initWithFormat:@"%f [m]", self.nearestBeacon.accuracy];
        NSLog(@"%@", self.str);
        [self sendLocalNotificationForMessage:self.str];
    }
}

// 領域観測に失敗した場合
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    [self sendLocalNotificationForMessage:@"Exit Region"];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusNotDetermined) {
        // ユーザが位置情報の使用を許可していない
    } else if(status == kCLAuthorizationStatusAuthorizedAlways) {
        // ユーザが位置情報の使用を常に許可している場合
        [self.locationManager startMonitoringForRegion: self.beaconRegion];
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    } else if(status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // ユーザが位置情報の使用を使用中のみ許可している場合
        [self.locationManager startMonitoringForRegion: self.beaconRegion];
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    }
    NSLog(@"status: %d", status);
}

#pragma mark - Private methods

- (void)sendLocalNotificationForMessage:(NSString *)message
{
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

#pragma mark - Linking methods Private methods
- (void)setLinkingScanStart {
    if (!isScanning) {
        isScanning = YES;
        // デバイス検索の呼び出し
        [bleConnecter scanDevice];
    } else {
        isScanning = NO;
        // デバイス検索を停止する
        [bleConnecter stopScan];
    }
}
- (void)setLinkingScanStop {
    isScanning = NO;
    // デバイス検索を停止する
    [bleConnecter stopScan];
}

//デバイス情報の更新
-(void)updateDeviceArrayByPeripheral:(CBPeripheral *)peripheral{
    BLEDeviceSetting *foundDevice = [bleConnecter getDeviceByPeripheral:peripheral];
    NSString *uuidStr = foundDevice.peripheral.identifier.UUIDString;
    int index = 0;
    for(BLEDeviceSetting *device in self.deviceArray){
        if([device.peripheral.identifier.UUIDString isEqualToString:uuidStr]){
            // ローカル名を上書きする
            if (peripheral.name != nil && peripheral.name.length > 0) {
                foundDevice.name = peripheral.name;
            }
            [self.deviceArray replaceObjectAtIndex:index withObject:foundDevice];
            [self.mTableView reloadData];
            break;
        }
        index++;
    }
}

//すでにリストにあるか判定
-(BOOL)hadInDeviceArray:(NSString *)uuidStr{
    
    BOOL existed = NO;
    for(BLEDeviceSetting *device in self.deviceArray){
        if([device.peripheral.identifier.UUIDString isEqualToString:uuidStr]){
            existed = YES;
            break;
        }
    }
    return existed;
}

#pragma mark - <BLEDelegateModelDelegate> methods
/**
 　デバイスが発見された際に呼ばれるデリゲート
 
 @param peripheral 発見したデバイスのペリフェラル
 @param advertisementData 発見したデバイスのアドバタイズデータ。接続済みデバイスの場合はnilを返す。
 @param RSSI 発見したデバイスのRSSI値。接続済みデバイスの場合はnilを返す。
 */
- (void)didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    //スキャン結果
    if(![self hadInDeviceArray:peripheral.identifier.UUIDString]){
        BLEDeviceSetting *device = [bleConnecter getDeviceByPeripheral:peripheral];
        device.inDistanceThreshold = YES;
        if(device != nil){
            [self.deviceArray addObject:device];
            [self.mTableView reloadData];
        }
    }
    
}

/**
 　デバイスに接続した際に呼ばれるデリゲート
 @param peripheral 接続したデバイスのペリフェラル
 */
- (void)didConnectPeripheral:(CBPeripheral *)peripheral{
    [self updateDeviceArrayByPeripheral:peripheral];
}

/**
 　デバイスに接続した際に呼ばれるデリゲート
 @param setting 接続したデバイスの設定情報
 */
- (void)didConnectDevice:(BLEDeviceSetting *)setting {
    //接続
    NSString *message = [NSString stringWithFormat:@"%@とペアリングしました",setting.name];
    NSLog(@"didConnectDevice() %@)",message);
//    if([self.navigationController.topViewController isKindOfClass:[SearchViewController class]]){
//        [self ShowInformMessage_showInformWithMessage:message title:nil okActionName:@"OK" handler:nil cancelActionName:nil handler:nil];
//    }
}

/**
 　デバイスが切断された際に呼ばれるデリゲート
 @param peripheral 切断されたデバイスのペリフェラル
 */
- (void)didDisconnectPeripheral:(CBPeripheral *)peripheral{
    [self updateDeviceArrayByPeripheral:peripheral];
}

/**
 　デバイスが切断された際に呼ばれるデリゲート
 @param setting 切断されたデバイスの設定情報
 */
- (void)didDisconnectDevice:(BLEDeviceSetting *)setting {
    //切断
    NSString *message = [NSString stringWithFormat:@"%@が切断されました",setting.name];
        NSLog(@"didDisconnectDevice() %@)",message);
//    if([self.navigationController.topViewController isKindOfClass:[SearchViewController class]]){
//        [self ShowInformMessage_showInformWithMessage:message title:nil okActionName:@"OK" handler:nil cancelActionName:nil handler:nil];
//    }
}

/**
 　デバイス接続に失敗した際に呼ばれるデリゲート
 @param peripheral 接続に失敗したデバイスのペリフェラル
 @param error エラー内容
 */
- (void)didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    //接続に失敗した
    NSLog(@"接続に失敗しました(%@)",peripheral.name);
}

/**
 　RSSI値変更の通知
 @param peripheral 変更されたデバイスのペリフェラル
 @param RSSI 変更されたデバイスのRSSI値
 @param isInRSSIThreshold YESの場合は閾値内へ,NOの場合は閾値外へ遷移したことを示す。
 */
- (void)didDeviceChangeRSSIValue:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI inThreshold:(BOOL)isInRSSIThreshold{
    
}

/**
 　RSSIの取得値が閾値を下回った場合の通知
 @param peripheral 閾値を下回ったデバイスのペリフェラル
 @param RSSI 閾値を下回ったデバイスのRSSI値
 */
- (void)isBelowTheThreshold:(CBPeripheral *)peripheral RSSI:(NSNumber *)RSSI{
    
}

/**
 　受信したアドバタイズ情報の通知
 @param peripheral 受信したデバイスのペリフェラル
 @param data 受信したアドバタイズ情報。接続済みデバイスの場合はnilを返す。
 */
- (void)receivedAdvertisement:(CBPeripheral *)peripheral
                advertisement:(NSDictionary *)data{
    if([[SelectDevice sharedInstance].device.peripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]){
        if (data != nil) {
            //ビーコン情報を追加
            [[SelectDevice sharedInstance] addAdvertisement:data];
        }
    }
}

/**
 　同期状態変更の通知(同期開始)
 @param peripheral 同期開始したデバイスのペリフェラル
 */
- (void)didSyncPeripheralComplete:(CBPeripheral *)peripheral{
    
}

/**
 　同期状態変更の通知(同期終了)
 @param peripheral 同期終了したデバイスのペリフェラル
 */
- (void)didSyncPeripheralFinishComplete:(CBPeripheral *)peripheral{
    
}

/**
 　接続がタイムアウトした場合の通知
 @param peripheral タイムアウトしたデバイスのペリフェラル
 */
- (void)didTimeOutPeripheral:(CBPeripheral *)peripheral{
    
}

/**
 　書き込み処理成功の通知
 @param peripheral 書き込み処理が成功したデバイスのペリフェラル
 */
- (void)didSuccessToWrite:(CBPeripheral *)peripheral{
    
}

/**
 　書き込み処理失敗の通知
 @param peripheral 書き込み処理が失敗したデバイスのペリフェラル
 @param error エラー内容
 */
- (void)didFailToWrite:(CBPeripheral *)peripheral error:(NSError *)error{
    
}

/**
 デバイス情報取得シーケンス完了のデリゲート
 
 デバイス情報取得シーケンスを実行し、デバイス情報の更新完了を通知
 @param peripheral 情報を更新したデバイスのペリフェラル
 */
- (void)didDeviceInitialFinished:(CBPeripheral *)peripheral {
    [self updateDeviceArrayByPeripheral:peripheral];
}

/**
 　デバイス情報取得のデリゲート
 
 プロファイルGetDeviceInformationRespの受信を通知
 @param peripheral 受信したデバイスのペリフェラル
 @param data 受信したデータ
 */
- (void)sendGetDeviceInformationRespData:(CBPeripheral *)peripheral data:(NSData *)data {
    
}

/**
 　デバイス情報取得のデリゲート
 
 プロファイルGetDeviceInformationRespの受信成功を通知
 @param peripheral 受信したデバイスのペリフェラル
 */
- (void)getDeviceInformationRespSuccessDelegate:(CBPeripheral *)peripheral {
    
}

/**
 　デバイス情報取得のデリゲート
 
 プロファイルGetDeviceInformationRespのエラーを通知
 @param peripheral 受信したデバイスのペリフェラル
 @param result 受信したResultCode
 */
- (void)getDeviceInformationRespError:(CBPeripheral *)peripheral result:(char)result{
    // デバイス情報取得 失敗
}

/**
 通知カテゴリ確認のデリゲート
 
 プロファイルConfirmNotifyCategoryRespの受信を通知
 @param peripheral 受信したデバイスのペリフェラル
 @param data 受信したデータ
 */
- (void)sendConfirmNotifyCategoryRespData:(CBPeripheral *)peripheral data:(NSData *)data{
    
}

/**
 通知カテゴリ確認のデリゲート
 
 プロファイルConfirmNotifyCategoryRespの受信成功を通知
 @param peripheral 受信したデバイスのペリフェラル
 */
- (void)confirmNotifyCategoryRespSuccessDelegate:(CBPeripheral *)peripheral {
    
}

/**
 通知カテゴリ確認のデリゲート
 
 プロファイルGetDeviceInformationRespのエラーを通知
 @param peripheral 受信したデバイスのペリフェラル
 @param result 受信したResultCode
 */
- (void)confirmNotifyCategoryRespError:(CBPeripheral *)peripheral result:(char)result {
    // 通知カテゴリ確認 失敗
}

/**
 設定情報取得のデリゲート
 
 プロファイルGetSettingInformationRespの受信を通知
 @param peripheral 受信したデバイスのペリフェラル
 @param data 受信したデータ
 */
- (void)sendGetSettingInformationRespData:(CBPeripheral *)peripheral data:(NSData *)data {
    
}

/**
 設定情報取得のデリゲート
 
 プロファイルGetSettingInformationRespの受信成功を通知
 @param peripheral 受信したデバイスのペリフェラル
 */
- (void)getSettingInformationRespSuccessDelegate:(CBPeripheral *)peripheral {
    
}

/**
 設定情報取得のデリゲート
 
 プロファイルGetSettingInformationRespのエラーを通知
 @param peripheral 受信したデバイスのペリフェラル
 @param result 受信したResultCode
 */
- (void)getSettingInformationRespError:(CBPeripheral *)peripheral result:(char)result {
    
}

/**
 設定名称取得のデリゲート
 
 プロファイルGetSettingNameRespの受信を通知
 @param peripheral 受信したデバイスのペリフェラル
 @param data 受信したデータ
 */
- (void)sendGetSettingNameRespData:(CBPeripheral *)peripheral data:(NSData *)data {
    
}

/**
 設定名称取得のデリゲート
 
 プロファイルGetSettingNameRespの受信成功を通知
 @param peripheral 受信したデバイスのペリフェラル
 */
- (void)getSettingNameRespSuccessDelegate:(CBPeripheral *)peripheral {
    
}

/**
 設定名称取得のデリゲート
 
 プロファイルGetSettingNameRespのエラーを通知
 @param peripheral 受信したデバイスのペリフェラル
 @param result 受信したResultCode
 */
- (void)getSettingNameRespError:(CBPeripheral *)peripheral result:(char)result {
    
}

/**
 設定情報選択のデリゲート
 
 プロファイルSelectSettingInformationRespの受信を通知
 @param peripheral 受信したデバイスのペリフェラル
 @param data 受信したデータ
 */
- (void)sendSelectSettingInformationRespData:(CBPeripheral *)peripheral data:(NSData *)data {
    
}

/**
 設定情報選択のデリゲート
 
 プロファイルSelectSettingInformationRespの受信成功を通知
 @param peripheral 受信したデバイスのペリフェラル
 */
- (void)sendSelectSettingInformationRespSuccessDelegate:(CBPeripheral *)peripheral {
    
}

/**
 設定情報選択のデリゲート
 
 プロファイルSelectSettingInformationRespのエラーを通知
 @param peripheral 受信したデバイスのペリフェラル
 @param result 受信したResultCode
 */
- (void)selectSettingInformationRespError:(CBPeripheral *)peripheral result:(char)result {
    
}

/**
 通知詳細情報の取得応答のデリゲート
 
 プロファイルGetPdNotifyDetailDataRespの受信を通知
 @param peripheral 受信したデバイスのペリフェラル
 @param data 受信したデータ
 */
- (void)sendGetPdNotifyDetailDataRespData:(CBPeripheral *)peripheral data:(NSData *)data {
    
}

/**
 通知詳細情報の取得のデリゲート
 
 プロファイルGetPdNotifyDetailDataの受信を通知
 @param peripheral 取得したデバイスのペリフェラル
 @param paramKey   取得したいパラメータID識別キー
 */
- (void)sendGetPdNotifyDetailDataSuccessDelegate:(CBPeripheral *)peripheral paramKey:(NSString *)paramKey {
    
}

/**
 周辺機器からの汎用情報通知のデリゲート
 
 プロファイルNotifyPdGeneralInformationの受信を通知
 @param peripheral   受信したデバイスのペリフェラル
 @param receiveArray 受信したデータ
 */
- (void)sendNotifyPdGeneralInformationSuccessDelegate:(CBPeripheral *)peripheral receiveArray:(NSMutableArray *)receiveArray {
    
}

/**
 周辺機器からのアプリケーション起動のデリゲート
 
 プロファイルStartPdApplicationの受信を通知
 @param peripheral   受信したデバイスのペリフェラル
 */
- (void)sendStartPdApplicationSuccessDelegate:(CBPeripheral *)peripheral result:(Byte)result {
    
}

/**
 周辺機器からのアプリケーション起動のデリゲート
 
 プロファイルStartPdApplicationRespの受信を通知
 @param peripheral 受信したデバイスのペリフェラル
 @param data 受信したデータ
 */
- (void)sendStartPdApplicationRespData:(CBPeripheral *)peripheral data:(NSData *)data {
    
}

/**
 センサー情報通知設定のデリゲート
 
 プロファイルSetNotifySensorInfoRespの受信を通知
 @param peripheral 受信したデバイスのペリフェラル
 @param data 受信したデータ
 */
- (void)sendSetNotifySensorInfoRespData:(CBPeripheral *)peripheral data:(NSData *)data {
    
}

/**
 センサー情報通知設定のデリゲート
 
 プロファイルSetNotifySensorInfoRespの受信成功を通知
 @param peripheral 受信したデバイスのペリフェラル
 */
- (void)setNotifySensorInfoRespSuccessDelegate:(CBPeripheral *)peripheral {
    
}

/**
 センサー情報通知設定のデリゲート
 
 プロファイルSetNotifySensorInfoRespのエラーを通知
 @param peripheral 受信したデバイスのペリフェラル
 @param result 受信したResultCode
 */
- (void)setNotifySensorInfoRespError:(CBPeripheral *)peripheral result:(char)result{
        NSLog(@"失敗:%hhu",result);
}

/**
 デバイス操作通知のデリゲート
 
 プロファイルNotifyPdOperationの受信を通知
 @param peripheral 受信したデバイスのペリフェラル
 @param buttonID 受信したbuttonID
 */
- (void)deviceButtonPushed:(CBPeripheral *)peripheral buttonID:(char)buttonID{
    NSLog(@"デバイス操作通知: %@",[NSString stringWithFormat:@"%@",[NSNumber numberWithChar:buttonID]]);
}

/**
 設定時間超過の為,ジャイロセンサーの取得終了を通知
 @param peripheral 終了したデバイスのペリフェラル
 */
- (void)gyroscopeObservationEnded:(CBPeripheral *)peripheral {
    
}

/**
 設定時間超過の為,加速センサーの取得終了を通知
 @param peripheral 終了したデバイスのペリフェラル
 */
- (void)accelerometerObservationEnded:(CBPeripheral *)peripheral{
    NSLog(@"センサー観測完了");
}

/**
 設定時間超過の為,方位センサーの取得終了を通知
 @param peripheral 終了したデバイスのペリフェラル
 */
- (void)orientationObservationEnded:(CBPeripheral *)peripheral{
    NSLog(@"センサー観測完了");
}

/**
 設定時間超過の為,電池残量の取得終了を通知
 @param peripheral 終了したデバイスのペリフェラル
 */
- (void)batteryPowerObservationEnded:(CBPeripheral *)peripheral{
    NSLog(@"センサー観測完了");
}

/**
 設定時間超過の為,温度センサーの取得終了を通知
 @param peripheral 終了したデバイスのペリフェラル
 */
- (void)temperatureObservationEnded:(CBPeripheral *)peripheral{
    NSLog(@"センサー観測完了");
}

/**
 設定時間超過の為,湿度センサーの取得終了を通知
 @param peripheral 終了したデバイスのペリフェラル
 */
- (void)humidityObservationEnded:(CBPeripheral *)peripheral{
    NSLog(@"センサー観測完了");
}

/**
 設定時間超過の為,気圧センサーの取得終了を通知
 @param peripheral 終了したデバイスのペリフェラル
 */
- (void)atmosphericPressureObservationEnded:(CBPeripheral *)peripheral{
    NSLog(@"センサー観測完了");
}

/**
 ジャイロセンサーの取得を通知
 
 プロファイルNotifyPdSensorInfoの受信を通知
 @param peripheral 取得したデバイスのペリフェラル
 @param sensor 取得したデバイスのセンサーデータ
 */
- (void)gyroscopeDidUpDateDelegate:(CBPeripheral *)peripheral sensor:(BLESensorGyroscope *)sensor {
    
}

/**
 設定された間隔でのジャイロセンサーの取得を通知
 
 @param peripheral 取得したデバイスのペリフェラル
 @param sensor 取得したデバイスのセンサーデータ
 */
- (void)gyroscopeDidUpDateWithIntervalDelegate:(CBPeripheral *)peripheral sensor:(BLESensorGyroscope *)sensor {
    
}

/**
 ジャイロセンサーの取得を通知
 
 プロファイルNotifyPdSensorInfoの受信を通知
 @param peripheral 取得したデバイスのペリフェラル
 */
- (void)gyroscopeDidUpDateDelegate:(CBPeripheral *)peripheral {
    
}

/**
 加速センサーの取得を通知
 
 プロファイルNotifyPdSensorInfoの受信を通知
 @param peripheral 取得したデバイスのペリフェラル
 @param sensor 取得したデバイスのセンサーデータ
 */
- (void)accelerometerDidUpDateDelegate:(CBPeripheral *)peripheral sensor:(BLESensorAccelerometer *)sensor {
    
}

/**
 設定された間隔での加速センサーの取得を通知
 
 @param peripheral 取得したデバイスのペリフェラル
 @param sensor 取得したデバイスのセンサーデータ
 */
- (void)accelerometerDidUpDateWithIntervalDelegate:(CBPeripheral *)peripheral sensor:(BLESensorAccelerometer *)sensor {
    //加速センサーの通知
}

/**
 加速センサーの取得を通知
 
 プロファイルNotifyPdSensorInfoの受信を通知
 @param peripheral 取得したデバイスのペリフェラル
 */
- (void)accelerometerDidUpDateDelegate:(CBPeripheral *)peripheral {
    
}

/**
 方位センサーの取得を通知
 
 プロファイルNotifyPdSensorInfoの受信を通知
 @param peripheral 取得したデバイスのペリフェラル
 @param sensor 取得したデバイスのセンサーデータ
 */
- (void)orientationDidUpDateDelegate:(CBPeripheral *)peripheral sensor:(BLESensorOrientation *)sensor{
    
}

/**
 設定された間隔での方位センサーの取得を通知
 
 @param peripheral 取得したデバイスのペリフェラル
 @param sensor 取得したデバイスのセンサーデータ
 */
- (void)orientationDidUpDateWithIntervalDelegate:(CBPeripheral *)peripheral sensor:(BLESensorOrientation *)sensor {
    
}

/**
 方位センサーの取得を通知
 
 プロファイルNotifyPdSensorInfoの受信を通知
 @param peripheral 取得したデバイスのペリフェラル
 */
- (void)orientationDidUpDateDelegate:(CBPeripheral *)peripheral; {
    
}

/**
 電池残量の取得を通知
 
 プロファイルNotifyPdSensorInfoの受信を通知
 @param peripheral 取得したデバイスのペリフェラル
 @param sensor 取得したデバイスのセンサーデータ
 */
- (void)batteryPowerDidUpDateDelegate:(CBPeripheral *)peripheral sensor:(BLESensorBatteryPower *)sensor {
    
}

/**
 設定された間隔での電池残量の取得を通知
 
 @param peripheral 取得したデバイスのペリフェラル
 @param sensor 取得したデバイスのセンサーデータ
 */
- (void)batteryPowerDidUpDateWithIntervalDelegate:(CBPeripheral *)peripheral sensor:(BLESensorBatteryPower *)sensor {
    
}

/**
 電池残量の取得を通知
 
 プロファイルNotifyPdSensorInfoの受信を通知
 @param peripheral 取得したデバイスのペリフェラル
 */
- (void)batteryPowerDidUpDateDelegate:(CBPeripheral *)peripheral {
    
}

/**
 温度センサーの取得を通知
 
 プロファイルNotifyPdSensorInfoの受信を通知
 @param peripheral 取得したデバイスのペリフェラル
 @param sensor 取得したデバイスのセンサーデータ
 */
- (void)temperatureDidUpDateDelegate:(CBPeripheral *)peripheral sensor:(BLESensorTemperature *)sensor {
    
}

/**
 設定された間隔での温度センサーの取得を通知
 
 @param peripheral 取得したデバイスのペリフェラル
 @param sensor 取得したデバイスのセンサーデータ
 */
- (void)temperatureDidUpDateWithIntervalDelegate:(CBPeripheral *)peripheral sensor:(BLESensorTemperature *)sensor {
    
}

/**
 温度センサーの取得を通知
 
 プロファイルNotifyPdSensorInfoの受信を通知
 @param peripheral 取得したデバイスのペリフェラル
 */
- (void)temperatureDidUpDateDelegate:(CBPeripheral *)peripheral {
    
}

/**
 湿度センサーの取得を通知
 
 プロファイルNotifyPdSensorInfoの受信を通知
 @param peripheral 取得したデバイスのペリフェラル
 @param sensor 取得したデバイスのセンサーデータ
 */
- (void)humidityDidUpDateDelegate:(CBPeripheral *)peripheral sensor:(BLESensorHumidity *)sensor {
    
}

/**
 設定された間隔での湿度センサーの取得を通知
 
 @param peripheral 取得したデバイスのペリフェラル
 @param sensor 取得したデバイスのセンサーデータ
 */
- (void)humidityDidUpDateWithIntervalDelegate:(CBPeripheral *)peripheral sensor:(BLESensorHumidity *)sensor {
    
}

/**
 湿度センサーの取得を通知
 
 プロファイルNotifyPdSensorInfoの受信を通知
 @param peripheral 取得したデバイスのペリフェラル
 */
- (void)humidityDidUpDateDelegate:(CBPeripheral *)peripheral {
    
}

/**
 気圧センサーの取得を通知
 
 プロファイルNotifyPdSensorInfoの受信を通知
 @param peripheral 取得したデバイスのペリフェラル
 @param sensor 取得したデバイスのセンサーデータ
 */
- (void)atmosphericPressureDidUpDateDelegate:(CBPeripheral *)peripheral sensor:(BLESensorAtmosphericPressure *)sensor {
    
}

/**
 設定された間隔での気圧センサーの取得を通知
 
 @param peripheral 取得したデバイスのペリフェラル
 @param sensor 取得したデバイスのセンサーデータ
 */
- (void)atmosphericPressureDidUpDateWithIntervalDelegate:(CBPeripheral *)peripheral sensor:(BLESensorAtmosphericPressure *)sensor {
    
}

/**
 気圧センサーの取得を通知
 
 プロファイルNotifyPdSensorInfoの受信を通知
 @param peripheral 取得したデバイスのペリフェラル
 */
- (void)atmosphericPressureDidUpDateDelegate:(CBPeripheral *)peripheral {
    
}

/**
 スキャン間隔変更APIの完了通知
 */
- (void)changePartialScanIntervalSuccessDelegate {
    
}

/**
 スキャン間隔変更APIのエラー通知
 @param error エラー
 */
- (void)changePartialScanIntervalError:(NSError *)error {
    
}

/**
 ビーコンスキャン開始通知
 */
- (void)startPartialScanDelegate {
    NSLog(@"ビーコンスキャン開始通知");
}

/**
 * ビーコンスキャンのタイムアウトの通知
 */
- (void)partialScanTimeOutDelegate {
     NSLog(@"ビーコンスキャンのタイムアウト");
}

/**
 ビーコンスキャンのBluetooth接続エラー通知
 @param error エラー
 */
- (void)connectBluetoothWhenPartialScanError:(NSError *)error {
    NSLog(@"ビーコンスキャンのBluetooth接続エラー通知");
}

/**
 ビーコンスキャン開始時のBluetooth接続エラー通知
 @param error エラー
 */
- (void)connectBluetoothWhenStartPartialScanError:(NSError *)error{
    NSLog(@"ビーコンスキャン開始時のBluetooth接続エラー通知");
}

@end
