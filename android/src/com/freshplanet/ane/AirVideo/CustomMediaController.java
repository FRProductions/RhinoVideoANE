package com.freshplanet.ane.AirVideo;

import android.content.Context;
import android.graphics.Color;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.MediaController;
import android.widget.VideoView;

public class CustomMediaController extends MediaController
{
  /**************************************************************************
   * INSTANCE PROPERTIES
   **************************************************************************/
  
  private boolean mExitButtonEnabled;
  private ImageButton mExitButton;
  private int mExitButtonImageId;
  private OnClickListener mExitButtonListener;

  /**************************************************************************
   * INSTANCE CONSTRUCTOR
   **************************************************************************/

  public CustomMediaController(Context context, boolean exitButtonEnabled) {
    super(context);
    
    // init
    mExitButtonEnabled = exitButtonEnabled;
    mExitButton = null;
    mExitButtonListener = null;
  }

  /**************************************************************************
   * INSTANCE METHODS
   **************************************************************************/
  
  @Override 
  public void setAnchorView(View view) {
    super.setAnchorView(view);

    if(mExitButtonEnabled && !(view instanceof VideoView))
    {
      // create exit button if necessary
      if(mExitButton==null) {
        mExitButton = new ImageButton(this.getContext());
        mExitButton.setImageResource(mExitButtonImageId);
        mExitButton.setBackgroundColor(Color.TRANSPARENT);
        if(mExitButtonListener!=null) { mExitButton.setOnClickListener(mExitButtonListener); }
      }
      
      // add exit button if necessary
      if(this.findViewById(mExitButton.getId())==null) {
        FrameLayout.LayoutParams lytprm = new FrameLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
        lytprm.gravity = Gravity.LEFT;
        this.addView(mExitButton, lytprm);
      }
    }
  }
  
  public void setExitListener(OnClickListener exitListener) {
    mExitButtonListener = exitListener;
  }

  public void setExitButtonImageId(int imageId) {
    mExitButtonImageId = imageId;
  }

  /**************************************************************************
   * STATIC PROPERTIES
   **************************************************************************/

  /**************************************************************************
   * STATIC METHODS
   **************************************************************************/

}
