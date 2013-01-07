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

    SPSocrataDataProvider *socrataDataProvider = [[SPSocrataDataProvider alloc]
                                                  initWithDataSetString:[self.dataURLBox stringValue]];
    
    socrataDataProvider.delegate = self;
    
    [socrataDataProvider fetchData:[NSNumber numberWithInt:25]];
    
    NSMutableString *outputString = nil;

//    for (id columnHeader in socrataDataProvider.columns) {
//        outputString = [NSString stringWithFormat:@"%@\t", columnHeader[@"name"]];
//        [self.outputTextView insertText:outputString];
//    }
    
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
    
//    for (int j=0; j<socrataDataProvider.rows.count;j++)
//    {
//        for (int i=0; i<socrataDataProvider.columns.count-1; i++) {
//            
//            outputString = [NSString stringWithFormat:@"%@ : %@\n", socrataDataProvider.columns[i][@"name"], socrataDataProvider.rows[j][i] ];
//            [self.outputTextView insertText:outputString];
//        }
//        [self.outputTextView insertText:@"###########################################################\n"];
//        
//    }

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
