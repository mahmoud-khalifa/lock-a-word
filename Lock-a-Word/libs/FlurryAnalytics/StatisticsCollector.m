//
//  StatisticsCollector.m
//  TextTwistGame
//
//  Created by Log n Labs on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatisticsCollector.h"
#import "FlurryAnalytics.h"

@implementation StatisticsCollector

+(void)startSession:(NSString*)sessionId{
    [FlurryAnalytics startSession:sessionId];

}

+(void)logEvent:(NSString*)eventName{
    [FlurryAnalytics logEvent:eventName];
}

+(void)trackApplicationError:(NSString*)errorName andMessage:(NSString*)msg andException:(NSException*)e{
    [FlurryAnalytics logError:errorName message:msg exception:e];
}


+(void)logEvent:(NSString*)eventName withParameters:(NSDictionary*)parameters{
    [FlurryAnalytics logEvent:eventName withParameters:parameters];
}

+(void)logEvent:(NSString*)eventName timed:(BOOL)timed{

    [FlurryAnalytics logEvent:eventName timed:timed];
}

+(void)logEvent:(NSString*)eventName withParameters:(NSDictionary*)parameters timed:(BOOL)timed{
    [FlurryAnalytics logEvent:eventName withParameters:parameters timed:timed];
}

+(void)endTimedEvent:(NSString*)eventName  withParameters:(NSDictionary*)parameters{

    [FlurryAnalytics endTimedEvent:eventName withParameters:parameters];
}
@end
