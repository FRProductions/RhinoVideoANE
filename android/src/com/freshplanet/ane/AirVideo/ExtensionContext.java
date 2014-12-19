package com.freshplanet.ane.AirVideo;

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
import com.freshplanet.ane.AirVideo.functions.DisposePlayerFunction;
import com.freshplanet.ane.AirVideo.functions.EnableExitFunction;
import com.freshplanet.ane.AirVideo.functions.EnablePauseFunction;
import com.freshplanet.ane.AirVideo.functions.HidePlayerFunction;
import com.freshplanet.ane.AirVideo.functions.LoadVideoFunction;
import com.freshplanet.ane.AirVideo.functions.ShowPlayerFunction;
import com.freshplanet.ane.AirVideo.video.CustomMediaController;
import com.freshplanet.ane.AirVideo.video.CustomVideoView;

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
   * INSTANCE METHODS
   **************************************************************************/
  
  @Override
  public void dispose() {
    mVideoView = null;
  }

  @Override
  public Map<String, FREFunction> getFunctions()
  {
    Map<String, FREFunction> functions = new HashMap<String, FREFunction>();
    
    functions.put("airVideoEnablePause", new EnablePauseFunction());
    functions.put("airVideoEnableExit", new EnableExitFunction());
    functions.put("airVideoLoadVideo", new LoadVideoFunction());
    functions.put("airVideoShowPlayer", new ShowPlayerFunction());
    functions.put("airVideoHidePlayer", new HidePlayerFunction());
    functions.put("airVideoDisposePlayer", new DisposePlayerFunction());
    
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
    log("loading video " + Uri.parse(url));
    getVideoView().setVideoURI(Uri.parse(url));
  }

  public void showPlayer()
  {
    log("show player");

    // add VideoView to root container
    ViewGroup rootContainer = this.getRootContainer();
    VideoView videoView = this.getVideoView();
    FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT);
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
    /**/log("isPlaying? " + mVideoView.isPlaying());
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
