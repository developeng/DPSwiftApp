//
//  WHBluetooth.m
//  WeiHong
//
//  Created by developeng on 2021/8/23.
//

#import "WHBluetooth.h"
#import "HLBLEManager.h"

@interface WHBluetooth(){
    Boolean flag;
}

@property (strong, nonatomic)   NSMutableArray    *deviceArray;  /**< 蓝牙设备个数 */
@property (strong, nonatomic)   NSMutableArray    *infos;  /**< 详情数组 */
@property (strong, nonatomic)   CBCharacteristic  *chatacter;  /**< 可写入数据的特性 */

@property(nonatomic, assign) BOOL  isShowTip;  //是否需要弹窗提示
@property(nonatomic, assign) BOOL  isPrintNow;  //标记入口，连接后是否立即打印
@property(nonatomic, assign) HLOptionStage optionStage;

@end

@implementation WHBluetooth
static WHBluetooth *instance = nil;

- (NSMutableArray *)deviceArray{
    
    if (!_deviceArray) {
        _deviceArray = [NSMutableArray array];
    }
    return  _deviceArray;
}

-(NSMutableArray *)infos {
    if (!_infos) {
        _infos = [NSMutableArray array];
    }
    return  _infos;
}

+ (instancetype)shared
{
    return [[self alloc] init];
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super init];
        
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

-(void)initBluetooth{
    [self.deviceArray removeAllObjects];
    HLBLEManager *manager = [HLBLEManager sharedInstance];
    [manager reconnect];
    __weak HLBLEManager *weakManager = manager;
    manager.stateUpdateBlock = ^(CBCentralManager *central) {
        switch (central.state) {
            case CBManagerStatePoweredOn:
                self.bleState = WHManagerStateStartScan;
                //APP一定已经授权,并且蓝牙已经开启
                [self startScane];
                [self postNotification];
                [weakManager scanForPeripheralsWithServiceUUIDs:nil options:nil];
                break;
            case CBManagerStatePoweredOff:
                self.bleState = WHManagerStatePoweredOff;
                [self postNotification];
                break;
            case CBManagerStateUnsupported:
                //未知状态,重置状态,不支持状态
                self.bleState = WHManagerStateUnsupported;
                break;
            case CBManagerStateUnauthorized:
                // app一定未授权,蓝牙是否开启不知  (两个弹窗)
                self.bleState = WHManagerStateUnauthorized;
                [self postNotification];
                [WHTips alertTipWithTitle:@"请注意" detail:@"添加蓝牙打印需要在手机【设置】\n中开启蓝牙。" itemTitle:@"开启蓝牙" block:^(NSInteger index) {
                    
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                }];
                break;
            case CBManagerStateResetting:
                self.bleState = WHManagerStateResetting;
                break;
            case CBManagerStateUnknown:
                self.bleState = WHManagerStateUnknown;
                break;
        }
    };
}

- (void)postNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:BLE_STATE object:@{@"state":@(self.bleState)}];
}

