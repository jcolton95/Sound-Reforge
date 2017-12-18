import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import java.net.URLEncoder;

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

    stroke(255);
    fill(0);
    textSize(16);
    
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
            String value = params.getString(property);

            url += "&" + property + "=" + value;
        }
    }

    String [] response = loadStrings(url);
    saveStrings("data.json", response);
    JSONObject jobj = loadJSONObject("data.json");

    return jobj;
}

AudioSample getAudioSampleForQuery (String query) {

    AudioSample sound = null;
    
    // list of search results
    JSONObject searchParams = new JSONObject();

    String encodedQuery = convertencoding(query);
    println("encodedQuery: "+encodedQuery);


    searchParams.setString("query", encodedQuery);
    JSONObject response = callAPI("search/text/", searchParams);

    println("RESPONSE:", response);

    // song data for first result
    JSONArray results = response.getJSONArray("results");
    if (results.size() > 0) {
        // song Id for first result
        int firstSoundId = results.getJSONObject(0).getInt("id");

        // song data for first result (using id)
        JSONObject songData = callAPI("sounds/" + firstSoundId, null);


        if (songData != null) {
            // preview URL for first result in songData->previews->preview-lq-mpw
            String previewUrl = songData.getJSONObject("previews").getString("preview-lq-mp3");

            //println("Song Data:", songData);
            //println("URL:", previewUrl);

            // load sample in to sound engine
            sound = soundengine.loadSample(previewUrl, 1024);
        }
    }
    
    return sound;
}

void keyPressed () {
    if (key == ENTER) {
        query = query.toLowerCase();
        AudioSample sound = getAudioSampleForQuery(query);

        if (sound != null) {
            sound.trigger();
        } else {
            println("No results for " + query);
        }
    }
    else if ((key > 31) && (key != CODED)) {
        query = query + key;
    }
    else if (key == BACKSPACE && query.length() > 0) {
        query = query.substring(0, query.length()-1);
    }
}

void draw() {
    background(255);
    float cursorPosition = textWidth(query);
    line(cursorPosition, 0, cursorPosition, 100);
    text(query, 0, 50);
}