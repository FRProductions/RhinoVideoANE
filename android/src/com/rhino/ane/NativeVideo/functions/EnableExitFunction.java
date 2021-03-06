package com.rhino.ane.NativeVideo.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.rhino.ane.NativeVideo.Extension;

public class EnableExitFunction implements FREFunction
{
  @Override
  public FREObject call(FREContext context, FREObject[] args)
  {
    boolean enable;
    try { enable = args[0].getAsBool(); }
    catch (Exception e) { e.printStackTrace(); return null; }

    Extension.context.enableExit(enable);
    return null;
  }
}