import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

// PShape _mapShape;

// HashMap<Point, Float> _data = new HashMap<String, Table>();

private final boolean DEBUG = true;

String file;

int[] nw_max;
int[] se_max;
float zoom;

float scaleX, scaleY;

void setup() {

	// file = dataPath("west.csv");

	/* VOOR WEST */
	// nw_max = new int[] { 87500, 441000};
	// se_max = new int[] { 98000, 431000};

	// nw_max = new int[] { 90500, 432000};
	// se_max = new int[] { 92000, 431000};

	/* VOOR OOST */
	file = dataPath("oost.csv");

	nw_max = new int[] { 56750, 447000};
	se_max = new int[] { 75000, 437000};

	zoom = 0.8f;

	/* Calculate proper window size */
	int window_width = (int)(((se_max[0] - nw_max[0]) / 10) * zoom);
	int window_height = (int)(((nw_max[1] - se_max[1]) / 10) * zoom);

	size(window_width, window_height);
	background(255);
	noLoop();

	// float scaleX = map(1, nw_max[0], se_max[0], 0, width);
	// float scaleY = map(1, nw_max[1], se_max[1], 0, height);

	loadAndVisualize(0); // Load data
}

void draw() {}

void loadAndVisualize(int amount_to_print) {
	int count = 0;
	long startTime = System.currentTimeMillis();

	rectMode(CORNERS);
	colorMode(RGB);

	BufferedReader br = null;
	String line = "";
	String cvsSplitBy = ",";

	try {

		br = new BufferedReader(new FileReader(file));

		while ((line = br.readLine()) != null && (count < amount_to_print || amount_to_print == 0)) {

			String[] ss = line.split(cvsSplitBy);

			float cX = Float.parseFloat(ss[0]);
			float cY = Float.parseFloat(ss[1]);
			float cZ = Float.parseFloat(ss[2]);
			int sh = Integer.parseInt(ss[3]);

			color c = color(0);

			if(sh == -1)
				c = color(255);
			else if(sh == 0)
				c = color(130);
			else if(sh == 1)
				c = color(0);

			if( ! ((cX >= nw_max[0] && cX <= se_max[0]) && (cY <= nw_max[1] && cY >= se_max[1])))
				continue;

			drawBlock(new PVector(cX, cY), c);
			count++;

			if(DEBUG)
				if(count % 10000 == 0) println("Shadows drawn: " + count);
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

	draw();

	println("Final count: " + count + " shadows drawn in " + (System.currentTimeMillis() - startTime) + " milliseconds.");
}

void drawBlock(PVector p, color c) {
	fill(c);
	noStroke();

	float adjusted_cX = map(p.x, nw_max[0], se_max[0], 0, width);
	float adjusted_cY = map(p.y, nw_max[1], se_max[1], 0, height);

	// rect(
	// 	adjusted_cX - 2, adjusted_cY - 2,
	// 	adjusted_cX + 2, adjusted_cY + 2);

	rect(
		adjusted_cX, adjusted_cY,
		adjusted_cX + 2, adjusted_cY + 2);
}

