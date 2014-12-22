Fullscreen Video Playback ANE
=============================

This is an [AIR Native Extension](http://www.adobe.com/devnet/air/native-extensions-for-air.html) for fullscreen video playback on iOS and Android.


Installation
---------

The ANE binary file is located at `bin\com.rhino.ane.NativeVideo.ane`.

The ANE ID is `com.rhino.ane.NativeVideo`.


Usage
---------

Video files can be played from URLs or from relative local paths.

    // play video
    var natvid:NativeVideo = NativeVideo.instance();
    natvid.addEventListener(NativeVideo.VIDEO_COMPLETED,onVideoCompleted);
    natvid.addEventListener(NativeVideo.VIDEO_USER_EXITED,onVideoUserExited);
    natvid.addEventListener(NativeVideo.VIDEO_ERROR,onVideoError);
    natvid.addEventListener(NativeVideo.VIDEO_PLAYED,onVideoPlayed);
    natvid.addEventListener(NativeVideo.VIDEO_PAUSED,onVideoPaused);
    natvid.loadVideo("http://some/video/url.mp4");
    natvid.showPlayer();


Build script
---------

To rebuild the ANE, use the ant build script (build.xml) in the *build* folder:

    cd /path/to/the/ane/build
    mv example.build.config build.config
    #edit the build.config file to provide your machine-specific paths
    ant
