//
//  StatisticsCollector.h
//  TextTwistGame
//
//  Created by Log n Labs on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StatisticsCollector : NSObject {
    
}

+(void)trackApplicationError:(NSString*)errorName andMessage:(NSString*)msg andException:(NSException*)e;
+(void)logEvent:(NSString*)eventName;
+(void)startSession:(NSString*)sessionId;
+(void)logEvent:(NSString*)eventName withParameters:(NSDictionary*)parameters;
+(void)logEvent:(NSString*)eventName timed:(BOOL)timed;
+(void)logEvent:(NSString*)eventName withParameters:(NSDictionary*)parameters timed:(BOOL)timed;
+(void)endTimedEvent:(NSString*)eventName  withParameters:(NSDictionary*)parameters;

@end
