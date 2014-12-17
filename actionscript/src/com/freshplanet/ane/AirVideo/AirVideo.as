package com.freshplanet.ane.AirVideo
{
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.StatusEvent;
  import flash.external.ExtensionContext;
  import flash.system.Capabilities;

  public class AirVideo extends EventDispatcher
  {
    /**************************************************************************
     * INSTANCE PROPERTIES
     **************************************************************************/
    
    private var mContext:ExtensionContext;
    private var mLoggingEnabled:Boolean;
    
    /**************************************************************************
     * INSTANCE CONSTRUCTOR
     **************************************************************************/
    
    public function AirVideo()
    {
      // singleton pattern
      if(sInstance) { throw new Error("Singleton... use instance()"); }

      // ensure we can continue
      if(!isSupported) { throw Error('AirVideo not supported'); }
      
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
      mContext.call("airVideoEnablePause",enabled);
    }
    
    /**
     * Enables / disables video player exit functionality.
     */
    public function enableExit(enabled:Boolean):void {
      if(!isSupported) { log('not supported'); return; }
      mContext.call("airVideoEnableExit",enabled);
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
      mContext.call("airVideoLoadVideo",url);
    }
    
    /**
     * Shows the video player.
     */
    public function showPlayer():void
    {
      if(!isSupported) { log('not supported'); return; }
      mContext.call("airVideoShowPlayer");
    }
    
    /**
     * Hides the video player.
     */
    public function hidePlayer():void
    {
      if(!isSupported) { log('not supported'); return; }
      mContext.call("airVideoHidePlayer");
    }
    
    /**
     * Disposes the video player.
     */
    public function disposePlayer():void
    {
      if(!isSupported) { log('not supported'); return; }
      mContext.call("airVideoDisposePlayer");
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
      if(mLoggingEnabled) { trace("[AirVideo] " + message); }
    }
    
    /**************************************************************************
     * STATIC PROPERTIES
     **************************************************************************/
    
    // singleton pattern: there may be only one of these objects ever created
    private static var sInstance:AirVideo = null;

    // extension ID
    private static const EXTENSION_ID:String = "com.freshplanet.AirVideo";
    
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
    public static function instance():AirVideo
    {
      if(!sInstance) { sInstance = new AirVideo(); }
      return sInstance;
    }

    /**
     * AirVideo supports iOS and Android devices.
     * @return true if AirVideo is supported.
     */
    public static function get isSupported():Boolean
    {
      var isIOS:Boolean = (Capabilities.manufacturer.indexOf("iOS") != -1);
      var isAndroid:Boolean = (Capabilities.manufacturer.indexOf("Android") != -1)
      return isIOS || isAndroid;
    }

  }
}