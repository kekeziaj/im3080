//Written by Denny
//U1420246C

import processing.sound.*;
import processing.serial.*;
import javax.swing.JFileChooser;
import java.io.File;      
import javax.swing.JFrame;
import javax.swing.JButton;
import java.nio.file.Path;
import java.nio.file.Paths;

import java.awt.event.KeyEvent;

Serial port;  //arduino serial port
SoundFile sample;
Amplitude rms;
File selectedFile;

int val = -1;      // Data received from the serial port
int prevVal = -1; //to detect mode change

int currTime; //to detect end of music

// Used for smoothing
float sum;
float scale=5;
float smooth_factor=0.25;

float x,y,btnWidth,btnHeight; //layout size for "Change Music" button in beat mode

boolean[] isPressed = new boolean[13]; //which key is pressed in piano mode

public void setup() {
    size(640,480);
    for (int i = 0; i < isPressed.length; i++ ) {
      isPressed[i] = false;
    }
    while (Serial.list().length == 0) {

    }
    
          
    x = width * 4/5.0;
    btnWidth = width / 5.5;
    y =  height * 7/8.0;
    btnHeight = height / 10;
    String portName = Serial.list()[0]; //get arduino port
    port = new Serial(this, portName, 57600); 
}      

public void draw() {
     // Set background color, noStroke and fill color
    background(0,0,0);
    stroke(0,0,0);
    fill(255,255,255);
    textSize(height/40);
  
    if (port.available() > 0) { //new mode requested
      prevVal = val; //store previous mode code
      val = port.read();
    }
    
    if (val == 1) {  //Beat analyze
      if (prevVal != 1) { 
        chooseFile(); //initialize mode
        
        
        //Load and play a soundfile
        sample = new SoundFile(this, selectedFile.getAbsolutePath());
        sample.play();
        currTime = millis(); //get elapsed time 
        
        // Create and patch the rms tracker
        rms = new Amplitude(this);
        rms.input(sample);
        prevVal = 1;
      }
      
      //end of initialization
      
      if ((millis() - currTime) > sample.duration()*1000) {
        sum = 0;
        sample.play();
        currTime = millis();
        rms.input(sample);
      }
      
      sum += (rms.analyze() - sum) * smooth_factor;        // smooth the rms data by smoothing factor

      float rms_scaled=sum*(height/2)*scale;       // rms.analyze() return a value between 0 and 1. It's scaled to height/2 and then multiplied by a scale factor
      float arduino_scaled = sum*500;
      System.out.println(arduino_scaled); //DEBUG purpose
      
      if (arduino_scaled > 0.01) {  //prune insignificant amplitude
              port.write(Math.round(arduino_scaled));
      }

      // We draw an ellispe coupled to the audio analysis
      fill(255, 255, 255);
      ellipse(width/2, height/2, rms_scaled, rms_scaled);

      //cursor within "Change Music" box
      if (inRegion(x,y,btnWidth,btnHeight)) {
        fill(128,128,128);
      }
      rect(x, y, btnWidth , btnHeight);
      fill(0,0,0);
      text("Change Music", width * 4.15/5.0, height * 7.5/8.0); 

    }
    
    if (val == 2) { //piano
        for (int index = 0; index < 8; ++index) { //initialize layout 
          if (isPressed[index]) {
             fill(128,128,128);
          } else {
             fill(255,255,255);
          }

          rect(index * width/8, 0, width/8, height); // Left
          if (index > 0 && index < 3) {
            if (isPressed[index+7]) { //the left side minor is pressed (D,E)
              fill(128,128,128);
            } else {
              fill(0,0,0);
            }
            rect(index * width/8 - width/32, 0, width/16,height/2);
          } else if (index > 3 && index < 7) {
            if (isPressed[index+6]) { //the left side minor is pressed (G,A,B)
              fill(128,128,128);
            } else {
              fill(0,0,0);
            }
            rect(index * width/8 - width/32, 0, width/16,height/2);
          }

        }
      }
    }
    
