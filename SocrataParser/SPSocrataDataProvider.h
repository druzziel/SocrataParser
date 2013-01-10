//
//  SPSocrataDataProvider.h
//  SocrataParser
//
//  Created by David Roth on 12/30/12.
//  Copyright (c) 2012 David Roth. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPSocrataDataProvider;

@protocol SPSocrataDataProviderDelegate <NSObject>

// delegate functions if you want to provide user feedback when data
// downloading and parsing are completed

-(void)socrataDataProvider:(SPSocrataDataProvider *)socrataDataProvider
   didFinishDownloadingData:(BOOL)result;

-(void)socrataDataProvider:(SPSocrataDataProvider *)socrataDataProvider
   didFinishProcessingData:(BOOL)result;

@end

@interface SPSocrataDataProvider : NSObject

-(SPSocrataDataProvider *)initWithDataSetString:(NSString *)dataSetString;
- (NSString *)stringForJSONURL;
-(void)fetchData:(NSNumber *)maxRows;
+(SPSocrataDataProvider *)parserWithFileName:(NSString *)filepath;
+(SPSocrataDataProvider *)parserWithString:(NSString *)data;
+(SPSocrataDataProvider *)parserWithData:(NSData *)data;

//+URLStringForServer:dataset:
//+URLStringForServer:dataset:maxRows:
//+URLStringForServer:dataset:modifiedSince:

@property (nonatomic, strong) NSString *dataSetString;
@property (nonatomic, strong) NSDictionary *rawDict;
@property (nonatomic, strong) NSArray *rows;
@property (nonatomic, strong) NSArray *columns;
@property (nonatomic, strong) NSNumber *metadataColumnCount;
@property (nonatomic, strong) id delegate;


@end
