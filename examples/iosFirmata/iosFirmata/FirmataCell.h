//
//  FirmataCell.h
//  iosFirmata
//
//  Created by Jacob on 11/11/13.
//  Copyright (c) 2013 Augmetous Inc.
//

#import <UIKit/UIKit.h>

@interface FirmataCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *modeButton;
@property (weak, nonatomic) IBOutlet UILabel *buttonLabel;
@property (strong, nonatomic) IBOutlet UILabel* value;
@property (strong, nonatomic) IBOutlet UILabel* name;

@end