-(void)startScane {
    HLBLEManager *manager = [HLBLEManager sharedInstance];
    manager.discoverPeripheralBlcok = ^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        if (peripheral.name.length <= 0) {
            return ;
        }
        
        if (![peripheral.name localizedCaseInsensitiveContainsString:@"printer"]) {
            return;
        }
        
        if (self.deviceArray.count == 0) {
            NSDictionary *dict = @{@"peripheral":peripheral, @"RSSI":RSSI};
            [self.deviceArray addObject:dict];
        } else {
            BOOL isExist = NO;
            for (int i = 0; i < self.deviceArray.count; i++) {
                NSDictionary *dict = [self.deviceArray objectAtIndex:i];
                CBPeripheral *per = dict[@"peripheral"];
                if ([per.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                    isExist = YES;
                    NSDictionary *dict = @{@"peripheral":peripheral, @"RSSI":RSSI};
                    [self->_deviceArray replaceObjectAtIndex:i withObject:dict];
                }
            }
            if (!isExist) {
                NSDictionary *dict = @{@"peripheral":peripheral, @"RSSI":RSSI};
                [self.deviceArray addObject:dict];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:BLE_UPDATEDEVICE object:self.deviceArray];
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:BLE_UPDATEDEVICE object:self.deviceArray];
}

//连接打印机
-(void)connectPrinter:(CBPeripheral *)peripheral{
    self.isPrintNow = NO;
    flag = YES;
    [self loadBLEInfo:peripheral];
}

- (void)loadBLEInfo:(CBPeripheral *)peripheral{
    [self.infos removeAllObjects];
    self.chatacter = nil;
    HLBLEManager *manager = [HLBLEManager sharedInstance];
    [manager connectPeripheral:peripheral
                connectOptions:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@(YES)}
        stopScanAfterConnected:YES
               servicesOptions:nil
        characteristicsOptions:nil
                 completeBlock:^(HLOptionStage stage, CBPeripheral *peripheral, CBService *service, CBCharacteristic *character, NSError *error) {
        
        self.optionStage = stage;
                     switch (stage) {
                         case HLOptionStageConnectionStart:{
                             [WHToast showTipAnimated:@"开始连接设备" :5];
                           
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                 if (self.optionStage == HLOptionStageConnectionStart) {
                                     [WHToast hideAnimated];
                                     [WHToast show_fail:@"打印机连接失败"];
                                     [manager cancelPeripheralConnection];
                                     [self selectPrinter];
                                 }
                             });
                             break;
                         }
                         case HLOptionStageConnectionSuccess:{
                             self->_connectedPerpheral = peripheral;
                             
                             
                             [self setDeviceUUID];
                             [WHToast hideAnimated];
                             
                             if (self.isShowTip) {
                                 [WHToast show_success:@"打印机连接成功"];
                             }
                             if (self.printerData == nil || self.isPrintNow == NO) {
                                 [self setupPrinter];
                             }
                             break;
                         }
                         case HLOptionStageConnectionFial:{
                             [WHToast hideAnimated];
                             if (self.isShowTip) {
                                 [WHToast show_fail:@"打印机连接失败"];
                             }
                             if (self.printerData == nil) {
                                 [self selectPrinter];
                             }
                             break;
                         }
                         case HLOptionStageSeekServices:{
                             if (error) {
                                 if (self.isShowTip) {
                                     [WHToast show_fail:@"查找服务失败"];
                                 }
                             } else {
                                 [self->_infos addObjectsFromArray:peripheral.services];
                                 [self checkService];
                             }
                             break;
                         }
                         case HLOptionStageSeekCharacteristics:
                         {
                             // 该block会返回多次，每一个服务返回一次
                             if (error) {
                                 NSLog(@"查找特性失败");
                             } else {
                                 NSLog(@"查找特性成功");
                                 [self checkService];
                             }
                             break;
                         }
                         case HLOptionStageSeekdescriptors:{
                             // 该block会返回多次，每一个特性返回一次
                             if (error) {
                                 NSLog(@"查找特性的描述失败");
                             } else {
                                 //                                 NSLog(@"查找特性的描述成功");
                             }
                             break;
                         }
                         default:
                             break;
                     }
    }];
}


-(void)checkService{
    for (int i=0; i<[_infos count]; i++) {
        CBService *service = _infos[i];
        for (int j=0; j<service.characteristics.count; j++) {
            CBCharacteristic *character = [service.characteristics objectAtIndex:j];
            CBCharacteristicProperties properties = character.properties;
            /**
             CBCharacteristicPropertyWrite和CBCharacteristicPropertyWriteWithoutResponse类型的特性都可以写入数据
             但是后者写入完成后，不会回调写入完成的代理方法{peripheral:didWriteValueForCharacteristic:error:},
             因此，你也不会受到block回调。
             所以首先考虑使用CBCharacteristicPropertyWrite的特性写入数据，如果没有这种特性，再考虑使用后者写入吧。
             */
            //
            if (properties & CBCharacteristicPropertyWrite) {
                self.chatacter = character;
                if (self.isPrintNow) {
                    [self startPrint];//找到服务进行打印
                }
                return;
            }
        }
    }
//    [WHToast show_fail:@"未搜索到打印服务"];
}

-(void)startPrint{

    if (!self.isClickPrint) {
        return;
    }
    if(!flag){
        return;
    }
    flag=NO;
    if(self.chatacter==nil){
        [WHToast showTipAnimated:@"正在搜索打印服务" :5];
        return;
    }
    
    if (self.printerData == nil) {
        return;
    }
    
    NSData *mainData = self.printerData;
    HLBLEManager *bleManager = [HLBLEManager sharedInstance];
    if (self.chatacter.properties & CBCharacteristicPropertyWrite) {
        [bleManager writeValue:mainData forCharacteristic:self.chatacter type:CBCharacteristicWriteWithResponse completionBlock:^(CBCharacteristic *characteristic, NSError *error) {
            if (!error) {
                NSLog(@"写入成功");
            }else{
                [self selectPrinter];
            }
        }];
    } else if (self.chatacter.properties & CBCharacteristicPropertyWriteWithoutResponse) {
        [bleManager writeValue:mainData forCharacteristic:self.chatacter type:CBCharacteristicWriteWithoutResponse];
    }
}

