import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
// import blobDetection.*;
import rita.*;
import java.util.*;

import java.net.URLEncoder;

import ddf.minim.*;

Minim soundengine;
AudioSample freesound; 
RiTa rita;
RiString rs;

String query = rita.randomWord();
String baseUrl = "https://freesound.org/apiv2/";
String[] rhymes;
String stress;
String phonemes;
JSONArray tags;
int duration;
PImage spectrumImage;

float gain;
float volume;

// BlobDetection blobDetection;

boolean isLoading = false;

/*
    query
    search 
    returns list of sounds with IDs
    use an ID to get specific sound data from /sounds/<sound_id>
    returns 'preview' field as url
    use url as argument to Minim method to play audio
*/
void setup() {
    fullScreen();
    frameRate(30);
    background(255);

    stroke(255);
    fill(0);
    textSize(16);
    
    soundengine = new Minim(this);
    rita = new RiTa();
    rs = new RiString(query);
    rhymes = rita.rhymes(query);
    stress = rita.getStresses(query);
    phonemes = rita.getPhonemes(query);
    // blobDetection = new BlobDetection(width, height);

    query = query.toLowerCase();
    freesound = getAudioSampleForQuery(query);
}

/*
    Returns a JSON object containing the freesound API response given an 
    endpoint and paramenters.
*/
JSONObject callAPI (String endpoint, JSONObject params) {
    // isLoading = true;

    String url = baseUrl + endpoint + "?token=" + apiKey + "&format=json";

    if (params != null) {
        String [] properties = (String[]) params.keys()
            .toArray(new String[params.size()]);

        for (int i = 0; i < params.size(); i++) {
            // println(properties[i]);
            String property = properties[i];
            String value = params.getString(property);

            url += "&" + property + "=" + value;
        }
    }

    String [] response = loadStrings(url);
    saveStrings("data.json", response);
    JSONObject jobj = loadJSONObject("data.json");

    // isLoading = false;

    return jobj;
}

/*
    returns an AudioSample for the given query by calling the freesound API
    if there are no results, returns null
*/
AudioSample getAudioSampleForQuery (String query) {

    AudioSample sound = null;
    
    // list of search results
    JSONObject searchParams = new JSONObject();

    String encodedQuery = convertencoding(query);
    println("encodedQuery: " + encodedQuery);


    searchParams.setString("query", encodedQuery);
    JSONObject response = callAPI("search/text/", searchParams);

    // println("RESPONSE:", response);

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
            tags = songData.getJSONArray("tags");
            duration = songData.getInt("duration");
            // println(duration);
            
            // get spectrum image
            String spectrumUrl = songData.getJSONObject("images").getString("spectral_l");
            spectrumImage = loadImage(spectrumUrl);

            // get blobs
            if (spectrumImage != null) {
                PImage img = spectrumImage.get(0, 0, 5, 5); 
                img.loadPixels();
                // blobDetection.computeBlobs(img.pixels);
                // println(blobDetection.getBlobNb());
            };

            // load sample in to sound engine
            sound = soundengine.loadSample(previewUrl, 1024);
        };
    };
    
    return sound;
}

// void getStressValues (String stress) {
//      // Convert RiTA Stress string to int[]
//     String[] stressvalues = stress.replaceAll("\\[", "").replaceAll("\\]", "").replaceAll("\\s", "").replaceAll("/", " ").split("/");
//     int[] stresses = new int[stressvalues.length];
//     for (int i = 0; i < stressvalues.length; i++) {
//         try {
//             stresses[i] = Integer.parseInt(stressvalues[i]);
//         } catch (NumberFormatException nfe) {
//          //NOTE: write something here if you need to recover from formatting errors
//         };
//     // println(stressvalues);
//     };

//     stress = rita.getStresses(query);
//     for (int index = 0; index < stressvalues.length; index = index + duration/stressvalues) {
//         stressvalues[index];
//     }
//     if (index == 0) {
//         freesound.mute();
//     } else if (index == 1) {
//         freesound.unmute();
//     }
// }

void keyPressed () {
    if (key == ENTER && query.length() > 0) {
            rhymes = rita.rhymes(query);
            textY = 0;
            //println(rhymes);
            int index = int(random(rhymes.length));
            if (rhymes.length > 0) {
                query = rhymes[index];
            }
            freesound = getAudioSampleForQuery(query);
        if (freesound != null) {
            freesound.trigger();
            // println(freesound.duration());
        } else {
            println("No results for " + query);
        }
    }
    if ((key > 31) && (key != CODED)) {
        query = query + key;
    }
    if (key == TAB) {
        query = rita.randomWord();
        freesound = getAudioSampleForQuery(query);
    }
    else if (key == BACKSPACE && query.length() > 0) {
        query = query.substring(0, query.length()-1);
    };
}

int textY = 0;

void draw() {
    background(80);
    if (spectrumImage != null) {
        // tint(255,50);
        image(spectrumImage, 0, 0, width, height);
    }
    float cursorPosition = textWidth(query);
    fill(255);
    text(query, 0, 50);

    // we draw the waveform by connecting neighbor values with a line
    // we multiply each of the values by 50 
    // because the values in the buffers are normalized
    // this means that they have values between -1 and 1. 
    // If we don't scale them up our waveform 
    // will look more or less like a straight line.
    
    // visualizer
    int amplitude = height;
    int spaceBetween = 150;

    if (freesound != null) {
        for(int i = 0; i < freesound.bufferSize() - 1; i++) {
            line(i, amplitude + freesound.left.get(i)*amplitude, 
                    i+1, amplitude + freesound.left.get(i+1)*amplitude);
            line(i, spaceBetween + freesound.right.get(i)*amplitude, i+1, 
                    spaceBetween + freesound.right.get(i+1)*amplitude);
        }
    }

    if (tags != null) {

        for (int i = 0; i < tags.size(); ++i) {
            String tag = tags.getString(i);
            text(tag, 200, textY - i * 40);
        }
        textSize(30);
        textY++;
        // int x;
        // int y;

    };

    String[] stressvalues = stress.replaceAll("\\[", "").replaceAll("\\]", "").replaceAll("\\s", "").replaceAll("/", " ").split("/");
    int[] stresses = new int[stressvalues.length];
    for (int i = 0; i < stressvalues.length; i++) {
        try {
            stresses[i] = Integer.parseInt(stressvalues[i]);
        } catch (NumberFormatException nfe) {
         //NOTE: write something here if you need to recover from formatting errors
        };
    };

    // for (int index = 0; index < stressvalues.length; index = index + duration / stressvalues) {
    //     stressvalues[index];
    // }
    // if (index == 0) {
    //     freesound.mute();
    // } else if (index == 1) {
    //     freesound.unmute();
    // };

    stress = rita.getStresses(query);
    phonemes = rita.getPhonemes(query);
    text(stress, 0, 100);
    text(phonemes, 0, 150);
}