/**
 * Polargraph Controller - Processing 4
 * 
 * A desktop application for controlling a polargraph machine
 * (networked drawing robot using string tension and stepper motors)
 * 
 * Communicates with machine via ASCII command language over serial link
 * 
 * Version: 1.0 (Processing 4 Rewrite)
 * Author: Migration from Sandy Noble original (euphy)
 * 
 * License: GNU General Public License v3
 * https://github.com/euphy/polargraphcontroller
 */

import processing.serial.*;

// Application state
int majorVersionNo = 3;
int minorVersionNo = 0;
int buildNo = 1;

String programTitle = "Polargraph Controller v" + majorVersionNo + "." + minorVersionNo + " build " + buildNo;

// Core components
Machine displayMachine;
SerialComm serialComm;
CommandQueue commandQueue;
UIManager uiManager;

// Application state
boolean isRunning = false;

void settings() {
  size(1200, 800);
}

void setup() {
  println(programTitle);
  println("Processing: 4.0+");
  
  // Initialize core components
  displayMachine = new Machine(2790, 2347, 200.0, 40.0);
  serialComm = new SerialComm();
  commandQueue = new CommandQueue();
  uiManager = new UIManager();
  
  // Load configuration
  loadConfiguration();
  
  // Setup display
  background(100);
  // run continuously so UI updates
}


void draw() {
  background(100);

  // Draw display machine representation
  displayMachine.display();

  // Draw UI panels
  uiManager.display();

  // Draw status
  drawStatusBar();

  // process any queued commands
  processQueue();
}

/**
 * Send next command from queue if running and machine is ready
 */
void processQueue() {
  if (commandQueue.isRunning() && serialComm.isConnected()) {
    // Only send next command if machine signals it's ready
    if (serialComm.isMachineReady()) {
      String cmd = commandQueue.pop();
      if (cmd != null) {
        serialComm.sendCommand(cmd);
      } else {
        // Queue finished
        commandQueue.stop();
        println("Command queue complete");
      }
    }
  }
}

void drawStatusBar() {
  fill(50);
  rect(0, height - 30, width, 30);
  
  fill(200);
  textAlign(LEFT, CENTER);
  text("Commands in queue: " + commandQueue.size(), 10, height - 15);
  
  if (serialComm.isConnected()) {
    fill(0, 255, 0);
    text("Serial: CONNECTED", 300, height - 15);
  } else {
    fill(255, 0, 0);
    text("Serial: DISCONNECTED", 300, height - 15);
  }
}

void keyPressed() {
  // Global keyboard shortcuts
  if (key == 'q' || key == 'Q') {
    commandQueue.clear();
    println("Command queue cleared");
  }
}

void mousePressed() {
  uiManager.handleMousePress(mouseX, mouseY);
}

Config cfg;

void loadConfiguration() {
  println("Loading configuration...");
  cfg = new Config();

  // apply settings to machine/display
  displayMachine.setSize((int)cfg.machineWidth, (int)cfg.machineHeight);
  displayMachine.setPenLiftPositions((int)cfg.penUpPosition, (int)cfg.penDownPosition);
  displayMachine.setPenWidth(cfg.penWidth);
  displayMachine.setHomePoint(cfg.homeX, cfg.homeY);

  // pre-populate queue with initial handshake commands
  // pen width, motor speed/accel
  commandQueue.add("C02," + cfg.penWidth + ",END");
  commandQueue.add("C31," + cfg.motorMaxSpeed + ",END");
  commandQueue.add("C32," + cfg.motorAccel + ",END");

  println("Configuration applied: pen up=" + cfg.penUpPosition + ", down=" + cfg.penDownPosition);
}


void saveConfiguration() {
  // TODO: Save to properties file
  println("Saving configuration...");
}

/**
 * Global serial event callback (required by Processing)
 * Delegates to SerialComm instance for message handling
 */
void serialEvent(Serial p) {
  if (serialComm != null) {
    serialComm.serialEvent(p);
  }
}
