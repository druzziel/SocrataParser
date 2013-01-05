//
//  SPSocrataDataProvider.m
//  SocrataParser
//
//  Created by David Roth on 12/30/12.
//  Copyright (c) 2012 David Roth. All rights reserved.
//

#import "SPSocrataDataProvider.h"

@implementation SPSocrataDataProvider

-(SPSocrataDataProvider *)initWithDataSetString:(NSString *)dataSetString
{
    self = [super init];
    _dataSetString = dataSetString;
    return self;
}


- (NSString *)stringForJSONURL
{
    NSString *url = [NSString stringWithFormat:@"https://data.seattle.gov/api/views/%@/rows.json",self.dataSetString];
    return url;
    
}

-(void)fetchData:(NSNumber *)maxRows
{
    // Retrieve a JSON dictionary object which contains column information and data rows
    // and store it in self.rawDict
    NSNumber *rowsToFetch = [NSNumber numberWithInt:5];
    if (maxRows) {
        rowsToFetch = maxRows;
    }
    NSString *socrataURL = [NSString stringWithFormat:@"%@?max_rows=%d", [self stringForJSONURL], rowsToFetch];
    NSData *inputData = [NSData dataWithContentsOfURL:[NSURL URLWithString:socrataURL]];
    NSDictionary *database;
    NSError *error;
    database = [NSJSONSerialization
                JSONObjectWithData:inputData
                options:kNilOptions
                error:&error];
    self.rawDict = database;
    
    if ( [ self.delegate respondsToSelector:@selector(socrataDataProvider:didFinishDownloadingData:) ] ) {
        [self.delegate socrataDataProvider:self didFinishDownloadingData:TRUE];
    }
    [self parseColumnHeaders];
    [self parseRows];
}

-(void)parseColumnHeaders
{
    self.columns = self.rawDict[@"meta"][@"view"][@"columns"];
    int metaDataCount = 0;
    NSNumber *zero = [NSNumber numberWithInt:0];
    for (NSDictionary *colDict in self.columns) {
        NSNumber *position = colDict[@"position"];
        if ([position isEqualToNumber:zero]) {
            metaDataCount++;
        }
    }
    
    //NSLog(@"metadata count = %d", metaDataCount);
    
    self.metadataColumnCount = [NSNumber numberWithInt:metaDataCount];
    
    NSMutableArray *colsArray = [[NSMutableArray alloc] initWithCapacity:(self.columns.count) - metaDataCount];
    for (NSDictionary *colDict in self.columns) {
        NSNumber *position = colDict[@"position"];
        if (![position isEqualToNumber:zero]) {
            //TODO:this is an invalid assumption: the first column's position may not == 1.
            // we need to add each colDict to the colsArray and then sort colsArray by position.
            //[colsArray insertObject:colDict atIndex:position.integerValue-1];
            [colsArray addObject:colDict[@"name"]];
        }
    }
    
    self.columns = colsArray;
    //NSLog(@"columns = %@", colsArray);
    [colsArray release];
    
}

-(void)parseRows
{
    // translate the JSON row data
    // into an array of dictionaries
    self.rows = self.rawDict[@"data"];
    NSMutableArray *rowsArray = [NSMutableArray arrayWithCapacity:self.rows.count];
    NSArray *firstRow = self.rows[0];
    int metaDataColumns = [self.metadataColumnCount intValue];
    int numberOfColumnsInRow = (int)firstRow.count - metaDataColumns;
    NSMutableArray *aRow = [NSMutableArray arrayWithCapacity:numberOfColumnsInRow];
    
    for (NSArray *rowArray in self.rows) {
        for (int i = metaDataColumns; i < numberOfColumnsInRow + metaDataColumns; i++) {
            [aRow addObject:rowArray[i]];
        }
        NSDictionary *x = [NSDictionary dictionaryWithObjects:aRow forKeys:self.columns];
        [aRow removeAllObjects];
        [rowsArray addObject:x];
    
    }
    self.rows = nil;
    self.rows = rowsArray;
    
    if ( [self.delegate respondsToSelector:@selector(socrataDataProvider:didFinishProcessingData:)]) {
        [self.delegate socrataDataProvider:self didFinishProcessingData:TRUE];
    }

    // we're done parsing our rawDict data now, so we can let it go.
    self.rawDict = nil;
    
}


@end
