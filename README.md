Air Native Extension for playing videos (iOS + Android)
======================================

This is an [Air native extension](http://www.adobe.com/devnet/air/native-extensions-for-air.html) for playing videos on iOS and Android.


Installation
---------

The ANE binary (AirVideo.ane) is located in the *bin* folder.  Package the ANE binary with your app as appropriate.


Usage
---------

This ANE can play video files from URLs or from relative local paths.

    // play video
    var airvid:AirVideo = AirVideo.instance();
    airvid.addEventListener(AirVideo.VIDEO_COMPLETED,onVideoCompleted);
    airvid.addEventListener(AirVideo.VIDEO_USER_EXITED,onVideoUserExited);
    airvid.addEventListener(AirVideo.VIDEO_ERROR,onVideoError);
    airvid.addEventListener(AirVideo.VIDEO_PLAYED,onVideoPlayed);
    airvid.addEventListener(AirVideo.VIDEO_PAUSED,onVideoPaused);
    airvid.enableLogging(true);
    airvid.enablePause(true);
    airvid.enableExit(true);
    airvid.loadVideo("http://url/of/a/video.mp4");
    airvid.showPlayer();


Build script
---------

To rebuild the ANE, use the ant build script (build.xml) in the *build* folder:

    cd /path/to/the/ane/build
    mv example.build.config build.config
    #edit the build.config file to provide your machine-specific paths
    ant
