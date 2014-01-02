//
//  FirmataCell.h
//  iosFirmata
//
//  Created by Jacob on 11/25/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirmataCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *modeButton;
@property (strong, nonatomic) IBOutlet UILabel* value;
@property (strong, nonatomic) IBOutlet UILabel* name;

@end
