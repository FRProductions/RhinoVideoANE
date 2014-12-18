//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//    http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  
//////////////////////////////////////////////////////////////////////////////////////

package com.freshplanet.ane.AirVideo.functions;

import android.net.Uri;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirVideo.Extension;

public class LoadVideoFunction implements FREFunction
{
  @Override
  public FREObject call(FREContext context, FREObject[] args)
  {
    String url = null;
    try {
      url = args[0].getAsString();
    }
    catch (Exception e) {
      e.printStackTrace();
      return null;
    }
    
    Extension.context.log("loading video " + url);
    Extension.context.log("after parse " + Uri.parse(url));
    String tsturl = "android.resource://com.captainmcfinn.SwimAndPlay/assets/" + url;
    Extension.context.log("test URL " + tsturl);
    Extension.context.log("test URL after parse " + Uri.parse(tsturl));
    Extension.context.getVideoView().setVideoPath(tsturl);
    
    //Extension.context.getVideoView().setVideoURI(Uri.parse(url));
    
    return null;
  }
}