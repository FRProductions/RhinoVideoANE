#import "AirVideo.h"

FREContext AirVideoCtx = nil;

/**************************************************************************/
#pragma mark INSTANCE PROPERTIES
/**************************************************************************/

@interface AirVideo()

@end

/**************************************************************************/
#pragma mark INSTANCE INIT / DEALLOC
/**************************************************************************/

@implementation AirVideo

- (id)init
{
  if(self=[super init]) {
    // init
  }
  return self;
}

- (void)dealloc
{
  // should never be called (Singleton), but just here for clarity
}

/**************************************************************************/
#pragma mark INSTANCE METHODS
/**************************************************************************/

- (void)initPlayer
{
  if(self.player) { return; } // nothing to do: already initialized!
  
  // initialize movie player controller
  _player = [[MPMoviePlayerController alloc] init];
  self.player.scalingMode = MPMovieScalingModeAspectFit;
  self.player.controlStyle = MPMovieControlStyleNone;

  // init to full screen size
  CGSize scrsiz = [AirVideo screenSize];
  CGRect tmpfrm = self.player.view.frame;
  tmpfrm.origin.x = 0;
  tmpfrm.origin.y = 0;
  tmpfrm.size.width = scrsiz.width;
  tmpfrm.size.height = scrsiz.height;
  self.player.view.frame = tmpfrm;
  [AirVideo log:[NSString stringWithFormat:@"init player size to %@",NSStringFromCGRect(tmpfrm)]];

  // register for player notifications
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:self.player];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.player];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];

  [AirVideo log:@"init movie player controller"];
}

- (void)disposePlayer
{
  if(!self.player) { return; } // nothing to do

  // unregister for player notifications
  [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.player];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:self.player];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];

  // stop video and remove from superview
  [self hidePlayer];
  
  // remove player reference
  _player = nil;

  [AirVideo log:@"disposed movie player controller"];
}

- (void)showPlayer
{
  if(!self.player) { return; } // nothing to do
  
  if(!self.player.view.superview) {
    UIView *rootView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
    [rootView addSubview:[[AirVideo instance].player view]];
  }
}

- (void)hidePlayer
{
  if(!self.player) { return; } // nothing to do

  // stop video and remove from superview
  [self.player stop];
  self.player.fullscreen = NO;
  [[self.player view] removeFromSuperview];
}

- (void)playerLoadStateDidChange:(NSNotification *)notification
{
  // adjust player controls once ready to play
  if(self.player.loadState == (MPMovieLoadStatePlayable | MPMovieLoadStatePlaythroughOK)) {
    [AirVideo log:@"load state is playable and playthrough OK; adjusting control style per pause/exit permissions"];
    if(self.isPauseEnabled && self.isExitEnabled) { self.player.controlStyle = MPMovieControlStyleFullscreen; }
    else                                          { self.player.controlStyle = MPMovieControlStyleNone;       }
  }
}

- (void)playerPlaybackStateDidChange:(NSNotification *)notification
{
  if(self.player.playbackState==MPMoviePlaybackStatePlaying) {
    [AirVideo dispatchAS3StatusEvent:@"VIDEO_PLAYED" withInfo:@""];
  }
  else if(self.player.playbackState==MPMoviePlaybackStatePaused) {
    [AirVideo dispatchAS3StatusEvent:@"VIDEO_PAUSED" withInfo:@""];
  }
}

- (void)playerPlaybackDidFinish:(NSNotification *)notification
{
  // switch on finish reason code
  NSNumber *fnsrsn = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
  switch([fnsrsn intValue])
  {
    case MPMovieFinishReasonPlaybackEnded: {
      [AirVideo dispatchAS3StatusEvent:@"VIDEO_COMPLETED" withInfo:@""];
    } break;
    case MPMovieFinishReasonPlaybackError: {
      NSError *err = [notification.userInfo objectForKey:@"error"];
      if(err) { [AirVideo log:[NSString stringWithFormat:@"playback error: %@",err]]; }
      [AirVideo dispatchAS3StatusEvent:@"VIDEO_ERROR" withInfo:@""];
    } break;
    case MPMovieFinishReasonUserExited: {
      [AirVideo dispatchAS3StatusEvent:@"VIDEO_USER_EXITED" withInfo:@""];
    } break;
  }
}

/**************************************************************************/
#pragma mark CLASS METHODS
/**************************************************************************/

+ (void)dispatchAS3StatusEvent:(NSString *)eventName withInfo:(NSString *)info
{
  if(AirVideoCtx != nil) {
    FREDispatchStatusEventAsync(AirVideoCtx, (const uint8_t *)[eventName UTF8String], (const uint8_t *)[info UTF8String]);
  }
}

+ (void)log:(NSString *)message
{
  [AirVideo dispatchAS3StatusEvent:@"LOG_MESSAGE" withInfo:message];
}

/**
 * Report screen size according to orientation.
 * Consistent across iOS 7 and 8.
 */
+ (CGSize)screenSize
{
  // get screen dimensions
  CGSize scrsiz = [UIScreen mainScreen].bounds.size;      // get screen size
  CGFloat bigdim = MAX(scrsiz.width,scrsiz.height);       // big screen dimension
  CGFloat smldim = MIN(scrsiz.width,scrsiz.height);       // small screen dimension
  
  // report screen width and height according to orientation
  BOOL lndscpmod = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
  if(lndscpmod) { return CGSizeMake(bigdim,smldim); }
  else          { return CGSizeMake(smldim,bigdim); }
}

