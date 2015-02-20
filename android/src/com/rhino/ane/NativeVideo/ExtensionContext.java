package com.rhino.ane.NativeVideo;

import android.app.Activity;
import android.content.Context;
import android.media.MediaPlayer;
import android.net.Uri;
import android.view.Gravity;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.VideoView;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.rhino.ane.NativeVideo.functions.DisposePlayerFunction;
import com.rhino.ane.NativeVideo.functions.EnableExitFunction;
import com.rhino.ane.NativeVideo.functions.EnablePauseFunction;
import com.rhino.ane.NativeVideo.functions.HidePlayerFunction;
import com.rhino.ane.NativeVideo.functions.LoadVideoFunction;
import com.rhino.ane.NativeVideo.functions.ShowPlayerFunction;
import com.rhino.ane.NativeVideo.video.CustomMediaController;
import com.rhino.ane.NativeVideo.video.CustomVideoView;

import java.util.HashMap;
import java.util.Map;

public class ExtensionContext extends FREContext implements
        MediaPlayer.OnPreparedListener, MediaPlayer.OnCompletionListener, MediaPlayer.OnErrorListener,
        CustomVideoView.PlayPauseListener, OnClickListener
{
  /**************************************************************************
   * INSTANCE PROPERTIES
   **************************************************************************/

  private CustomVideoView mVideoView = null;
  private boolean mIsPauseEnabled = true;
  private boolean mIsExitEnabled = true;
  
  /**************************************************************************
   * INSTANCE CONSTRUCTOR
   **************************************************************************/

  public ExtensionContext() {}
  
  /**************************************************************************
   * INSTANCE METHODS - FREContext
   **************************************************************************/
  
  @Override
  public void dispose() {
    mVideoView = null;
  }

  @Override
  public Map<String, FREFunction> getFunctions()
  {
    Map<String, FREFunction> functions = new HashMap<String, FREFunction>();
    
    functions.put("anefncEnablePause", new EnablePauseFunction());
    functions.put("anefncEnableExit", new EnableExitFunction());
    functions.put("anefncLoadVideo", new LoadVideoFunction());
    functions.put("anefncShowPlayer", new ShowPlayerFunction());
    functions.put("anefncHidePlayer", new HidePlayerFunction());
    functions.put("anefncDisposePlayer", new DisposePlayerFunction());
    
    return functions;
  }

  /**************************************************************************
   * INSTANCE METHODS - PUBLIC
   **************************************************************************/

  public void enablePause(boolean enable) {
    mIsPauseEnabled = enable;
    log("enabled pause: " + enable);
  }

  public void enableExit(boolean enable) {
    mIsExitEnabled = enable;
    log("enabled exit: " + enable);
  }

  public void loadVideo(String url)
  {
    log("loading video: input URL is " + url);

    // local video support
    if(!url.startsWith("http://"))
    {
      // assume: video files have been moved from assets/assets/videos -> res/raw
      // note: video playback only works if videos are in res/raw folder, not in assets (!)

      // get ApplicationContext
      Activity appaty = this.getActivity();
      Context appctx = appaty.getApplicationContext();

      // create res/raw video file path
      // assume input URL is of the form: "assets/videos/<videoFilename>.<extension>"
      //   and contains at least one '/' and one trailing '.' for an extension
      int slslstidx = url.lastIndexOf('/');   // slash last index
      int prdlstidx = url.lastIndexOf('.');   // period last index
      if(slslstidx>=0 && prdlstidx>slslstidx+1) {
        String fnm = url.substring(slslstidx+1,prdlstidx);
        url = "android.resource://" + appctx.getPackageName() + "/raw/" + fnm;
      }
    }

    // load video
    log("loading video: modified URL is " + url);
    getVideoView().setVideoURI(Uri.parse(url));
  }

  public void showPlayer()
  {
    log("show player");

    // add VideoView to root container
    ViewGroup rootContainer = this.getRootContainer();
    VideoView videoView = this.getVideoView();
    FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT);
    layoutParams.gravity = Gravity.CENTER_HORIZONTAL;
    rootContainer.addView(videoView, layoutParams);
    videoView.clearFocus();
  }

  public void hidePlayer()
  {
    log("hide player");
    if(mVideoView==null) { return; } // nothing to do

    // remove VideoView from root container
    ViewGroup rootContainer = this.getRootContainer();
    VideoView videoView = this.getVideoView();
    rootContainer.removeView(videoView);
  }

  public void disposePlayer()
  {
    log("dispose player");
    if(mVideoView==null) { return; } // nothing to do

    hidePlayer();
    mVideoView = null;
    log("disposed video view");
  }

  /**************************************************************************
   * INSTANCE METHODS - VideoView
   **************************************************************************/

  private ViewGroup getRootContainer()
  {
    return (ViewGroup)((ViewGroup)getActivity().findViewById(android.R.id.content)).getChildAt(0);
  }

  private VideoView getVideoView()
  {
    // create new VideoView if necessary
    if(mVideoView == null) {
      mVideoView = new CustomVideoView(getActivity());
      mVideoView.setZOrderOnTop(true);
      mVideoView.setOnPreparedListener(this);
      mVideoView.setOnCompletionListener(this);
      mVideoView.setOnErrorListener(this);
      mVideoView.setPlayPauseListener(this);
      log("initialized video view");
    }

    // set/clear MediaController as necessary
    if(mIsPauseEnabled) {
      CustomMediaController mediaController = new CustomMediaController(getActivity(),mIsExitEnabled);
      mediaController.setExitListener(this);
      mediaController.setExitButtonImageId(this.getResourceId("drawable.white_x"));
      mVideoView.setMediaController(mediaController);
    }
    else {
      mVideoView.setMediaController(null);
    }

    return mVideoView;
  }

  /**************************************************************************
   * INSTANCE METHODS - LISTENERS
   **************************************************************************/

  public void onCompletion(MediaPlayer mediaPlayer) {
    dispatchStatusEventAsync("VIDEO_COMPLETED");
  }

  public boolean onError(MediaPlayer mediaPlayer, int what, int extra) {
    dispatchStatusEventAsync("VIDEO_ERROR");
    return true;
  }

  public void onPrepared(MediaPlayer mediaPlayer) {
    mVideoView.start();
    mVideoView.clearFocus();
  }

  public void onPlay() {
    dispatchStatusEventAsync("VIDEO_PLAYED");
  }

  public void onPause() {
    dispatchStatusEventAsync("VIDEO_PAUSED");
  }

  // exit button click listener
  public void onClick(View view) {
    dispatchStatusEventAsync("VIDEO_USER_EXITED");
  }

  /**************************************************************************
   * INSTANCE METHODS - UTILITY
   **************************************************************************/

  public void log(String message) {
    dispatchStatusEventAsync("LOG_MESSAGE", message);
  }

  public void dispatchStatusEventAsync(String s) throws java.lang.IllegalArgumentException, java.lang.IllegalStateException {
    dispatchStatusEventAsync(s,"");
  }

  /**************************************************************************
   * STATIC PROPERTIES
   **************************************************************************/

  /**************************************************************************
   * STATIC METHODS
   **************************************************************************/
}
