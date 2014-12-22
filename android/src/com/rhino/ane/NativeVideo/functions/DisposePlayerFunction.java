package com.rhino.ane.NativeVideo.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.rhino.ane.NativeVideo.Extension;

public class DisposePlayerFunction implements FREFunction
{
  @Override
  public FREObject call(FREContext context, FREObject[] args)
  {
    Extension.context.disposePlayer();
    return null;
  }
}
