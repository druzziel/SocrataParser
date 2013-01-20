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
    // adjust the NSTextView so that we don't get line wraps
    [[self.outputTextView textContainer] setContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    [[self.outputTextView textContainer] setWidthTracksTextView:NO];
    [self.outputTextView setHorizontallyResizable:YES];
}


- (IBAction)fetchIt:(id)sender
{

    SPSocrataDataProvider *socrataDataProvider = [SPSocrataDataProvider parserWithDataSetString:[self.dataURLBox stringValue]];
    
    socrataDataProvider.delegate = self;
    
    NSNumber *rowsToFetch = (NSNumber *)self.numRowsBox.stringValue;
    
    [socrataDataProvider fetchData:rowsToFetch];
        
    NSMutableString *outputString = nil;

    NSLog(@"Columns Report: \n%@", [socrataDataProvider columnReport]);
    
    [self.outputTextView insertText:@"Type | Address | Latitude | Longitude | Datetime\n"];
    
    for (NSDictionary *row in socrataDataProvider.rows) {
        double datetime = [(NSNumber *)row[@"Datetime"] doubleValue];
        outputString = [NSString stringWithFormat:@"%@ | %@ | %@ | %@ | %@\n",
                        row[@"Type"],
                        row[@"Address"],
                        row[@"Latitude"],
                        row[@"Longitude"],
                        [NSDate dateWithTimeIntervalSince1970:datetime]];
        [self.outputTextView insertText:outputString];
    }
    [self.outputTextView insertText:@"\n"];
    
}

- (IBAction)reportColumns:(id)sender {

    SPSocrataDataProvider *socrataDataProvider = [SPSocrataDataProvider parserWithDataSetString:[self.dataURLBox stringValue]];
    
    socrataDataProvider.delegate = self;
        
    [socrataDataProvider fetchData:[NSNumber numberWithInteger:1]];
    
    [self.outputTextView insertText:[socrataDataProvider columnReport]];
    
}


-(void)socrataDataProvider:(SPSocrataDataProvider *)socrataDataProvider didFinishDownloadingData:(BOOL)result
{
    NSLog(@"Finished downloading the data!");
}

-(void)socrataDataProvider:(SPSocrataDataProvider *)socrataDataProvider didFinishProcessingData:(BOOL)result
{
    NSLog(@"Finished processing the data!");
}




@end
