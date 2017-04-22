PFont f;
float test = 0.0; 
int totalheight = 330;

int[] data = {120, 150, 180, 60};

void setup() {
  size(1000, 500);
  
  f = createFont("Arial",16,true);
  
  background(255);
  noLoop();
}

void draw() {
//  line(0,0 , 100, 100);
  
//  quad(10,10, 10,50, 50,50, 50,10);
  
  drawVertical(30, 360, 400, 100, 200, 20);
  drawHorizontal(100, 360, 100, 500, 100, "kwartaal");
  
  fill(0,0,255);
  
  int startPoint = 130;
  
  for(int i : data){
//    println((float)i/20);
//    println((int)(((float)i/20)*30));
//    println((int)(totalheight - ((float)i/20)*30));
    plotBar(startPoint, (int)(totalheight - ((float)i/20)*30), 60, (int)(((float)i/20)*30));
    startPoint+=100;
  }
  
}

void drawGrid(int step) {
 System.out.println(width); 
 System.out.println(height);
 
 for(int i = step; i < width; i+=step){
     line(0,i , width, i);
 }
 
 for(int i = step; i < height; i+=step){
     line(i,0 , i, height);
 }
}

void drawVertical(int step, int maxheight, int maxwidth, int offset, int maxText, int stepText){
  textFont(f,16);
  fill(0);
  
  int displayText = maxText;
  
  for(int i = step; i < maxheight; i+=step){
     line(offset,i , maxwidth+offset, i);
     text(Integer.toString(displayText), offset - 50, i);
     displayText-=20;
  }
}

void drawHorizontal(int barWidth, int barHeightBottom ,int start, int end, int step, String text){
  textFont(f,16);
  fill(0);
  
  int textcount = 1;
  int padding = 30;
  
  for(int i = start; i < end; i+=step){
//     line(offset,i , maxwidth+offset, i);
     text(text + Integer.toString(textcount), i+padding, barHeightBottom);
     textcount+=1;
  }
  
  
}

void plotBar(int topx, int topy, int bottomx, int bottomy){
  fill(0,0,255);
  rectMode(CORNER);
  
  rect(topx, topy, bottomx, bottomy);
}