public boolean chooseFile() {
  JFileChooser fileChooser = new JFileChooser(); //prompt music selection
  JFrame frame = new JFrame();
  fileChooser.setCurrentDirectory(new File("C:\\Users\\DennyBasillie\\Downloads\\Compressed\\processing-3.2.1\\BeatWrite\\data"));
  int result = fileChooser.showOpenDialog(frame);
  selectedFile = fileChooser.getSelectedFile();
  
  if (prevVal != 1) { //start of mode (not due to "Change Music")
    while (result != JFileChooser.APPROVE_OPTION || (!selectedFile.getAbsolutePath().endsWith(".mp3") && !selectedFile.getAbsolutePath().endsWith(".wav"))) {
      result = fileChooser.showOpenDialog(frame);
      selectedFile = fileChooser.getSelectedFile();
    }
  } else {
    while (result == JFileChooser.APPROVE_OPTION && !selectedFile.getAbsolutePath().endsWith(".mp3") && !selectedFile.getAbsolutePath().endsWith(".wav")) {
      result = fileChooser.showOpenDialog(frame);
      selectedFile = fileChooser.getSelectedFile();
    }
    
    return (result == JFileChooser.APPROVE_OPTION);
  }
  return true;
}

public void mousePressed() {
  if (val == 1 && inRegion(x,y,btnWidth,btnHeight)) { //only applicable to beat mode and click is on the "Change Music" button
    if (chooseFile()) { //change is valid
      //reinitialize
      sample.stop();
      sum = 0;
      sample = new SoundFile(this, selectedFile.getAbsolutePath());
      sample.play();
      currTime = millis(); //get elapsed time 
      rms.input(sample);
    }
  }
}

public boolean inRegion (float x, float y, float width, float height) { //cursor is in this region (rectangle)
 return (mouseX >= x && mouseX <= x + width && 
      mouseY >= y && mouseY <= y + height);
        
}

