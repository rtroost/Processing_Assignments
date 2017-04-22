int[] data = {
  13661000,
  10498000,
   8468300,
  43608000,
  30335000,
  25349000,
  21069501
};

String[] names = {"Antartica", "Europa", "Oceanie", "Azie", "Afrika", "Noord-Amerika", "Zuid-Amerika"};
int[][] colors = { {18, 66, 130}, {187, 21, 18}, {80, 184, 38}, {89, 36, 91}, {89, 135, 188}, {227, 77, 31}, {99, 159, 198}  };
float[] percentages = new float[data.length];
float[] angles = new float[data.length];

int graden360 = 0;

void setup() {
  
  for(int i : data){
     graden360 += i; 
  }
  
  for(int i = 0; i < data.length; i++){
    percentages[i] = ((float)data[i]/(float)graden360) * 100;
  }
  
  for(int i = 0; i < percentages.length; i++){
     angles[i] = ((float)360/(float)100)*percentages[i];     
  }
  
  size(640, 360);
  noStroke();
  noLoop();  // Run once and stop
}

void draw() {
  background(100);
  pieChart(300, angles);
  drawLabels(new int[]{500, 80}, 80, names, colors);
}

void pieChart(float diameter, float[] data) {
  float lastAngle = radians(270);
  for (int i = 0; i < data.length; i++) {
    fill(colors[i][0], colors[i][1], colors[i][2]);
    arc(width/2, height/2, diameter, diameter, lastAngle, lastAngle+radians(data[i]));
    lastAngle += radians(data[i]);
  }
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

