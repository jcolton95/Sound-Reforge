// evening of Dec 12, 2017
// first go at freesound

import processing.sound.*;
import ddf.minim.*;

Minim soundengine;
AudioSample freesound; 

String query = "";

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

  stroke(255);
  fill(0);
  textSize(16);
}

JSONObject getResponse(String query) {
  //String stringWithoutSpaces = input.replaceAll("\\s+", "+");
  String url = "https://freesound.org/apiv2/search/text/" + "?query=" + query + "&token=" + apiKey + "&format=json";
  String [] response = loadStrings(url);
  saveStrings("data.json", response);
  JSONObject jobj = loadJSONObject("data.json");
  return(jobj);
}

JSONObject getSoundData(int id) {
  String url = "https://freesound.org/apiv2/sounds/" + id + "?token=" + apiKey + "&format=json";
  String [] response = loadStrings(url);
  saveStrings("data.json", response);
  JSONObject jobj = loadJSONObject("data.json");
  return(jobj);
}

void keyPressed() {
  if (key == ENTER) {
    query = query.toLowerCase();
    // list of search results
    JSONObject response = getResponse(query);
    println(response);

    // song data for first result
    JSONArray results = response.getJSONArray("results");
    // song Id for first result
    int firstSoundId = results.getJSONObject(0).getInt("id");

    // song data for first result (using id)
    JSONObject songData = getSoundData(firstSoundId);

    // preview URL for first result in songData->previews->preview-lq-mpw
    String previewUrl = songData.getJSONObject("previews").getString("preview-lq-mp3");

    println("Song Data:", songData);
    println("URL:", previewUrl);

    // load sample in to sound engine
    freesound = soundengine.loadSample(previewUrl, 1024);    

    // play sound
    freesound.trigger();
  } else if ((key > 31) && (key != CODED)) {
    query = query + key;
  } else if (key == BACKSPACE) {
    if (query.length() > 0) {
      query = query.substring(0, query.length()-1);
    }
  }
}

void draw() {
  background(255);
  float cursorPosition = textWidth(query);
  line(cursorPosition, 0, cursorPosition, 100);
  text(query, 0, 50);
}