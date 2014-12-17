#import "FlashRuntimeExtensions.h"
#import <MediaPlayer/MediaPlayer.h>

@interface AirVideo : NSObject

/**************************************************************************/
#pragma mark INSTANCE PROPERTIES
/**************************************************************************/

@property (nonatomic, readonly) MPMoviePlayerController * player;

/// YES if user is allowed to pause the video.
@property (readwrite) BOOL isPauseEnabled;

/// YES if user is allowed to exit the video.
@property (readwrite) BOOL isExitEnabled;

/**************************************************************************/
#pragma mark INSTANCE METHODS
/**************************************************************************/

/**************************************************************************/
#pragma mark CLASS METHODS
/**************************************************************************/

/**
 * @return The singleton instance.
 */
+ (AirVideo *)instance;

@end

// C interface
DEFINE_ANE_FUNCTION(airVideoEnablePause);
DEFINE_ANE_FUNCTION(airVideoEnableExit);
DEFINE_ANE_FUNCTION(airVideoLoadVideo);
DEFINE_ANE_FUNCTION(airVideoShowPlayer);
DEFINE_ANE_FUNCTION(airVideoHidePlayer);
DEFINE_ANE_FUNCTION(airVideoDisposePlayer);

// ANE Setup
void AirVideoInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);
void AirVideoFinalizer(void *extData);
void AirVideoContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);
void AirVideoContextFinalizer(FREContext ctx);

// Utility
NSString * getNSStringParameter(FREObject freobj);
BOOL getBOOLParameter(FREObject freobj);