-(void)stopScan{
//    [Manager stopScan];
    self.bleState = WHManagerStateStopScan;
    [self postNotification];
}

- (void)close {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LastTimeConnectId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[HLBLEManager sharedInstance] close];
}

//判断状态(是否已连接打印机)
- (BOOL)isConnectedPrinter{
    
    if ([self getDeviceUUID]) {
        CBPeripheral *peri =  [[HLBLEManager sharedInstance] getPeripheralWithUUID:[self getDeviceUUID]];
        if(peri != nil && peri.state == CBPeripheralStateConnected){
            return YES;
        }
    }
    return  NO;
}

//跳转蓝牙打印机
- (void)goToPrinter:(BOOL)isPrint{
    self.isPrintNow = isPrint;
    flag = YES;
    self.isClickPrint = isPrint;
    if (!isPrint) {
        self.printerData = nil;
    }
    
    if (self.bleState != WHManagerStateStartScan &&
        self.bleState != WHManagerStateStopScan  &&
        self.bleState != WHManagerStateUnknown) {
        [self.deviceArray removeAllObjects];
        [self selectPrinter];
        return;
    }
    
    if (self.deviceArray.count <= 0) {
        [self initBluetooth];
        [WHToast showTipAnimated:@"打印机连接中..." :3];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self connectFormerPrinter:isPrint];
        });
    } else {
        [self connectFormerPrinter:isPrint];
    }
}


//连接之前的蓝牙设备
- (void)connectFormerPrinter:(BOOL)isPrint{
    NSUUID *selUUID = [self getDeviceUUID];
    if (selUUID != nil) {
        //上次链接的蓝牙设备是否在范围内
        __block BOOL isInRange = NO;
        [self.deviceArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CBPeripheral *peripheral = obj[@"peripheral"];
            if ([peripheral.identifier.UUIDString isEqualToString: selUUID.UUIDString]){
                isInRange = YES;
                *stop = YES;
            }
        }];
        
        if (isInRange) {
            self.isShowTip = NO;
            CBPeripheral *peri =  [[HLBLEManager sharedInstance] getPeripheralWithUUID:selUUID];
            if(peri != nil){
                if (peri.state == CBPeripheralStateConnected) {
                    if (isPrint) {
                        //开始打印
                        [self startPrint];
                    } else {
                        //到设置界面
                        [self setupPrinter];
                    }
                } else {
                    [self loadBLEInfo:peri];//判断是否支持服务
                }
                return;
            } else {
                CBPeripheral *peri =  [[HLBLEManager sharedInstance] getPeripheralWithUUID:selUUID];
                if(peri != nil){
                    if (peri.state == CBPeripheralStateConnected) {
                        if (isPrint) {
                            //开始打印
                            [self startPrint];
                        } else {
                            //到设置界面
                            [self setupPrinter];
                        }
                    } else {
                        [self loadBLEInfo:peri];//判断是否支持服务
                    }
                    return;
                }
            }
        }
    }
    [self selectPrinter];
}

//到选择界面
- (void)selectPrinter{
    //到选择界面
    self.isShowTip = YES;
    UIViewController *currentVC = [WHRouter currentVC];
    WHBleSelectController *vc = [[WHBleSelectController alloc] init];
    if ([currentVC isKindOfClass:[vc classForCoder]]) {
        return;
    }
    [[WHRouter currentVC].navigationController pushViewController:vc animated:true];
}

//到设置界面
- (void)setupPrinter{
    UIViewController *currentVC = [WHRouter currentVC];
    WHBleSetupController *vc = [[WHBleSetupController alloc] init];
    if ([currentVC isKindOfClass:[vc classForCoder]]) {
        return;
    }
    [[WHRouter currentVC].navigationController pushViewController:vc animated:true];
}

- (void)setDeviceUUID{
    [[NSUserDefaults standardUserDefaults] setObject:self.connectedPerpheral.identifier.UUIDString forKey:LastTimeConnectId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUUID *)getDeviceUUID{
    NSString *connectId = [[NSUserDefaults standardUserDefaults] objectForKey:LastTimeConnectId];
    return [[NSUUID UUID]initWithUUIDString: connectId];
}

@end

