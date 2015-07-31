#import "NativeVideo.h"

FREContext NativeVideoCtx = nil;

/**************************************************************************/
#pragma mark INSTANCE PROPERTIES
/**************************************************************************/

@interface NativeVideo()

@end

/**************************************************************************/
#pragma mark INSTANCE INIT / DEALLOC
/**************************************************************************/

@implementation NativeVideo

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
  CGSize scrsiz = [NativeVideo screenSize];
  CGRect tmpfrm = self.player.view.frame;
  tmpfrm.origin.x = 0;
  tmpfrm.origin.y = 0;
  tmpfrm.size.width = scrsiz.width;
  tmpfrm.size.height = scrsiz.height;
  self.player.view.frame = tmpfrm;
  [NativeVideo log:[NSString stringWithFormat:@"init player size to %@",NSStringFromCGRect(tmpfrm)]];

  // register for player notifications
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:self.player];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackStateDidChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.player];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];

  [NativeVideo log:@"init movie player controller"];
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

  [NativeVideo log:@"disposed movie player controller"];
}

- (void)showPlayer
{
  if(!self.player) { return; } // nothing to do
  
  if(!self.player.view.superview) {
    UIView *rootView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
    [rootView addSubview:[[NativeVideo instance].player view]];
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
    [NativeVideo log:@"load state is playable and playthrough OK; adjusting control style per pause/exit permissions"];
    if(self.isPauseEnabled && self.isExitEnabled) { self.player.controlStyle = MPMovieControlStyleFullscreen; }
    else                                          { self.player.controlStyle = MPMovieControlStyleNone;       }
  }
}

- (void)playerPlaybackStateDidChange:(NSNotification *)notification
{
  if(self.player.playbackState==MPMoviePlaybackStatePlaying) {
    [NativeVideo dispatchAS3StatusEvent:@"VIDEO_PLAYED" withInfo:@""];
  }
  else if(self.player.playbackState==MPMoviePlaybackStatePaused) {
    [NativeVideo dispatchAS3StatusEvent:@"VIDEO_PAUSED" withInfo:@""];
  }
}

- (void)playerPlaybackDidFinish:(NSNotification *)notification
{
  // switch on finish reason code
  NSNumber *fnsrsn = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
  switch([fnsrsn intValue])
  {
    case MPMovieFinishReasonPlaybackEnded: {
      [NativeVideo dispatchAS3StatusEvent:@"VIDEO_COMPLETED" withInfo:@""];
    } break;
    case MPMovieFinishReasonPlaybackError: {
      NSError *err = [notification.userInfo objectForKey:@"error"];
      if(err) { [NativeVideo log:[NSString stringWithFormat:@"playback error: %@",err]]; }
      [NativeVideo dispatchAS3StatusEvent:@"VIDEO_ERROR" withInfo:@""];
    } break;
    case MPMovieFinishReasonUserExited: {
      [NativeVideo dispatchAS3StatusEvent:@"VIDEO_USER_EXITED" withInfo:@""];
    } break;
  }
}

/**************************************************************************/
#pragma mark CLASS METHODS
/**************************************************************************/

+ (void)dispatchAS3StatusEvent:(NSString *)eventName withInfo:(NSString *)info
{
  if(NativeVideoCtx != nil) {
    FREDispatchStatusEventAsync(NativeVideoCtx, (const uint8_t *)[eventName UTF8String], (const uint8_t *)[info UTF8String]);
  }
}

