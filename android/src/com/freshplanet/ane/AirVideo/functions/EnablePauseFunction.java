package com.freshplanet.ane.AirVideo.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirVideo.Extension;

public class EnablePauseFunction implements FREFunction
{
  @Override
  public FREObject call(FREContext context, FREObject[] args)
  {
    boolean enable = false;
    try {
      enable = args[0].getAsBool();
    }
    catch (Exception e) {
      e.printStackTrace();
      return null;
    }

    Extension.context.enablePause(enable);
    return null;
  }
}