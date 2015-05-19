//
//  WatcherTableViewCell.h
//  VideoWatcher
//
//  Created by almakaev iliyas on 19/05/15.
//  Copyright (c) 2015 almakaev iliyas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WatcherTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameCell;
@property (weak, nonatomic) IBOutlet UILabel *descriptCell;
@property (weak, nonatomic) IBOutlet UILabel *timeCell;
@property (weak, nonatomic) IBOutlet UIImageView *imageCell;

@end
