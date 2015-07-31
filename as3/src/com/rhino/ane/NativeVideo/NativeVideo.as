package com.rhino.ane.NativeVideo
{
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.StatusEvent;
  import flash.external.ExtensionContext;
  import flash.system.Capabilities;

  public class NativeVideo extends EventDispatcher
  {
    /**************************************************************************
     * INSTANCE PROPERTIES
     **************************************************************************/
    
    private var mContext:ExtensionContext;
    private var mLoggingEnabled:Boolean;
    
    /**************************************************************************
     * INSTANCE CONSTRUCTOR
     **************************************************************************/
    
    public function NativeVideo()
    {
      // singleton pattern
      if(sInstance) { throw new Error("Singleton... use instance()"); }

      // ensure we can continue
      if(!isSupported) { throw Error('not supported'); }
      
      // init
      mContext = ExtensionContext.createExtensionContext(EXTENSION_ID,null);
      if(!mContext) { throw Error("Extension context is null. Please check if extension.xml is setup correctly."); }
      mContext.addEventListener(StatusEvent.STATUS,onStatus);
      mLoggingEnabled = false;
    }
    
    /**************************************************************************
     * INSTANCE METHODS - PUBLIC
     **************************************************************************/
    
    /**
     * Toggles log message display.
     */
    public function enableLogging(enabled:Boolean):void {
      mLoggingEnabled = enabled;
    }
    
    /**
     * Enables / disables video player pause functionality.
     */
    public function enablePause(enabled:Boolean):void {
      if(!isSupported) { log('not supported'); return; }
      mContext.call("anefncEnablePause",enabled);
    }
    
    /**
     * Enables / disables video player exit functionality.
     */
    public function enableExit(enabled:Boolean):void {
      if(!isSupported) { log('not supported'); return; }
      mContext.call("anefncEnableExit",enabled);
    }
    
    /**
     * Loads and plays a given video URL fullscreen.
     * 
     * @param url   URL of the video to play.
     *              This can be a relative local path or a remote URL.
     *              Local paths are expected to be relative to the application bundle root, i.e. "assets/videos/myVideo.mp4"
     */
    public function loadVideo(url:String):void
    {
      if(!isSupported) { log('not supported'); return; }
      mContext.call("anefncLoadVideo",url);
    }
    
    /**
     * Shows the video player.
     */
    public function showPlayer():void
    {
      if(!isSupported) { log('not supported'); return; }
      mContext.call("anefncShowPlayer");
    }
    
    /**
     * Hides the video player.
     */
    public function hidePlayer():void
    {
      if(!isSupported) { log('not supported'); return; }
      mContext.call("anefncHidePlayer");
    }
    
    /**
     * Disposes the video player.
     */
    public function disposePlayer():void
    {
      if(!isSupported) { log('not supported'); return; }
      mContext.call("anefncDisposePlayer");
    }
    
    /**
     * Exits the app - iOS only.
     */
    public function exitApp():void
    {
      if(!isIOS) { log('not supported'); return; }
      mContext.call("anefncExitApp");
    }
    
    /**************************************************************************
     * INSTANCE METHODS - PRIVATE
     **************************************************************************/
    
    /**
     * Receives all status events from native code and dispatches them as a new Event.
     * LOG_MESSAGE events are simply logged and not passed on.
     */
    private function onStatus(event:StatusEvent):void
    {
      if(event.code==LOG_MESSAGE) {
        log(event.level);
      }
      else {
        log('dispatching event: ' + event.code);
        dispatchEvent(new Event(event.code));
      }
    }
    
    /**
     * Optionally displays log message.
     */
    private function log(message:String):void
    {
      if(mLoggingEnabled) { trace("[NativeVideo] " + message); }
    }
    
    /**************************************************************************
     * STATIC PROPERTIES
     **************************************************************************/
    
    // singleton pattern: there may be only one of these objects ever created
    private static var sInstance:NativeVideo = null;

    // extension ID
    private static const EXTENSION_ID:String = "com.rhino.ane.NativeVideo";
    
    // event strings dispatched
    private static const LOG_MESSAGE          : String = "LOG_MESSAGE";
    public  static const VIDEO_COMPLETED      : String = "VIDEO_COMPLETED";
    public  static const VIDEO_USER_EXITED    : String = "VIDEO_USER_EXITED";
    public  static const VIDEO_ERROR          : String = "VIDEO_ERROR";
    public  static const VIDEO_PLAYED         : String = "VIDEO_PLAYED";
    public  static const VIDEO_PAUSED         : String = "VIDEO_PAUSED";
    
    /**************************************************************************
     * STATIC METHODS
     **************************************************************************/
    
    // singleton pattern
    public static function instance():NativeVideo
    {
      if(!sInstance) { sInstance = new NativeVideo(); }
      return sInstance;
    }

    /**
     * NativeVideo supports iOS and Android devices.
     * @return true if NativeVideo is supported.
     */
    public static function get isSupported():Boolean {
      return isIOS || isAndroid;
    }
    
    private static function isIOS():Boolean {
      return (Capabilities.manufacturer.indexOf("iOS") != -1);
    }

    private static function isAndroid():Boolean {
      return (Capabilities.manufacturer.indexOf("Android") != -1);
    }
  }
}