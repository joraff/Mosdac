//
//  Building.h
//  Mac Task Sequence
//
//  Created by Joseph Rafferty on 5/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Building : NSObject
{
    NSString *value;
    NSString *name;
    NSString *number;
    
    NSMutableDictionary *rooms;
}

- (Building *) init;
- (Building *) initWithArray:(NSArray *)line;

- (NSString *) description;

- (NSArray *) roomsArray;

@property (nonatomic, retain) NSString *value, *name, *number;
@property (nonatomic, retain) NSMutableDictionary *rooms;

@end

//AGLS|Agriculture and Life Sciences|1535|IMS;OAL|AGLS|WCL-APPS