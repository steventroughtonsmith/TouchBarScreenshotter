//
//  AppDelegate.m
//  TouchBarScreenshotter
//
//  Created by Steven Troughton-Smith on 04/11/2016.
//  Copyright © 2016 High Caffeine Content. All rights reserved.
//
//  Thanks to https://github.com/zydeco/TouchBarServer for reference
//

#import "AppDelegate.h"

@import Accelerate;
@import QuartzCore;

CGDisplayStreamRef SLSDFRDisplayStreamCreate(int displayID, dispatch_queue_t queue, CGDisplayStreamFrameAvailableHandler handler);
void DFRSetStatus(int status);
int32_t CGSMainConnectionID();

@interface AppDelegate ()
@property (weak) IBOutlet NSPanel *window;
@end

@implementation AppDelegate

// http://stackoverflow.com/questions/1320988/saving-cgimageref-to-a-png-file
BOOL CGImageWriteToFile(CGImageRef image, NSString *path) {
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
	CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
	if (!destination) {
		NSLog(@"Failed to create CGImageDestination for %@", path);
		return NO;
	}
	
	CGImageDestinationAddImage(destination, image, nil);
	
	if (!CGImageDestinationFinalize(destination)) {
		NSLog(@"Failed to write image to %@", path);
		CFRelease(destination);
		return NO;
	}
	
	CFRelease(destination);
	return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	cgsConnectionID = CGSMainConnectionID();
	touchBarStream = SLSDFRDisplayStreamCreate(0, dispatch_get_main_queue(), ^(CGDisplayStreamFrameStatus status, uint64_t displayTime, IOSurfaceRef  _Nullable frameSurface, CGDisplayStreamUpdateRef  _Nullable updateRef) {
		
		if (status == kCGDisplayStreamFrameStatusFrameComplete)
		{
			surface = frameSurface;

			IOSurfaceLock(surface, kIOSurfaceLockReadOnly, nil);
			void *frameBase = IOSurfaceGetBaseAddress(surface);
			size_t bytesPerRow = IOSurfaceGetBytesPerRow(surface);
			size_t height = IOSurfaceGetHeight(surface);
			size_t width = IOSurfaceGetWidth(surface);
			
			CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceDisplayP3);
			
			vImage_Buffer src;
			src.height = height;
			src.width = width;
			src.rowBytes = bytesPerRow;
			src.data = frameBase;
			
			vImage_Buffer dest;
			dest.height = height;
			dest.width = width;
			dest.rowBytes = bytesPerRow;
			dest.data = malloc(bytesPerRow*height);
			
			// Swap pixel channels from BGRA to RGBA.
			const uint8_t map[4] = { 2, 1, 0, 3 };
			vImagePermuteChannels_ARGB8888(&src, &dest, map, kvImageNoFlags);
			
			context = CGBitmapContextCreate (dest.data,
											 width,
											 height,
											 8,
											 bytesPerRow,
											 colorSpace,
											 kCGImageAlphaPremultipliedLast);
			if (context == NULL)
			{
				fprintf (stderr, "Context not created!");
			}
			
			CGColorSpaceRelease( colorSpace );
			
			IOSurfaceUnlock(surface, kIOSurfaceLockReadOnly, nil);
		}
	});
	
	DFRSetStatus(2);
	CGDisplayStreamStart(touchBarStream);
}

- (IBAction)screenshotTouchBar:(id)sender {
	
	CGImageRef imgRef = CGBitmapContextCreateImage(context);
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"MM-dd-yyyy HH.mm.ss"];
	
	NSString *appName = [[[NSWorkspace sharedWorkspace] frontmostApplication] localizedName];
	
	NSString *outputPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ Touch Bar %@.png", appName, [formatter stringFromDate:[NSDate date]]]];
	
	CGImageWriteToFile(imgRef,outputPath);
}

@end
