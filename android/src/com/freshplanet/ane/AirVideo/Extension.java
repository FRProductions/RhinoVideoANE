package com.freshplanet.ane.AirVideo;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class Extension implements FREExtension
{
  public static ExtensionContext context;
  
  @Override
  public FREContext createContext(String arg0)
  {
    context = new ExtensionContext();
    return context;
  }

  @Override
  public void dispose()
  {
    context = null;
  }

  @Override
  public void initialize()
  {
  }
}