/**************************************************************************/
#pragma mark CLASS METHODS - SINGLETON
/**************************************************************************/

+ (AirVideo *)instance
{
  static AirVideo *singletonInstance = nil;
  
  // this code will run only once
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    singletonInstance = [[self alloc] init];
  });
  
  return singletonInstance;
}

@end

/**************************************************************************/
#pragma mark - ANE C INTERFACE
/**************************************************************************/

void AirVideoInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
  *extDataToSet = NULL;
  *ctxInitializerToSet = &AirVideoContextInitializer;
  *ctxFinalizerToSet = &AirVideoContextFinalizer;
}

void AirVideoFinalizer(void *extData)
{
}

void AirVideoContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                                uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
  // Register links between AS3 and Objective-C.
  // note: don't forget to modify the nbFuntionsToLink integer when adding/removing functions
  NSInteger nbFuntionsToLink = 6;
  *numFunctionsToTest = nbFuntionsToLink;
  
  FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * nbFuntionsToLink);
  
  func[0].name = (const uint8_t*) "airVideoEnablePause";
  func[0].functionData = NULL;
  func[0].function = &airVideoEnablePause;
  
  func[1].name = (const uint8_t*) "airVideoEnableExit";
  func[1].functionData = NULL;
  func[1].function = &airVideoEnableExit;
  
  func[2].name = (const uint8_t*) "airVideoLoadVideo";
  func[2].functionData = NULL;
  func[2].function = &airVideoLoadVideo;
  
  func[3].name = (const uint8_t*) "airVideoShowPlayer";
  func[3].functionData = NULL;
  func[3].function = &airVideoShowPlayer;
  
  func[4].name = (const uint8_t*) "airVideoHidePlayer";
  func[4].functionData = NULL;
  func[4].function = &airVideoHidePlayer;
  
  func[5].name = (const uint8_t*) "airVideoDisposePlayer";
  func[5].functionData = NULL;
  func[5].function = &airVideoDisposePlayer;
  
  *functionsToSet = func;
  
  AirVideoCtx = ctx;
}

void AirVideoContextFinalizer(FREContext ctx)
{
}

/**************************************************************************/
#pragma mark - ANE FUNCTIONS
/**************************************************************************/

DEFINE_ANE_FUNCTION(airVideoEnablePause)
{
  BOOL enb = getBOOLParameter(argv[0]);
  [AirVideo instance].isPauseEnabled = enb;
  [AirVideo log:[NSString stringWithFormat:@"enabled pause: %d",enb]];
  return nil;
}

DEFINE_ANE_FUNCTION(airVideoEnableExit)
{
  BOOL enb = getBOOLParameter(argv[0]);
  [AirVideo instance].isExitEnabled = enb;
  [AirVideo log:[NSString stringWithFormat:@"enabled exit: %d",enb]];
  return nil;
}

DEFINE_ANE_FUNCTION(airVideoLoadVideo)
{
  NSString *      pth;        // user supplied path of video to load
  NSURL *         url;        // URL of video to load
  
  // read path argument
  pth = getNSStringParameter(argv[0]);
  if(!pth) {
    [AirVideo log:@"a valid path must be specified"];
    return nil;
  }
  [AirVideo log:[NSString stringWithFormat:@"loading video %@",pth]];
  
  // create video URL
  if([pth hasPrefix:@"http"]) {
    url = [NSURL URLWithString:pth];
  }
  else {
    // create absolute local URL from relative file path
    NSURL *baspth = [[NSBundle mainBundle] resourceURL];
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baspth,pth]];
    NSError *unreachableError;
    if([url checkResourceIsReachableAndReturnError:&unreachableError]==NO) {
      [AirVideo log:[NSString stringWithFormat:@"FileUnreachableError: %@",unreachableError.localizedDescription]];
      return nil;
    }
  }
  
  // load and play video
  [[AirVideo instance] initPlayer]; // create player if it hasn't been already
  [[AirVideo instance].player setContentURL:url];
  [[AirVideo instance].player play];
  [AirVideo log:[NSString stringWithFormat:@"initiated play of video %@",url]];
  return nil;
}

DEFINE_ANE_FUNCTION(airVideoShowPlayer)
{
  [AirVideo log:@"show player"];
  [[AirVideo instance] showPlayer];
  return nil;
}

DEFINE_ANE_FUNCTION(airVideoHidePlayer)
{
  [AirVideo log:@"hide player"];
  [[AirVideo instance] hidePlayer];
  return nil;
}

DEFINE_ANE_FUNCTION(airVideoDisposePlayer)
{
  [AirVideo log:@"dispose player"];
  [[AirVideo instance] disposePlayer];
  return nil;
}

/**************************************************************************/
#pragma mark - UTILITY
/**************************************************************************/

NSString * getNSStringParameter(FREObject freobj)
{
  uint32_t          strlen;         // string length
  const uint8_t *   strbuf;         // UTF8 null terminated string
  NSString *        newstr;         // new NSString pointer
  
  newstr = nil;
  if(FREGetObjectAsUTF8(freobj,&strlen,&strbuf)==FRE_OK) {
    newstr = [NSString stringWithUTF8String:(const char *)strbuf];
  }
  return newstr;
}

BOOL getBOOLParameter(FREObject freobj)
{
  uint32_t          bolval;         // boolean value
  
  if(FREGetObjectAsBool(freobj,&bolval)!=FRE_OK) { return NO; }
  return (bolval!=0); // a non-zero value corresponds to true/YES
}
