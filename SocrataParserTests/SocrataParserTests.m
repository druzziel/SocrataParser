//
//  SocrataParserTests.m
//  SocrataParserTests
//
//  Created by David Roth on 1/6/13.
//  Copyright (c) 2013 David Roth. All rights reserved.
//

#import "SocrataParserTests.h"
#import "SPSocrataDataProvider.h"

@implementation SocrataParserTests

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

-(void)testSPSocrataDataProvider
{
    SPSocrataDataProvider *myProvider = [SPSocrataDataProvider parserWithDataSetString:@"aaaa-yyyy"];
    STAssertTrue([myProvider isKindOfClass:[SPSocrataDataProvider class]], @"myProvider is a SPSocrataDataProvider");
    
}

-(void)testLoadNYCData
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *myURL = [bundle URLForResource:@"ny_wifi_hotspots" withExtension:@"json"];
    NSData *inputData = [NSData dataWithContentsOfURL:myURL];

    SPSocrataDataProvider *nycProvider = [SPSocrataDataProvider parserWithData:inputData];
    STAssertTrue([nycProvider isKindOfClass:[SPSocrataDataProvider class]], @"nycProvider should be a SPSocrataDataProvider");
    
}

-(void)testLoadAustinData
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *myURL = [bundle URLForResource:@"austin_restaurants" withExtension:@"json"];
    NSData *inputData = [NSData dataWithContentsOfURL:myURL];
    
    SPSocrataDataProvider *nycProvider = [SPSocrataDataProvider parserWithData:inputData];
    STAssertTrue([nycProvider isKindOfClass:[SPSocrataDataProvider class]], @"nycProvider should be a SPSocrataDataProvider");
    
}

-(void)testLoadSeattleData
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *myURL = [bundle URLForResource:@"seattle_code_violations" withExtension:@"json"];
    NSData *inputData = [NSData dataWithContentsOfURL:myURL];
    
    SPSocrataDataProvider *nycProvider = [SPSocrataDataProvider parserWithData:inputData];
    STAssertTrue([nycProvider isKindOfClass:[SPSocrataDataProvider class]], @"nycProvider should be a SPSocrataDataProvider");
    
}

@end
