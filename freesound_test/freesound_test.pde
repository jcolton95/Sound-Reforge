import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

// evening of Dec 12, 2017
// first go at freesound

//import processing.sound.*;
import ddf.minim.*;

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

void setup() {
  size(200, 200);
  background(255);

  soundengine = new Minim(this);
}

/*
  Returns a JSON object containing the freesound API response given an 
  endpoint and paramenters.
*/
JSONObject callAPI (String endpoint, JSONObject params) {
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

void mouseClicked() {

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

void draw() {
}