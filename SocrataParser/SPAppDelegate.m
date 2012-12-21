//
//  SPAppDelegate.m
//  SocrataParser
//
//  Created by David Roth on 12/11/12.
//  Copyright (c) 2012 David Roth. All rights reserved.
//

#import "SPAppDelegate.h"

@implementation SPAppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (NSString *)stringForJSONURL
{
    return [[self dataURLBox] stringValue];
}


- (NSString *)stringForJSONColumnsURL
{
    return [[self columnsURLBox] stringValue] ;
}

- (NSString *)stringForJSONRowsURL
{
    return [[self rowsURLBox] stringValue];
}

- (IBAction)fetchIt:(id)sender
{
    [self fetchData];
    [self loadColumnData];
    [self loadRowData];
    
    NSLog(@"Found %lu column headers", self.columns.count);
    NSArray *foo = self.rows[0];
    NSLog(@"Found %lu row coluns", foo.count);
    NSLog(@"Found %lu rows", self.rows.count);
    
    for (int j=0; j<self.rows.count;j++)
    {
        for (int i=0; i<self.columns.count-1; i++) {
            NSLog(@"%@ : %@", self.columns[i][@"name"], self.rows[j][i]);
        }
        NSLog(@"###########################################################");
        
    }
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
            // this is an invalid assumption: the first column's position may not == 1.
            // we need to add each colDict to the colsArray and then sort colsArray by position.
            //[colsArray insertObject:colDict atIndex:position.integerValue-1];
            [colsArray addObject:colDict];
        }
    }

    self.columns = colsArray;
    //NSLog(@"columns = %@", colsArray);

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
    
}












- (IBAction)fetchColumns:(id)sender {
    NSData *inputData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self stringForJSONColumnsURL]]];
    NSArray *database;
    NSError *error;
    database = [NSJSONSerialization
                JSONObjectWithData:inputData
                options:kNilOptions
                error:&error];

    [SPAppDelegate exploreColumns:database];

}

- (IBAction)fetchRows:(id)sender {

    NSData *colsData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self stringForJSONColumnsURL]]];
    NSArray *colsDatabase;
    NSError *error;
    colsDatabase = [NSJSONSerialization
                    JSONObjectWithData:colsData
                    options:kNilOptions
                    error:&error];
    
    NSArray *columns = [self extractColumnData:colsDatabase];

    
    
    NSData *inputData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self stringForJSONRowsURL]]];
    NSDictionary *database;
    database = [NSJSONSerialization
                JSONObjectWithData:inputData
                options:kNilOptions
                error:&error];
    NSArray *rows = [self extractRowData:database];

    for (NSArray *row in rows) {
        for (int i = 0; i < columns.count; i++)
            NSLog(@"CODE DELPHI %u %@: %@",i, columns[i][@"fieldName"], row[i]);
        }
    
}

- (IBAction)fetchMetadataCount:(id)sender {
    NSData *inputData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self stringForJSONRowsURL]]];
    NSDictionary *database;
    NSError *error;
    database = [NSJSONSerialization
                JSONObjectWithData:inputData
                options:kNilOptions
                error:&error];
    NSArray *data = database[@"meta"][@"view"][@"columns"];
//    for (NSDictionary *dict in data) {
//        NSLog(@"%@", dict);
//    }
    NSLog(@"I found %@ metadata columns", [SPAppDelegate numberOfMetadataColumns:data]);
}

-(NSArray *)extractRowData:(NSDictionary *)database
{
    // the Socrate API returns row information embedded in a dictionary
    // get the data array and return it
    NSArray *data = database[@"data"];
    // filter out the metadata columns
    // 
    return data;
}

-(NSArray *)extractColumnData:(NSArray *)database
{
    // return the names of the fields in database
    // result[0] is the name of column 1
    // result[1] is the name of column 2
    // etc.
    NSMutableArray *colsArray = [[NSMutableArray alloc] initWithCapacity:[database count]];
    for (NSDictionary *colDict in database) {
        NSNumber *position = colDict[@"position"];
        if (position != 0) {
            NSLog(@"Code Delphi: position = %@", position);
            NSLog(@"Code Delphi: name = %@", colDict[@"name"]);
            
            [colsArray insertObject:colDict atIndex:position.integerValue-1];
        }
    }

    NSLog(@"pre-sort");
    for (NSDictionary *colDict in colsArray) {
        NSLog(@"%@", [colDict valueForKey:@"position"]);
    }
    
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
//
//    [colsArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
//
//    [sortDescriptor release];

//    NSLog(@"post-sort");
//    for (NSDictionary *colDict in colsArray) {
//        NSLog(@"%@", [colDict valueForKey:@"position"]);
//    }
    
    return colsArray;
}

+(NSNumber *)numberOfMetadataColumns:(NSArray *)database
{
    int metaDataCount = 0;
    NSNumber *zero = [NSNumber numberWithInt:0];
    for (NSDictionary *colDict in database) {
        NSNumber *position = colDict[@"position"];
        NSLog(@"position = %@", position);
        NSLog(@"position is a %@", [position class]);
        if ([position isEqualToNumber:zero]) {
            metaDataCount++;
        }
    }

    return [[NSNumber alloc] initWithInt:metaDataCount];
}

+(void)exploreColumns:(NSArray *)database
{
    NSLog(@"database is a %@", database.class);
    for (NSDictionary *colDict in database) {
        NSLog(@"################");
        NSLog(@"%@", [colDict valueForKey:@"name"]);
        NSLog(@"%@", [colDict valueForKey:@"fieldName"]);
        NSLog(@"%@", [colDict valueForKey:@"position"]);
        NSLog(@"%@", [colDict valueForKey:@"dataTypeName"]);
        //        NSLog(@"%@", colDict.allKeys);
    }
}

+ (void)exploreDatabase:(NSDictionary *)database
{
    
    // The database has a meta dictionary which contains a columns dictionary
    // columns is an array of dictionaries that describe the columns
    // if a column's position == 0, then it's a metacolumn
    // if the position >= 1, then the position is equal to the number
    // of position 0 columns + its position number
    
    NSDictionary *meta = database[@"meta"];
    //NSLog(@"'meta' keys: %@", meta.allKeys);
    NSDictionary *view = meta[@"view"];
    NSLog(@"'view' keys: %@", view.allKeys);
    NSArray *columns = view[@"columns"];
    NSLog(@"columns are of class %@", columns.class);
    NSLog(@"column elements are of class %@", [columns[0] class]);
    NSDictionary *aColumnsElement = columns[0];
    NSLog(@"columns keys are %@", aColumnsElement.allKeys);

//    NSLog(@"column values: position name description dataTypeName fieldName");

    NSNumber *colPosition;
    NSString *colName;
    NSString *colType;
    
    NSMutableDictionary *columnDict = [[NSMutableDictionary alloc] initWithCapacity:40];
    
    for (NSDictionary *obj in columns) {
        colPosition = obj[@"position"];
        colName = obj[@"name"];
        colType = obj[@"dataTypeName"];
        NSLog(@"%@, %@, %@", colName, colPosition, colType);
        [columnDict setObject:colPosition forKey:colName];
    }

    NSLog(@"column dictionary = %@", columnDict);
    

}


@end
