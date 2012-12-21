//
//  SPAppDelegate.h
//  SocrataParser
//
//  Created by David Roth on 12/11/12.
//  Copyright (c) 2012 David Roth. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SPAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *dataURLBox;
@property (assign) IBOutlet NSTextField *columnsURLBox;
@property (assign) IBOutlet NSTextField *rowsURLBox;
@property (nonatomic, strong) NSDictionary *rawDict;
@property (nonatomic, strong) NSArray *rows;
@property (nonatomic, strong) NSArray *columns;
@property (nonatomic, strong) NSNumber *metadataColumnCount;

- (IBAction)fetchIt:(id)sender;
- (NSString *)stringForJSONURL;
- (NSString *)stringForJSONColumnsURL;
- (IBAction)fetchColumns:(id)sender;
- (IBAction)fetchRows:(id)sender;
- (IBAction)fetchMetadataCount:(id)sender;
+ (void)exploreDatabase:(NSDictionary *)database;
+ (void)exploreColumns:(NSArray *)database;
+(NSNumber *)numberOfMetadataColumns:(NSArray *)database;


@end
