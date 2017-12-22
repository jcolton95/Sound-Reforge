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
import rita.*; 
import java.util.*; 
import java.net.URLEncoder; 
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
String[] rhymes;
RiTa rita;
RiString rs;

boolean isLoading = false;

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

    stroke(255);
    fill(0);
    textSize(16);
    
    soundengine = new Minim(this);
    
    rita = new RiTa();
    rs = new RiString(query);
    rhymes = rita.rhymes(query);
}

/*
    Returns a JSON object containing the freesound API response given an 
    endpoint and paramenters.
*/
public JSONObject callAPI (String endpoint, JSONObject params) {
    isLoading = true;

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

    isLoading = false;

    return jobj;
}

/*
    returns an AudioSample for the given query by calling the freesound API
    if there are no results, returns null
*/
public AudioSample getAudioSampleForQuery (String query) {

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

public void keyPressed () {
    if (key == ENTER) {
        query = query.toLowerCase();
        freesound = getAudioSampleForQuery(query);
        rhymes = rita.rhymes(query);
        println(rhymes);
        if (freesound != null) {
            freesound.trigger();
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

public void draw() {
    background(80);

    float cursorPosition = textWidth(query);
    line(cursorPosition, 0, cursorPosition, 100);
    text(query, 0, 50);

    // we draw the waveform by connecting neighbor values with a line
    // we multiply each of the values by 50 
    // because the values in the buffers are normalized
    // this means that they have values between -1 and 1. 
    // If we don't scale them up our waveform 
    // will look more or less like a straight line.
    
    // visualizer
    int amplitude = 50;
    int spaceBetween = 150;

    if (freesound != null) {
        for(int i = 0; i < freesound.bufferSize() - 1; i++) {
            line(i, amplitude + freesound.left.get(i)*amplitude, 
                    i+1, amplitude + freesound.left.get(i+1)*amplitude);
            line(i, spaceBetween + freesound.right.get(i)*amplitude, i+1, 
                    spaceBetween + freesound.right.get(i+1)*amplitude);
        }
    }

    if (isLoading == false) {
        AudioSample sound = getAudioSampleForQuery(rita.randomWord());
        sound.trigger();
        println("new word");
    }

   
    // Map data = rs.features();

    // float y = 15;
    // for (Iterator it = data.keySet().iterator(); it.hasNext();) {
    //     String key = (String) it.next();
    //     text(key + ": " + data.get(key), width/3, y += 26);
    // }

}
String apiKey = "A9i0clTQls40EREfWVaVNUycsGd7Y1XKN3ExH5VE";
public String convertencoding(String thestring){

  //convert thestring to utf-8
  String encoded = null;
  try { 
    encoded = java.net.URLEncoder.encode(thestring, "UTF-8");
     } catch (Exception e) {} 
 
  //workaround problem with artists like "Iron & Wine"
  String Strlist1[] = split(encoded, "%26");
  encoded = join(Strlist1, "%2526");
 
  //workaround the "+" problem with artists like "+/-"
  String Strlist2[] = split(encoded, "%2B");
  encoded = join(Strlist2, "%252B");

  //workaround the "/" problem with artists like "+/-"
  String Strlist3[] = split(encoded, "%2F");
  encoded = join(Strlist3, "%252F");


  return encoded;
}
  public void settings() {  size(500, 500); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#030000", "--hide-stop", "freesound_test" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
