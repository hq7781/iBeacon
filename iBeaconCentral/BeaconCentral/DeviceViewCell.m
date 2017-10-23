//
//  DeviceViewCell.m
//  iBeaconCentral
//
//  Created by TAKEDA Masanori on 2017/10/20.
//  Copyright © 2017年 grandbig.github.io. All rights reserved.
//

#import "DeviceViewCell.h"

@implementation DeviceViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if (self) {
        //self.label.text = NSStringFromClass([self class]);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
