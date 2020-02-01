//
//  Room.h
//  Mac Task Sequence
//
//  Created by Joseph Rafferty on 5/17/12.
//  Copyright (c) 2012 Texas A&M University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Room : NSObject
{
    NSString *number;
    NSString *type;
}

- (Room *) init;
- (Room *) initWithArray:(NSArray *)line;

- (NSString *) description;

@property (readwrite, retain) NSString *number, *type;

@end
