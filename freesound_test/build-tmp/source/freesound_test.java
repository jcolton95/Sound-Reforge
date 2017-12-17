import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.*; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import ddf.minim.signals.*; 
import ddf.minim.spi.*; 
import ddf.minim.ugens.*; 
import ddf.minim.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class freesound_test extends PApplet {








// evening of Dec 12, 2017
// first go at freesound

//import processing.sound.*;


Minim soundengine;
AudioSample freesound; 

String query = "chimpanzee";
String baseUrl = "https://freesound.org/apiv2/";

/*
  query
 search 
 returns list of sounds with IDs
 use an ID to get specific sound data from /sounds/<sound_id>
 returns 'preview' field as url
 use url as argument to Minim method to play audio
 
 */

public void setup() {
  
  background(255);

  soundengine = new Minim(this);
}

/*
  Returns a JSON object containing the freesound API response given an 
  endpoint and paramenters.
*/
public JSONObject callAPI (String endpoint, JSONObject params) {
  String url = baseUrl + endpoint + "?token=" + apiKey + "&format=json";

  if (params != null) {
    String [] properties = (String[]) params.keys()
      .toArray(new String[params.size()]);

    for (int i = 0; i < params.size(); i++) {
      println(properties[i]);
      String property = properties[i];
      url += "&" + property + "=" + params.getString(property);
    }
  }

  String [] response = loadStrings(url);
  saveStrings("data.json", response);
  JSONObject jobj = loadJSONObject("data.json");

  return jobj;
}

public void mouseClicked() {

  JSONObject searchParams = new JSONObject();
  searchParams.setString("query", query);
  JSONObject response = callAPI("search/text/", searchParams);

  // song data for first result
  JSONArray results = response.getJSONArray("results");
  // song Id for first result
  int firstSoundId = results.getJSONObject(0).getInt("id");

  // song data for first result (using id)
  JSONObject songData = callAPI("sounds/" + firstSoundId, null);

  // preview URL for first result in songData->previews->preview-lq-mpw
  String previewUrl = songData.getJSONObject("previews").getString("preview-lq-mp3");

  println("Song Data:", songData);
  println("URL:", previewUrl);

  // load sample in to sound engine
  freesound = soundengine.loadSample(previewUrl, 1024);    

  // play sound
  freesound.trigger();
}

public void draw() {
}
String apiKey = "akoZxHxqSty8PsFNB3xNOAhYfQpYZb4E86mJ00xl";
  public void settings() {  size(200, 200); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "freesound_test" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
