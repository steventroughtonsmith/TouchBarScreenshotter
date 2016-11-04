//
//  AppDelegate.h
//  TouchBarScreenshotter
//
//  Created by Steven Troughton-Smith on 04/11/2016.
//  Copyright © 2016 High Caffeine Content. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
	CGDisplayStreamRef touchBarStream;
	int32_t cgsConnectionID;
	
	IOSurfaceRef surface;
	CGContextRef context;
}

@end

