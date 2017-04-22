void setup()
{
	size(1280, 720);
	background(255);
	noLoop();
}

void draw()
{
	textFont(createFont("Arial",16,true));
	fill(0);

	int[][] dataValues = new int[][] {
		{ 10,10,10,12,12,10,15,15,12,13,16,12,12,12 }, // ACER
		{ 40,38,36,34,32,30,28,26,24,22,20,18,16,14 }, // HP
		{ 15,15,15,15,15,15,15,15,15,14,14,13,13,13 }, // ASUS
		{ 20,20,23,23,24,23,22,20,20,18,15,17,19,20 }, // SAMSUNG
		{ 15,17,16,16,17,22,20,24,29,33,35,40,40,41 }, // APPLE
	};

	String[] dataLabels = new String[] { "acer","hp","asus","samsung","apple" };

	int[][] dataColours = {
		{80,43,228},
		{219,59,38},
		{5,218,29},
		{100,55,197},
		{29,142,182},
	};

	drawAreaChart (
		new int[] {100, 100}, // StartXY
		new int[] {700,500}, // Width and Height
		new int[] {2000,2013,13}, // start, stop, step for X-Axis
		new int[] {0,120,6}, // start, stop, step for Y-Axis
		dataValues,
		dataLabels,
		dataColours
	);
}

void drawAreaChart(int[] coords, int[] size, int[] xValues, int[] yValues, int[][] dataValues, String[] dataLabels, int[][] dataColours)
{
	float scaleX = drawAxisX(
		new int[] {coords[0], coords[1] + size[1]}, // X and Y coords
		size[0], // Width of the line
		xValues[0],
		xValues[1],
		xValues[2]
	);

	float scaleY = drawAxisY(
		new int[] {coords[0], coords[1]}, // X and Y coords
		size[1], // Height of the line
		yValues[0],
		yValues[1],
		yValues[2]
	);

	/*
	* Draw values
	*/

	int[] distributions = new int[100];

	for(int i = 0; i < dataValues.length; i++) // Loop through all data, starting at the end
	{
		int[] values = dataValues[i];

		fill(dataColours[i][0],dataColours[i][1],dataColours[i][2]);
		beginShape();

		int[] oldDistributions = new int[distributions.length]; // Keep a copy of old distributions
		arrayCopy(distributions, oldDistributions);

		for(int j = 0; j < values.length; j++) {
			distributions[j] += values[j];
			vertex(coords[0] + (j * scaleX), coords[1] + size[1] - (distributions[j] * scaleY));
		}

		if(i == 0) {
		// Pull the vertex down
			vertex(coords[0] + size[0], coords[1] + size[1]);
			vertex(coords[0], coords[1] + size[1]);
		} else {
			int[] prevValues = dataValues[i - 1];

			for(int k = prevValues.length - 1; k >= 0; k--) {
				vertex(coords[0] + (k * scaleX), coords[1] + size[1] - (oldDistributions[k] * scaleY));
			}
		}

		endShape(CLOSE);
	}

	drawLabels(new int[] {coords[0] + size[0] + 50, coords[1] + 20}, 20, dataLabels, dataColours);
}

float drawAxisY(int[] coords, int size, int valueStart, int valueEnd, int valueStep)
{
	String prefix = "";
	String suffix = "";

	textAlign(RIGHT);

	// Draw the line
	line(coords[0], coords[1], coords[0], coords[1] + size);

	// Calculate the width between each value
	int step = (valueEnd - valueStart) / valueStep;
	float padding = (float) size / (float) valueStep;

	for(int i = 0; i <= valueStep; i++){
		String str = Integer.toString(valueStart + (step * i));
		line(coords[0], coords[1] + size - (padding * i), coords[0] - 6, coords[1] + size - (padding * i));
		text(prefix + str + suffix, coords[0] - 15, coords[1] + size - (padding * i));
	}

	textAlign(LEFT);

	return (float) size / ((float)valueEnd - (float)valueStart);
}

float drawAxisX(int[] coords, int size, int valueStart, int valueEnd, int valueStep)
{
	String prefix = "";
	String suffix = "";

	// Draw the line
	line(coords[0], coords[1], coords[0] + size, coords[1]);

	// Calculate the width between each value
	int step = (valueEnd - valueStart) / valueStep;
	float padding = (float) size / (float) valueStep;

	textAlign(CENTER);

	for(int i = 0; i <= valueStep; i++){
		String str = Integer.toString(valueStart + (step * i));
		line(coords[0] + (padding * i), coords[1], coords[0] + (padding * i), coords[1] + 6);
		text(prefix + str + suffix, coords[0] + (padding * i), coords[1] + 30);
	}

	textAlign(LEFT);

	return (float) size / ((float)valueEnd - (float)valueStart);
}

void drawLabels(int[] coords, int step, String[] labels, int[][] colours)
{
	for(int i = 0; i < labels.length; i++)
	{
		int posX = coords[0];
		int posY = coords[1] + (step * i);
		fill(colours[i][0], colours[i][1], colours[i][2]);
		rect(posX, posY, 10, 10);
		fill(0);
		text(labels[i], posX + 20, posY + 10);
	}
}