String convertencoding(String thestring){

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