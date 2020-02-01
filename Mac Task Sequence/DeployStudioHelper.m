//
//  DeployStudioHelper.m
//  Mosdac
//
//  Created by Joseph Rafferty on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DeployStudioHelper.h"
#import "Constants.h"
#import "Base64.h"

@implementation DeployStudioHelper

+ (NSMutableDictionary *)getDictionaryWithIdentifier:(NSString *)id
{
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%@/computers/get/entry?id=%@", DSServerName, DSServerPort, id];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] 
                                    initWithURL:[NSURL 
                                                 URLWithString:urlString]];
    
    
    [request setValue:[self getEncodedAuthValue] forHTTPHeaderField:@"Authorization"];
    
    NSURLResponse *response;  
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];    
        
    NSPropertyListFormat format;
    
    NSMutableDictionary *plist = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:nil];
    
    NSMutableDictionary *inner = [plist objectForKey:id];
    
    return inner;
}

+ (void)updateIdentifier:(NSString *)id withDictionary:(NSMutableDictionary *)dict
{
    // Convert dictionary into plist-style string
    NSString *plistString = [[dict description] propertyList];
    
    // Convert plist-style string into data
    NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;
    NSString *error;
    NSData *newPlistData = [NSPropertyListSerialization dataFromPropertyList:plistString format:format errorDescription:&error];
    
    NSString *xml = [[NSString alloc] initWithData:newPlistData encoding:NSUTF8StringEncoding];
    
    NSString *postURLString = [NSString stringWithFormat:@"http://%@:%@/computers/set/entry?id=%@", DSServerName, DSServerPort, id];
    NSURL *postURL = [NSURL URLWithString:postURLString];
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:postURL];
    
    // Set Headers
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setValue:[self getEncodedAuthValue] forHTTPHeaderField:@"Authorization"];
    [postRequest setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    
    // Set Body content
    [postRequest setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];

    NSError *postError;
    NSURLResponse *postResponse;
    [NSURLConnection sendSynchronousRequest:postRequest returningResponse:&postResponse error:&postError];
}

+ (NSString *)getEncodedAuthValue
{
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", DSServerUsername, DSServerPassword];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [Base64 encode:authData]];
    return authValue;
}
@end
