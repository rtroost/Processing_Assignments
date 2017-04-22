import controlP5.*;
import java.util.Map.Entry;
import java.util.Collections;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;

/* Everything controls */
ControlP5 cp5;
CheckBox checkbox;
Chart myChart;

PFont f;

PShape map;
Table tabledata;

String yearDate = "2013";

HashMap<String, WeatherData> data = new HashMap<String, WeatherData>();

void setup() {
    
  f = createFont("Arial",16,true);

  cp5 = new ControlP5(this);
  
  makeControls();

  size(1000, 700);
  background(255);
  
  loadData(dataPath("etmgeg_344.txt"));
  println(data.size());

}

void draw() {


}

void makeControls() {
 checkbox = cp5.addCheckBox("checkBox")
  .setPosition(20, 20)
  .setColorForeground(color(0))
  .setColorActive(color(120))
  .setColorLabel(color(120))
  .setSize(40, 40)
  .setItemsPerRow(5)
  .setSpacingColumn(150)
  .setSpacingRow(20)
  .addItem("U (relatieve vochtigheid)", 1f)
  .addItem("P (luchtdruk)", 2f)
  .addItem("FF (windsnelheid)", 3f)
  .addItem("T (temperatuur)", 4f)
  .addItem("SQ (duur van zonneschijn)", 5f)
  ;
}

void controlEvent(ControlEvent theEvent) {
  
  ArrayList<Integer> activeBoxes = new ArrayList<Integer>();
  
  if (theEvent.isFrom(checkbox)) {
    println("Checkbox Trigger");
    for (int i=0; i < checkbox.getArrayValue().length; i++) {
      int n = (int)checkbox.getArrayValue()[i];
      if(n==1) {
        activeBoxes.add(i);
      }
    }
    
    if(activeBoxes.size() == 2){
      drawPlot(activeBoxes.get(0), activeBoxes.get(1));
    }
 
  }
}

void drawPlot(int xas, int yas){
  println(xas);
  println(yas);
  
  noStroke();
  fill(255);
  rect(0, 80, width, height);
  fill(0);
  
  String titleX = null;
  String titleY = null;
  
  ArrayList<Float> xData = new ArrayList<Float>();
  ArrayList<Float> yData = new ArrayList<Float>();
  
  for (Entry<String, WeatherData> entry : data.entrySet()) {
      String date = entry.getKey();
      WeatherData weer = entry.getValue();

      Float x = weer.getOnIndex(xas);
      Float y = weer.getOnIndex(yas);
      
      if(titleX == null){ titleX = weer.getTitleOnIndex(xas); }
      if(titleY == null){ titleY = weer.getTitleOnIndex(yas); }
       
      xData.add(x);
      yData.add(y);
      
  }
  
  Float minValueX = Collections.min(xData);
  Float maxValueX = Collections.max(xData);
  
  Float minValueY = Collections.min(yData);
  Float maxValueY = Collections.max(yData);  
  
  textFont(f, 12);
  
  drawAxisY(78, 100, 502, Math.round(minValueY), Math.round(maxValueY), 10);
  drawAxisX(78, 602, 834, Math.round(minValueX), Math.round(maxValueX), 10);
  
  noStroke();
  
  text(titleX, 10, 350);
  text(titleY, 500, 640);
  
  for(int i = 0; i < xData.size(); i++){
     Float toMapX = xData.get(i);
     Float toMapY = yData.get(i);
         
     Float cordX = map(toMapX, minValueX, maxValueX, 80, 922);
     Float cordY = map(toMapY, minValueY, maxValueY, 100, 602);
     
     ellipse(cordX-2, cordY-2, 4, 4);
  }
  
}

void loadData(String file) {
  BufferedReader br = null;
  String line = "";
  String cvsSplitBy = ",";

  try {
    
    //println(file);

    br = new BufferedReader(new FileReader(file));
    br.readLine(); // Skip header
    br.readLine(); // Skip empty line

    while ((line = br.readLine()) != null) {
      // use comma as separator
      String[] split = line.split(cvsSplitBy);

      String date = split[1].trim();
      if(date.substring(0, 4).contains(yearDate)){
   
        data.put(date, new WeatherData(
          Float.valueOf(split[35].trim()), // UG
          Float.valueOf(split[25].trim()), // PG
          Float.valueOf(split[4].trim()),  // FG
          Float.valueOf(split[11].trim()), // TG
          Float.valueOf(split[18].trim())  // SQ
        ));
        
      }
    }

  } catch (FileNotFoundException e) {
    e.printStackTrace();
  } catch (IOException e) {
    e.printStackTrace();
  } finally {
    if (br != null) {
      try {
        br.close();
      } catch (IOException e) {
        e.printStackTrace();
      }
    }
  }
}

void drawAxisX(int cX, int cY, int size, int valueStart, int valueEnd, int valueStep) {
    String prefix = "";
    String suffix = "";
  
    textAlign(CENTER);
  
    stroke(0);
    strokeWeight(1);
    fill(0);
    // Draw the line
    line(cX, cY, cX + size, cY);
  
    // Calculate the width between each value
    int step = (valueEnd - valueStart) / valueStep;
    float padding = (float) size / (float) valueStep;
  
    for(int i = 0; i <= valueStep; i++){
      String str = Integer.toString(valueStart + (step * i));
      line(cX + (padding * i), cY, cX + (padding * i), cY + 6 );
      text(prefix + str + suffix, cX + (padding * i), cY + 20);
    }
  
    textAlign(LEFT);
}

void drawAxisY(int cX, int cY, int size, int valueStart, int valueEnd, int valueStep) {
    String prefix = "";
    String suffix = "";
  
    textAlign(RIGHT);
  
    stroke(0);
    strokeWeight(1);
    fill(0);
    // Draw the line
    line(cX, cY, cX, cY + size);
  
    // Calculate the width between each value
    int step = (valueEnd - valueStart) / valueStep;
    float padding = (float) size / (float) valueStep;
  
    for(int i = 0; i <= valueStep; i++){
      String str = Integer.toString(valueStart + (step * i));
      line(cX, cY + size - (padding * i), cX - 6, cY + size - (padding * i));
      text(prefix + str + suffix, cX - 15, cY + size - (padding * i));
    }
  
    textAlign(LEFT);
}

class WeatherData {
  
  public Float U;
  public Float P;
  public Float FF;
  public Float T;
  public Float SQ;
  
  public WeatherData(Float u, Float p, Float ff, Float t, Float sq){
    this.U = u;
    this.P = p;
    this.FF = ff;
    this.T = t;
    this.SQ = sq;
    
  }
  
  public void printData(){
    println("U: " + this.U);
    println("P: " + this.P);
    println("FF: " + this.FF);
    println("T: " + this.T);
    println("SQ: " + this.SQ);
    
  }
  
  public Float getOnIndex(int i){
    switch (i) {    
      case 0:
          return this.U;
      case 1:
          return this.P;
      case 2:
          return this.FF;
      case 3:
          return this.T;
      case 4:
          return this.SQ;
      default:
          return 0f;
    }
    
  }
  
  public String getTitleOnIndex(int i){
    switch (i) {    
      case 0:
          return "U";
      case 1:
          return "P";
      case 2:
          return "FF";
      case 3:
          return "T";
      case 4:
          return "SQ";
      default:
          return " ";
    }
    
  }
   
}

