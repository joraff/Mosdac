//
//  DeployStudioHelper.h
//  Mosdac
//
//  Created by Joseph Rafferty on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeployStudioHelper : NSObject

+ (NSMutableDictionary *)getDictionaryWithIdentifier:(NSString *)id;

+ (void)updateIdentifier:(NSString *)id withDictionary:(NSMutableDictionary *)dict;

+ (NSString *)getEncodedAuthValue;

@end
