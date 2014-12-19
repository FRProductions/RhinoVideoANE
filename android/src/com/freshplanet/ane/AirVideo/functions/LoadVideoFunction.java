package com.freshplanet.ane.AirVideo.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirVideo.Extension;

public class LoadVideoFunction implements FREFunction
{
  @Override
  public FREObject call(FREContext context, FREObject[] args)
  {
    String url;
    try { url = args[0].getAsString(); }
    catch (Exception e) { e.printStackTrace(); return null; }

    Extension.context.loadVideo(url);
    return null;
  }
}