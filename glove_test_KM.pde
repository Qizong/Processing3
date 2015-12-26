import processing.serial.*;

Serial myPort;        // The serial port
int xPos = 100;         // horizontal position of the graph 

//Variables to draw a continuous line.
int lastxPos=100;
int lastheight=0;
int lastheightK=0;

PFont f; 

float KalmanPlot=0.0;
float varVolt = 0.5;
float varProcess = 0.005;
float Pc = 0.0;
float G = 0.0;
float P = 1.0;
float Xp = 0;
float Zp = 0;
float Xe = 0;

void setup () {
  // set the window size:
  size(1000, 800);        
  preparePlot();   

  // List all the available serial ports
  println(Serial.list());
  // Check the listed serial ports in your machine
  // and use the correct index number in Serial.list()[].
  myPort = new Serial(this, "COM3", 9600);  //
  // A serialEvent() is generated when a newline character is received :
  myPort.bufferUntil('\n');
  
  f = createFont("Arial",20,true); //Create Font
  //textFont(f,20);
  
}
void draw () {
   // Eraser Block
    textSize(20);
    fill(100);
    stroke(100);
    rect(width/2, height - map(3, 0, 20, 0, height)-50,100,100);
    
    // Get Serial Data
    String inString = myPort.readStringUntil('\n');
    if (inString != null) {
    inString = trim(inString);                // trim off whitespaces.
    float inByte = float(inString);           // convert to a number.
    //println(inByte);
    float Amp = (inByte)/330*1000;
    println(Amp);
    
    fill(0,0,205);
    text("Real (mA): ", width/2 - 110, height - map(3, 0, 20, 0, height)); 
    text(Amp, width/2, height - map(3, 0, 20, 0, height));
    
    
    if(Float.isNaN(inByte)){
        inByte = 0.0;  
    }
       
    Pc = P + varProcess;
    G = Pc / (Pc + varVolt);
    P = (1 - G) * Pc;
    Xp = Xe;
    Zp = Xp;
    Xe = G * (inByte - Zp) + Xp;
    float Kalman = (Xe)/330*1000;  
    
    fill(205,0,0);
    text("Kalman (mA): ", width/2 - 120, height - map(2, 0, 20, 0, height)); 
    text(Kalman, width/2, height - map(2, 0, 20, 0, height));
    
    inByte = map(Amp, 0, 10, 0, height); //map to the screen height.    
    KalmanPlot = map(Kalman, 0, 10, 0, height); //map to the screen height.
    
    //Drawing a line from Last inByte to the new one.
    stroke(0,0,205);     //stroke color
    strokeWeight(2);        //stroke wider
    line(lastxPos, lastheight, xPos, height - inByte); 
        
    stroke(205,0,0);     
    strokeWeight(2);        
    line(lastxPos, lastheightK, xPos, height - KalmanPlot); 
    
    
    lastxPos= xPos;
    lastheight= int(height-inByte);
    lastheightK= int(height-KalmanPlot);
    
    
    
    
    // at the edge of the window, go back to the beginning:
    if (xPos >= (width-100)) {
      xPos = 100;
      lastxPos= 100;
      preparePlot();
    } 
    else {
      // increment the horizontal position:
      xPos++;
    }
  }
}



void preparePlot(){
   background(100);
   stroke(255, 255, 255);  
   strokeWeight(1);
   
   textSize(20);
   fill(255);
   line(100, 0, 100, height); 
   line(100, height - map(3, 0, 10, 0, height), 
        width, height - map(3, 0, 10, 0, height) );  
   line(90, height - map(8, 0, 10, 0, height), 100, 
        height - map(8, 0, 10, 0, height)); 
   text("8 mA", 20, height - map(8, 0, 10, 0, height));   
   line(90, height - map(2, 0, 10, 0, height), 
        100, height - map(2, 0, 10, 0, height)); 
   text("2 mA", 20, height - map(2, 0, 10, 0, height));
   line(90, height - map(5, 0, 10, 0, height), 
        100, height - map(5, 0, 10, 0, height)); 
   text("5 mA", 20, height - map(5, 0, 10, 0, height));   
   text("Time", width/2, height - map(2.5, 0, 10, 0, height)); 
        
   textSize(15);
   text("Press key to exit", width - 150, 
        height - map(9.5, 0, 10, 0, height));   
   
   textSize(30);
   text("Real Time Operating Current - Sensor ", width/4, height - map(9, 0, 10, 0, height)); 
}
  
void keyPressed() {
  exit(); // Stops the program
}