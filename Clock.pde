/*
 * Digital Clock
 *
 * Copyright (c) 2011 Jacob Swartwood
 */

int element[7] = { 2, 3, 4, 5, 6, 7, 8 };

int digit[4] = { 10, 11, 12, 13 };

int num[10][7] = {
	{ LOW, LOW, LOW, LOW, LOW, LOW, HIGH },
	{ HIGH, LOW, LOW, HIGH, HIGH, HIGH, HIGH },
	{ LOW, LOW, HIGH, LOW, LOW, HIGH, LOW },
	{ LOW, LOW, LOW, LOW, HIGH, HIGH, LOW },
	{ HIGH, LOW, LOW, HIGH, HIGH, LOW, LOW },
	{ LOW, HIGH, LOW, LOW, HIGH, LOW, LOW },
	{ LOW, HIGH, LOW, LOW, LOW, LOW, LOW },
	{ LOW, LOW, LOW, HIGH, HIGH, HIGH, HIGH },
	{ LOW, LOW, LOW, LOW, LOW, LOW, LOW },
	{ LOW, LOW, LOW, HIGH, HIGH, LOW, LOW },
};

unsigned int start_time = millis();
unsigned int time = millis();

int hours;
int minutes;
int seconds;
int last_seconds = -1;

void setup() {
	for (int i = 0; i < 7; i++) {
		pinMode(element[i], OUTPUT);
	}
	
	for (int i = 0; i < 4; i++) {
		pinMode(digit[i], OUTPUT);
	}
	
	Serial.begin(9600);
}

void writeDigit( int d, int n ) {
	d = d % 4;
	n = n % 10;
	
	for (int i = 0; i < 7; i++) {
		digitalWrite(element[i], (n < 0 ? HIGH : num[n][i]));
	}

	for (int i = 0; i < 4; i++) {
		digitalWrite(digit[i], (i == d ? HIGH : LOW));
	}
	
	delay(5);
}

void loop() {
	time = (millis() - start_time) / 1000;
	hours = (time / (60 * 60)) % 12;
	minutes = (time / 60) % 60;
	seconds = time % 60;
	
	if (seconds != last_seconds) {
		last_seconds = seconds;
		Serial.print(hours);
		Serial.print(":");
		Serial.print(minutes);
		Serial.print(":");
		Serial.println(seconds);
	}
	
	writeDigit(0, hours / 10);
	writeDigit(1, hours % 10);
	writeDigit(2, minutes / 10);
	writeDigit(3, minutes % 10);
}
