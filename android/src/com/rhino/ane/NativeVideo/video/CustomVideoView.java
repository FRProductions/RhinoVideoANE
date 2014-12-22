package com.rhino.ane.NativeVideo.video;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.VideoView;

public class CustomVideoView extends VideoView {

  /**************************************************************************
   * INSTANCE PROPERTIES
   **************************************************************************/

  private PlayPauseListener mListener;

  /**************************************************************************
   * INSTANCE CONSTRUCTOR
   **************************************************************************/

  public CustomVideoView(Context context) {
    super(context);
  }

  public CustomVideoView(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  public CustomVideoView(Context context, AttributeSet attrs, int defStyle) {
    super(context, attrs, defStyle);
  }

  /**************************************************************************
   * INSTANCE METHODS
   **************************************************************************/

  public void setPlayPauseListener(PlayPauseListener listener) {
    mListener = listener;
  }

  @Override
  public void pause() {
    super.pause();
    if(mListener != null) { mListener.onPause(); }
  }

  @Override
  public void start() {
    super.start();
    if(mListener!=null) { mListener.onPlay(); }
  }

  /**************************************************************************
   * STATIC PROPERTIES
   **************************************************************************/

  /**************************************************************************
   * STATIC METHODS
   **************************************************************************/

  public static interface PlayPauseListener {
    void onPlay();
    void onPause();
  }

}
