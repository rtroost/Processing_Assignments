int[] data2011 = {
  200,
  50,
  50,
};

int[] data2012 = {
  180,
  45,
  45,
};

int[] data2013 = {
  300,
  30,
  30,
};

String[] names = {"HAVO", "VWO", "MBO"};
int[][] colors = { {18, 66, 130}, {187, 21, 18}, {80, 184, 38} };

void setup() { 
  size(1100, 360);
  noStroke();
  noLoop();  // Run once and stop
}

void draw() {
  background(100);
  pieChart(data2011, 300, 175, "2011");
  pieChart(data2012, 300, 500, "2012");
  pieChart(data2013, 300, 825, "2013");
  drawLabels(new int[]{1020, 140}, 80, names, colors);
}

void pieChart(int[] data, float diameter, int offset, String text) {
  int graden360 = 0;
  float[] angles = new float[data.length];
  
  for(int i : data){
     graden360 += i; 
  }
  
  for(int i = 0; i < data.length; i++){
    float percentage = ((float)data[i]/(float)graden360) * 100;
    angles[i] = ((float)360/(float)100)*percentage;
  }
  
  float lastAngle = radians(270);
  for (int i = 0; i < angles.length; i++) {
    fill(colors[i][0], colors[i][1], colors[i][2]);
    arc(offset, height/2, diameter, diameter, lastAngle, lastAngle+radians(angles[i]));
    lastAngle += radians(angles[i]);
  }
  fill(0);
  text(text, offset-10, diameter+50);
}

void drawLabels(int[] startpoint, int step, String[] names, int[][] colors){
    for(int i = 0; i < names.length; i++){
      fill(colors[i][0], colors[i][1], colors[i][2]);
      rect(startpoint[0], startpoint[1], 10, 10);
      fill(0);
      text(names[i], startpoint[0] + 20, startpoint[1]+10);
      startpoint[1] += 30;
    }
}

