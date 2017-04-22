
void setup() {
	setSize(500,500);
	noLoop();
}

void draw() {
	
	color[][] colors = new color[width][height];
	colors[0][0] = color(255,0,0);
	colors[width - 1][0] = color(255,255,0);
	colors[0][height - 1] = color(0,0,255);
	colors[width - 1][height - 1] = color(255,0,0);
	
	for (int x = 0; x < width; x++)
	{
    	for (int y = 0; y < height; y++ )
    	{
    		color colorTop, colorBottom, colorLeft, colorRight;
    		
    		// Get colors from the 4 nearest pixels
    		colorTop =  (y-1 > 0) ? colors[x][y - 1] : color(255,255,255);
    		colorBottom = (y+1 < height) ? colors[x][y + 1] : color(255,255,255);
    		colorLeft = (x-1 > 0) ? colors[x - 1][y] : color(255,255,255);
    		colorRight = (x+1 < width) ? colors[x + 1][y] : color(255,255,255);
    		
    		// Calculate the new color
    		color c = color(
    			(red(colorTop) + red(colorBottom) + red(colorLeft) + red(colorRight)) / 4,
    			(green(colorTop) + green(colorBottom) + green(colorLeft) + green(colorRight)) / 4,
    			(blue(colorTop) + blue(colorBottom) + blue(colorLeft) + blue(colorRight)) / 4
    		);
    		
    		// Apply the new color to the pixel
    		colors[x][y] = c;
    		
    		println("Setting color for P(" + x + "," + y + ")");
    	}    	
	}
	
	for (int x = 0; x < width; x++)
	{
    	for (int y = 0; y < height; y++ )
    	{
    		fill(colors[x][y]);
    		rect(x,y,1,1);    		
    	}    	
	}
}