public void keyPressed() {
  if (val == 2) { //only applicable to piano mode
      switch (key) {
        case ('S'): 
        case ('s'): if (!isPressed[0]) {
                      try {
                        SoundFile note = new SoundFile(this, dataPath("") + "\\c3.ogg");
                        note.play();
                        isPressed[0] = true;
                        port.write('s'); 
                        
                      } catch (Exception ex) {
                        System.out.println(ex.toString());
                      }
                    }
                    break;
                   
        case ('D'): 
        case ('d'): if (!isPressed[1]) {
                      try {
                        SoundFile note = new SoundFile(this, dataPath("") + "\\d3.ogg");
                        note.play();
                        isPressed[1] = true;
                        port.write('d'); 
                      } catch (Exception ex) {
                        System.out.println(ex.toString());
                      }
                    }
                    break;
        case ('F'): 
        case ('f'): if (!isPressed[2]) {
                      try {
                        SoundFile note = new SoundFile(this, dataPath("") + "\\e3.ogg");
                        note.play();
                        isPressed[2] = true;
                        port.write('f'); 
                      } catch (Exception ex) {
                        System.out.println(ex.toString());
                      }
                    }
                    break;
        case ('G'): 
        case ('g'): if (!isPressed[3]) {
                      try {
                        SoundFile note = new SoundFile(this, dataPath("") + "\\f3.ogg");
                        note.play();
                        isPressed[3] = true;
                        port.write('g'); 
                      } catch (Exception ex) {
                        System.out.println(ex.toString());
                      }
                    }
                    break;
        case ('H'): 
        case ('h'): if (!isPressed[4]) {
                      try {
                        SoundFile note = new SoundFile(this, dataPath("") + "\\g3.ogg");
                        note.play();
                        isPressed[4] = true;
                        port.write('h'); 
                      } catch (Exception ex) {
                        System.out.println(ex.toString());
                      }
                    }
                    break;
        case ('J'): 
        case ('j'): if (!isPressed[5]) {
                      try {
                        SoundFile note = new SoundFile(this, dataPath("") + "\\a3.ogg");
                        note.play();
                        isPressed[5] = true;
                        port.write('j'); 
                      } catch (Exception ex) {
                        System.out.println(ex.toString());
                      }
                    }
                    break;
        case ('K'): 
        case ('k'): if (!isPressed[6]) {
                      try {
                        SoundFile note = new SoundFile(this, dataPath("") + "\\b3.ogg");
                        note.play();
                        isPressed[6] = true;
                        port.write('k'); 
                      } catch (Exception ex) {
                        System.out.println(ex.toString());
                      }
                    }
                    break;
        case ('l'): 
        case ('L'): if (!isPressed[7]) {
                      try {
                        SoundFile note = new SoundFile(this, dataPath("") + "\\c4.ogg");
                        note.play();
                        isPressed[7] = true;
                        port.write('l'); 
                      } catch (Exception ex) {
                        System.out.println(ex.toString());
                      }
                    }
                    break;
        case ('e'): 
        case ('E'): if (!isPressed[8]) {
                      try {
                        SoundFile note = new SoundFile(this, dataPath("") + "\\c3m.ogg");
                        note.play();
                        isPressed[8] = true;
                        port.write('e'); 
                      } catch (Exception ex) {
                        System.out.println(ex.toString());
                      }
                    }
                    break;
        case ('r'): 
        case ('R'): if (!isPressed[9]) {
                      try {
                        SoundFile note = new SoundFile(this, dataPath("") + "\\d3m.ogg");
                        note.play();
                        isPressed[9] = true;
                        port.write('r'); 
                      } catch (Exception ex) {
                        System.out.println(ex.toString());
                      }
                    }
                    break;
        case ('y'): 
        case ('Y'): if (!isPressed[10]) {
                      try {
                        SoundFile note = new SoundFile(this, dataPath("") + "\\f3m.ogg");
                        note.play();
                        isPressed[10] = true;
                        port.write('y'); 
                      } catch (Exception ex) {
                        System.out.println(ex.toString());
                      }
                    }
                    break;
        case ('u'): 
        case ('U'): if (!isPressed[11]) {
                      try {
                        SoundFile note = new SoundFile(this, dataPath("") + "\\g3.ogg");
                        note.play();
                        isPressed[11] = true;
                        port.write('u'); 
                      } catch (Exception ex) {
                        System.out.println(ex.toString());
                      }
                    }
                    break;
        case ('i'): 
        case ('I'): if (!isPressed[12]) {
                      try {
                        SoundFile note = new SoundFile(this, dataPath("") + "\\a3m.ogg");
                        note.play();
                        isPressed[12] = true;
                        port.write('i'); 
                      } catch (Exception ex) {
                        System.out.println(ex.toString());
                      }
                    }
                    break;
      }
  }
}
  
public void keyReleased() {
    if (val == 2) { //only applicable to piano mode
      switch (key) {
        case ('S'): 
        case ('s'): isPressed[0] = false;
                    break;
        case ('D'): 
        case ('d'): isPressed[1] = false;
                    break;
        case ('F'): 
        case ('f'): isPressed[2] = false;
                    break;
        case ('G'): 
        case ('g'): isPressed[3] = false;
                    break;
        case ('H'): 
        case ('h'): isPressed[4] = false;
                    break;
        case ('J'): 
        case ('j'): isPressed[5] = false;
                    break;
        case ('K'): 
        case ('k'): isPressed[6] = false;
                    break;
        case ('l'): 
        case ('L'): isPressed[7] = false;
                    break;
        case ('e'): 
        case ('E'): isPressed[8] = false;
                    break;
        case ('r'): 
        case ('R'): isPressed[9] = false;
                    break;
        case ('y'): 
        case ('Y'): isPressed[10] = false;
                    break;
        case ('u'): 
        case ('U'): isPressed[11] = false;
                    break;
        case ('i'): 
        case ('I'): isPressed[12] = false;
                    break;
      }
  }
}