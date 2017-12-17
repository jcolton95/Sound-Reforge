// evening of Dec 12, 2017
// first go at freesound

import processing.sound.*;
import ddf.minim.*;

Minim soundengine;
AudioSample freesound; 

String query = "chimpanzee";

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

void mouseClicked() {
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
}

void draw() {
}