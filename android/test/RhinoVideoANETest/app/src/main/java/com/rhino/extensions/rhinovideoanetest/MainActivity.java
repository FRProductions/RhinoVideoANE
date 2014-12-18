package com.rhino.extensions.rhinovideoanetest;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;

import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.freshplanet.ane.AirVideo.Extension;

import java.util.Map;

public class MainActivity extends ActionBarActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

/*
      // Test code
      System.out.println("creating extension object...");
      Extension ext = new Extension();
      ext.createContext(null);
      System.out.println("retrieving extension functions...");
      Map fncmap = ext.context.getFunctions();
      System.out.println(fncmap);
      FREFunction fnc = (FREFunction)fncmap.get("airVideoLoadVideo");
      FREObject[] args = new FREObject[1];
      try { args[0] = FREObject.newObject("hello"); } catch(Exception e) { System.out.println("oops"); e.printStackTrace(); }
      System.out.println("calling load function " + fnc + " with arguments " + args);
      fnc.call(ext.context,args);
*/
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
