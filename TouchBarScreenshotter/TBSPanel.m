//
//  TBSPanel.m
//  TouchBarScreenshotter
//
//  Created by Steven Troughton-Smith on 04/11/2016.
//  Copyright © 2016 High Caffeine Content. All rights reserved.
//

#import "TBSPanel.h"

@implementation TBSPanel

-(BOOL)canBecomeKeyWindow
{
	return NO;
}

-(void)close
{
	[NSApp terminate:self];
}

@end
