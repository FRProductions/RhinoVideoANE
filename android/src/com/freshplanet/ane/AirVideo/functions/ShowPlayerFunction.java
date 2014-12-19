package com.freshplanet.ane.AirVideo.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirVideo.Extension;

public class ShowPlayerFunction implements FREFunction
{
  @Override
  public FREObject call(FREContext context, FREObject[] args)
  {
    Extension.context.showPlayer();
    return null;
  }
}