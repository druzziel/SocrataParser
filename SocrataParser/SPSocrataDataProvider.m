//
//  SPSocrataDataProvider.m
//  SocrataParser
//
//  Created by David Roth on 12/30/12.
//  Copyright (c) 2012 David Roth. All rights reserved.
//

#import "SPSocrataDataProvider.h"

@implementation SPSocrataDataProvider


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
    NSString *socrataURL = [NSString stringWithFormat:@"%@?max_rows=%@", [self stringForJSONURL], rowsToFetch];
    NSData *inputData = [NSData dataWithContentsOfURL:[NSURL URLWithString:socrataURL]];

    SPSocrataDataProvider *result = [SPSocrataDataProvider parserWithData:inputData];
    
    self.rawDict = result.rawDict;
    
    if ( [ self.delegate respondsToSelector:@selector(socrataDataProvider:didFinishDownloadingData:) ] ) {
        [self.delegate socrataDataProvider:self didFinishDownloadingData:TRUE];
    }
    [self parseMetadata];
    [self parseDataElements];
}


-(void)parseMetadata
{
    // self.rawDict[@"meta"][@"view"][@"columns"] is an array of dictionaries
    // each dict has a "name" key that we'll use for the key in self.columns
    NSArray *tmpColumns = self.rawDict[@"meta"][@"view"][@"columns"];
    int metaDataCount = 0;
    NSNumber *zero = [NSNumber numberWithInt:0];
    for (NSDictionary *colDict in tmpColumns) {
        NSNumber *position = colDict[@"position"];
        if ([position isEqualToNumber:zero]) {
            metaDataCount++;
        }
    }
        
    self.metadataColumnCount = [NSNumber numberWithInt:metaDataCount];
        
    NSMutableDictionary *colsDictionary = [[NSMutableDictionary alloc] initWithCapacity:([tmpColumns count]) - metaDataCount];
    for (NSDictionary *colDict in tmpColumns) {
        NSNumber *position = colDict[@"position"];
        if (![position isEqualToNumber:zero]) {
            //TODO:this is an invalid assumption: the first column's position may not == 1.
            // we need to add each colDict to the colsArray and then sort colsArray by position.
            //[colsArray insertObject:colDict atIndex:position.integerValue-1];
            colsDictionary[colDict[@"name"]] = colDict;
        }
    }
    
    self.columns = colsDictionary;
    
    [colsDictionary release];
    
}

-(void)parseDataElements
{
    // translate the JSON row data
    // into an array of dictionaries
    self.rows = self.rawDict[@"data"];
    NSMutableArray *rowsArray = [NSMutableArray arrayWithCapacity:[self.rows count]];
    NSArray *firstRow = self.rows[0];
    int metaDataColumns = [self.metadataColumnCount intValue];
    int numberOfColumnsInRow = (int)firstRow.count - metaDataColumns;
    NSMutableArray *aRow = [NSMutableArray arrayWithCapacity:numberOfColumnsInRow];

    for (NSArray *rowArray in self.rows) {
        
        for (int i = metaDataColumns; i < numberOfColumnsInRow + metaDataColumns; i++) {
            [aRow addObject:rowArray[i]];
        }

        // resolve the position of the elements in aRow with the 'position'
        // wow, Socrata are bastards.  'position' can be non-contiguous:
        // for kzjm-xkqj (real-time 911 calls), the positions are
        // 1, 3, 4, 5, 6, 7, 8.  There is no column 2.
        // so, what we need to do here is have the columns ordered as they are in the
        // Socrata JSON results and just pair each column with the row data in order
        NSMutableDictionary *x = [[[NSMutableDictionary alloc] init] autorelease];
        NSArray *columnsByPosition = [self columnsByPosition];
        for (NSInteger i = 0; i < [aRow count]; i++) {
            NSString *colName = columnsByPosition[i][@"name"];
            [x setObject:aRow[i] forKey:colName];
        }
        
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

-(NSString *)columnNameAtPosition:(NSInteger)position
{
    for (NSString *name in self.columns) {
        NSDictionary *colValues = self.columns[name];
        if (position == [colValues[@"position"] integerValue])
            return name;
        else
            NSLog(@"Returning nil because %lu != %@", position, colValues[@"position"]);
    }
    return nil;
}

-(NSArray *)columnsByPosition
{
    NSSortDescriptor *descriptor = [[[NSSortDescriptor alloc] initWithKey:@"position"  ascending:YES] autorelease];
    NSArray *colsArray = [NSArray arrayWithArray:[self.columns allValues]];
    NSArray *result = [colsArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];

    return result;
}

#pragma mark Initializers

+parserWithString:(NSString *)data
{
    // do stuff
    return [[SPSocrataDataProvider alloc] init];
}

//
// return a parser by fetching the specified data set
// over the network
//
+(SPSocrataDataProvider *)parserWithDataSetString:(NSString *)dataSetString
{
    SPSocrataDataProvider *result = [[[SPSocrataDataProvider alloc] init] autorelease];
    result.dataSetString = dataSetString;
    return result;
}

//
// return a parser by loading JSON data from a local file
//
+(SPSocrataDataProvider *)parserWithFileName:(NSString *)filepath
{
    
    
    NSURL *myURL = [[NSBundle mainBundle] URLForResource:filepath withExtension:@"json"];
    NSData *inputData = [NSData dataWithContentsOfURL:myURL];
    
    SPSocrataDataProvider *result = [SPSocrataDataProvider parserWithData:inputData];
    [result parseMetadata];
    [result parseDataElements];
    
    return result;
}

//
// This is the core factory method.  It converts the JSON data into a dictionary
// and makes it available for later parsing by parseMetaData and parseDataElements
//
+(SPSocrataDataProvider *)parserWithData:(NSData *)data
{
    NSDictionary *database;
    NSError *error;
    database = [NSJSONSerialization
                JSONObjectWithData:data
                options:kNilOptions
                error:&error];
    SPSocrataDataProvider *result = [[[SPSocrataDataProvider alloc] init] autorelease];
    result.rawDict = database;
    
    return result;
}

@end
