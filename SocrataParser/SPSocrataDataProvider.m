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
    [super init];
    self.dataSetString = dataSetString;
    return self;
}


- (NSString *)stringForJSONURL
{
    NSString *url = [NSString stringWithFormat:@"https://data.seattle.gov/api/views/%@/rows.json?max_rows=5",self.dataSetString];
    return url;
    
}

-(void)fetchData
{
    // Retrieve a JSON dictionary object which contains column information and data rows
    // and store it in self.rawDict
    NSData *inputData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self stringForJSONURL]]];
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
    [self loadColumnData];
    [self loadRowData];
}

-(void)loadColumnData
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
            [colsArray addObject:colDict];
        }
    }
    
    self.columns = colsArray;
    //NSLog(@"columns = %@", colsArray);
    [colsArray release];
    
}

-(void)loadRowData
{
    // return the row information from the JSON data
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
        [rowsArray addObject:[aRow copy] ];
        [aRow removeAllObjects];
    }
    self.rows = nil;
    self.rows = rowsArray;
    
    if ( [self.delegate respondsToSelector:@selector(socrataDataProvider:didFinishProcessingData:)]) {
        [self.delegate socrataDataProvider:self didFinishProcessingData:TRUE];
    }

}


@end
