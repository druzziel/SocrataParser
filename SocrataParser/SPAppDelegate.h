//
//  SPAppDelegate.h
//  SocrataParser
//
//  Created by David Roth on 12/11/12.
//  Copyright (c) 2012 David Roth. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SPSocrataDataProvider.h"

@interface SPAppDelegate : NSObject <NSApplicationDelegate,SPSocrataDataProviderDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *dataURLBox;
@property (assign) IBOutlet NSTextView *outputTextView;
@property (assign) IBOutlet NSTextField *numRowsBox;

- (IBAction)fetchIt:(id)sender;


@end
