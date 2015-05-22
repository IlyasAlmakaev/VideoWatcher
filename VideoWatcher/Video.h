//
//  Video.h
//  VideoWatcher
//
//  Created by intent on 21/05/15.
//  Copyright (c) 2015 almakaev iliyas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Video : NSManagedObject

@property (nonatomic, retain) NSString * descript;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * poster;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSNumber * select;
@property (nonatomic, retain) NSString * reference;

@end
