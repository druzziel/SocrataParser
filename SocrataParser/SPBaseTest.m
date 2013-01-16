//
//  SPBaseTest.m
//  SocrataParser
//
//  Created by David Roth on 1/5/13.
//  Copyright (c) 2013 David Roth. All rights reserved.
//

#import "SPBaseTest.h"
#import "SPSocrataDataProvider.h"

@implementation SPBaseTest

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testInitWithDataSetString
{
    SPSocrataDataProvider *dataProvider = [[SPSocrataDataProvider alloc] initWithDataSetString:@"kzjm-xkqj"];
    // kzjm-xkqj is the real-time 911 calls db.  Having initialized with that string, the URL that the dataProvider
    // uses to fetch data should be
    NSLog(@"%@", [dataProvider stringForJSONURL]);
}

@end