+ (void)log:(NSString *)message
{
  [NativeVideo dispatchAS3StatusEvent:@"LOG_MESSAGE" withInfo:message];
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

+ (NativeVideo *)instance
{
  static NativeVideo *singletonInstance = nil;
  
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

void NativeVideoInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
  *extDataToSet = NULL;
  *ctxInitializerToSet = &NativeVideoContextInitializer;
  *ctxFinalizerToSet = &NativeVideoContextFinalizer;
}

void NativeVideoFinalizer(void *extData)
{
}

void NativeVideoContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                                uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
  // Register links between AS3 and Objective-C.
  // note: don't forget to modify the numFunctionsToTest integer when adding/removing functions
  *numFunctionsToTest = 7;
  
  FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * *numFunctionsToTest);
  
  func[0].name = (const uint8_t*) "anefncEnablePause";
  func[0].functionData = NULL;
  func[0].function = &anefncEnablePause;
  
  func[1].name = (const uint8_t*) "anefncEnableExit";
  func[1].functionData = NULL;
  func[1].function = &anefncEnableExit;
  
  func[2].name = (const uint8_t*) "anefncLoadVideo";
  func[2].functionData = NULL;
  func[2].function = &anefncLoadVideo;
  
  func[3].name = (const uint8_t*) "anefncShowPlayer";
  func[3].functionData = NULL;
  func[3].function = &anefncShowPlayer;
  
  func[4].name = (const uint8_t*) "anefncHidePlayer";
  func[4].functionData = NULL;
  func[4].function = &anefncHidePlayer;
  
  func[5].name = (const uint8_t*) "anefncDisposePlayer";
  func[5].functionData = NULL;
  func[5].function = &anefncDisposePlayer;
  
  func[6].name = (const uint8_t*) "anefncExitApp";
  func[6].functionData = NULL;
  func[6].function = &anefncExitApp;
  
  *functionsToSet = func;
  
  NativeVideoCtx = ctx;
}

void NativeVideoContextFinalizer(FREContext ctx)
{
}

/**************************************************************************/
#pragma mark - ANE FUNCTIONS
/**************************************************************************/

DEFINE_ANE_FUNCTION(anefncEnablePause)
{
  BOOL enb = getBOOLParameter(argv[0]);
  [NativeVideo instance].isPauseEnabled = enb;
  [NativeVideo log:[NSString stringWithFormat:@"enabled pause: %d",enb]];
  return nil;
}

DEFINE_ANE_FUNCTION(anefncEnableExit)
{
  BOOL enb = getBOOLParameter(argv[0]);
  [NativeVideo instance].isExitEnabled = enb;
  [NativeVideo log:[NSString stringWithFormat:@"enabled exit: %d",enb]];
  return nil;
}

DEFINE_ANE_FUNCTION(anefncLoadVideo)
{
  NSString *      pth;        // user supplied path of video to load
  NSURL *         url;        // URL of video to load
  
  // read path argument
  pth = getNSStringParameter(argv[0]);
  if(!pth) {
    [NativeVideo log:@"a valid path must be specified"];
    return nil;
  }
  [NativeVideo log:[NSString stringWithFormat:@"loading video %@",pth]];
  
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
      NSString *errmsg = [NSString stringWithFormat:@"FileUnreachableError: %@",unreachableError.localizedDescription];
      [NativeVideo log:errmsg];
      [NativeVideo dispatchAS3StatusEvent:@"VIDEO_ERROR" withInfo:errmsg];
      return nil;
    }
  }
  
  // load and play video
  [[NativeVideo instance] initPlayer]; // create player if it hasn't been already
  [[NativeVideo instance].player setContentURL:url];
  [[NativeVideo instance].player play];
  [NativeVideo log:[NSString stringWithFormat:@"initiated play of video %@",url]];
  return nil;
}

DEFINE_ANE_FUNCTION(anefncShowPlayer)
{
  [NativeVideo log:@"show player"];
  [[NativeVideo instance] showPlayer];
  return nil;
}

DEFINE_ANE_FUNCTION(anefncHidePlayer)
{
  [NativeVideo log:@"hide player"];
  [[NativeVideo instance] hidePlayer];
  return nil;
}

DEFINE_ANE_FUNCTION(anefncDisposePlayer)
{
  [NativeVideo log:@"dispose player"];
  [[NativeVideo instance] disposePlayer];
  return nil;
}

DEFINE_ANE_FUNCTION(anefncExitApp)
{
  [NativeVideo log:@"exit app"];
  abort(); // causes the app to generate a crash log and terminate
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
