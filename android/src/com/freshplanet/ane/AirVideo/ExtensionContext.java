package com.freshplanet.ane.AirVideo;

import java.util.HashMap;
import java.util.Map;

import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.media.MediaPlayer.OnErrorListener;
import android.media.MediaPlayer.OnPreparedListener;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.VideoView;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.freshplanet.ane.AirVideo.functions.EnablePauseFunction;
import com.freshplanet.ane.AirVideo.functions.EnableExitFunction;
import com.freshplanet.ane.AirVideo.functions.LoadVideoFunction;
import com.freshplanet.ane.AirVideo.functions.ShowPlayerFunction;
import com.freshplanet.ane.AirVideo.functions.HidePlayerFunction;
import com.freshplanet.ane.AirVideo.functions.DisposePlayerFunction;

public class ExtensionContext extends FREContext implements OnCompletionListener, OnErrorListener, OnPreparedListener, OnClickListener
{
  /**************************************************************************
   * INSTANCE PROPERTIES
   **************************************************************************/

  private VideoView _videoView = null;
  private int x = 0;
  private int y = 0;
  private int width = 0;
  private int height = 0;
  private boolean isDisplayRectSet = false;
  private boolean _isPauseEnabled = true;
  private boolean _isExitEnabled = true;
  
  /**************************************************************************
   * INSTANCE CONSTRUCTOR
   **************************************************************************/

  public ExtensionContext() {
    System.out.println("hello from ExtensionContext!");
  }
  
  /**************************************************************************
   * INSTANCE METHODS
   **************************************************************************/
  
  @Override
  public void dispose() {}

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
  
  public ViewGroup getRootContainer()
  {
    return (ViewGroup)((ViewGroup)getActivity().findViewById(android.R.id.content)).getChildAt(0);
  }
  
  public VideoView getVideoView()
  {
    // create new VideoView if necessary
    if(_videoView == null) {
      _videoView = new VideoView(getActivity());
      _videoView.setZOrderOnTop(true);
      _videoView.setOnCompletionListener(this);
      _videoView.setOnErrorListener(this);
      _videoView.setOnPreparedListener(this);
    }

    // add / remove MediaController as necessary
    if(_isPauseEnabled) {
      CustomMediaController mediaController = new CustomMediaController(getActivity(),_isExitEnabled);
      mediaController.setExitListener(this);
      mediaController.setExitButtonImageId(this.getResourceId("drawable.white_x"));
      _videoView.setMediaController(mediaController);
    }
    else {
      _videoView.setMediaController(null);
    }
    
    return _videoView;
  }
  
  public void enablePause(boolean enable) {
    _isPauseEnabled = enable;
  }

  public void enableExit(boolean enable) {
    _isExitEnabled = enable;
  }
  
  public void setDisplayRect(double x, double y, double width, double height)
  {
    this.x = (int) x;
    this.y = (int) y;
    this.width = (int) width;
    this.height = (int) height;
    isDisplayRectSet = true;
    updateDisplayRect();
  }
  
  private void updateDisplayRect() 
  {
    if(!isDisplayRectSet) {
      return;
    }
    getVideoView();
    ViewGroup.LayoutParams params = _videoView.getLayoutParams();
    if(params == null) {
      return;
    }
    
    try {
      FrameLayout.LayoutParams frameParams = (FrameLayout.LayoutParams) params;
      frameParams.leftMargin = (int) x;
      frameParams.topMargin = (int) y;
    } catch (ClassCastException frameError) {
      try {
        WindowManager.LayoutParams windowParams = (WindowManager.LayoutParams) params;
        windowParams.horizontalMargin = (int) x;
        windowParams.verticalMargin = (int) y;
      } catch (ClassCastException windowError) {
        width += 2*x;
        height += 2*y;
      }
    }
    
    params.width = width;
    params.height = height;

    _videoView.setLayoutParams(params);
    _videoView.invalidate();
  }
  
  @Override
  public void onPrepared(MediaPlayer arg0) {
    if(isDisplayRectSet) {
      updateDisplayRect();
    }
    _videoView.start();
    _videoView.clearFocus();
  }
  
  public void onCompletion(MediaPlayer mp)
  {
    dispatchStatusEventAsync("VIDEO_COMPLETED", "OK");
  }

  @Override
  public boolean onError(MediaPlayer mp, int what, int extra) 
  {
    dispatchStatusEventAsync("VIDEO_ERROR", "OK");
    isDisplayRectSet = false;
    return true;
  }
  
  // exit button click listener
  public void onClick(View view)
  {
    dispatchStatusEventAsync("VIDEO_USER_EXITED", "OK");
  }
  
  public void log(String message)
  {
    dispatchStatusEventAsync("LOG_MESSAGE", message);
  }
  
  /**************************************************************************
   * STATIC PROPERTIES
   **************************************************************************/

  /**************************************************************************
   * STATIC METHODS
   **************************************************************************/
}
