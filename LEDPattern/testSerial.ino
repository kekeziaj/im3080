
#include "FastLED.h"
#define NUM_STRIPS 1
#define NUM_LEDS_PER_STRIP 60
CRGB leds[NUM_STRIPS][NUM_LEDS_PER_STRIP];


boolean once = true;
int val = 0;
int prevVal = 0;
int color = 0;

void setup() {
  // Open serial communications and wait for port to open:
  Serial.begin(57600);
    FastLED.addLeds<NEOPIXEL, 10>(leds[0], NUM_LEDS_PER_STRIP);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }
  Serial.write(1);
}

void loop() { // run over and over
  if (Serial.available()) {
    val = Serial.read();
  }

    for(int i = 0; i < NUM_LEDS_PER_STRIP; i++) {
      color = (60-i)/60.0 * val * 2;
      leds[0][i] = CRGB(color,0,0);
    }
    FastLED.show();


    for(int i = NUM_LEDS_PER_STRIP; i >= 0 ; i--) {
      leds[0][i] = CRGB::Black;
    }
              FastLED.show();
}

