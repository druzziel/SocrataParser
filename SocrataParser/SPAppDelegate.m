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


- (IBAction)fetchIt:(id)sender
{

    SPSocrataDataProvider *socrataDataProvider = [[SPSocrataDataProvider alloc]
                                                  initWithDataSetString:[self.dataURLBox stringValue]];
    
    socrataDataProvider.delegate = self;
    
    [socrataDataProvider fetchData];
    
    for (int j=0; j<socrataDataProvider.rows.count;j++)
    {
        for (int i=0; i<socrataDataProvider.columns.count-1; i++) {
            NSLog(@"%@ : %@", socrataDataProvider.columns[i][@"name"], socrataDataProvider.rows[j][i]);
        }
        NSLog(@"###########################################################");
        
    }

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
