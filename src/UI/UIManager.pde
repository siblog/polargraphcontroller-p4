/**
 * UIManager.pde
 * 
 * Manages the user interface panels and controls (MVP - no external GUI library)
 * Built with Processing primitives for maximum compatibility and control
 */

class UIManager {
  
  ArrayList<UIPanel> panels;
  Rectangle controlArea;
  
  UIManager() {
    panels = new ArrayList<UIPanel>();
    
    // Define control area (right side of screen)
    controlArea = new Rectangle(700, 50, 450, 700);
    
    // Initialize panels
    initializePanels();
  }
  
  void initializePanels() {
    // Status Panel
    panels.add(new StatusPanel(new Rectangle(710, 60, 430, 80)));
    
    // Serial Connection Panel
    panels.add(new SerialPanel(new Rectangle(710, 150, 430, 100)));
    
    // Command Queue Panel
    panels.add(new QueuePanel(new Rectangle(710, 260, 430, 150)));
    
    // Controls Panel
    panels.add(new ControlsPanel(new Rectangle(710, 420, 430, 150)));
  }
  
  void display() {
    // Draw panel backgrounds
    fill(60);
    stroke(100);
    strokeWeight(1);
    rect(controlArea.getLeft(), controlArea.getTop(), 
         controlArea.getWidth(), controlArea.getHeight());
    
    // Display all panels
    for (UIPanel panel : panels) {
      panel.display();
    }
  }
  
  void handleMousePress(int x, int y) {
    for (UIPanel panel : panels) {
      panel.handleMousePress(x, y);
    }
  }
}

// ==================== BASE PANEL CLASS ====================

abstract class UIPanel {
  protected Rectangle bounds;
  protected String title;
  
  UIPanel(Rectangle bounds) {
    this.bounds = bounds;
  }
  
  abstract void display();
  abstract void handleMousePress(int x, int y);
  
  protected void drawPanelHeader(String title) {
    fill(80);
    rect(bounds.getLeft(), bounds.getTop(), bounds.getWidth(), 25);
    
    fill(200);
    textAlign(LEFT, CENTER);
    textSize(12);
    text(title, bounds.getLeft() + 10, bounds.getTop() + 13);
  }
  
  protected boolean isInBounds(int x, int y) {
    return x >= bounds.getLeft() && x < bounds.getRight() &&
           y >= bounds.getTop() && y < bounds.getBottom();
  }
}

// ==================== STATUS PANEL ====================

class StatusPanel extends UIPanel {
  StatusPanel(Rectangle bounds) {
    super(bounds);
    this.title = "Status";
  }
  
  void display() {
    drawPanelHeader(title);
    
    fill(60);
    rect(bounds.getLeft(), bounds.getTop() + 25, bounds.getWidth(), bounds.getHeight() - 25);
    
    fill(200);
    textSize(11);
    textAlign(LEFT, TOP);
    
    String machineStatus = "Machine: OK";
    String penStatus = "Pen: UP";
    
    text(machineStatus, bounds.getLeft() + 10, bounds.getTop() + 35);
    text(penStatus, bounds.getLeft() + 200, bounds.getTop() + 35);
  }
  
  void handleMousePress(int x, int y) {
    // No interactive elements yet
  }
}

// ==================== SERIAL PANEL ====================

class SerialPanel extends UIPanel {
  private SimpleButton connectBtn;
  private SimpleButton disconnectBtn;
  
  SerialPanel(Rectangle bounds) {
    super(bounds);
    this.title = "Serial Connection";
    
    int btnY = bounds.getTop() + 35;
    connectBtn = new SimpleButton(new Rectangle(bounds.getLeft() + 10, btnY, 100, 25), "Connect");
    disconnectBtn = new SimpleButton(new Rectangle(bounds.getLeft() + 120, btnY, 100, 25), "Disconnect");
  }
  
  void display() {
    drawPanelHeader(title);
    
    fill(60);
    rect(bounds.getLeft(), bounds.getTop() + 25, bounds.getWidth(), bounds.getHeight() - 25);
    
    fill(200);
    textSize(10);
    textAlign(LEFT, TOP);
    
    String portInfo = "Port: ";
    if (serialComm.isConnected()) {
      portInfo += serialComm.getPortName() + " (CONNECTED)";
    } else {
      portInfo += "Not connected";
    }
    
    text(portInfo, bounds.getLeft() + 10, bounds.getTop() + 35);
    
    // Draw buttons
    connectBtn.display();
    disconnectBtn.display();
  }
  
  void handleMousePress(int x, int y) {
    if (connectBtn.isInBounds(x, y)) {
      String[] ports = serialComm.getAvailablePorts();
      if (ports.length > 0) {
        serialComm.connect(ports[0]);
      }
    }
    if (disconnectBtn.isInBounds(x, y)) {
      serialComm.disconnect();
    }
  }
}

// ==================== QUEUE PANEL ====================

class QueuePanel extends UIPanel {
  private SimpleButton clearBtn;
  private SimpleButton exportBtn;
  
  QueuePanel(Rectangle bounds) {
    super(bounds);
    this.title = "Command Queue";
    
    int btnY = bounds.getTop() + 35;
    clearBtn = new SimpleButton(new Rectangle(bounds.getLeft() + 10, btnY, 80, 25), "Clear");
    exportBtn = new SimpleButton(new Rectangle(bounds.getLeft() + 100, btnY, 80, 25), "Export");
  }
  
  void display() {
    drawPanelHeader(title);
    
    fill(60);
    rect(bounds.getLeft(), bounds.getTop() + 25, bounds.getWidth(), bounds.getHeight() - 25);
    
    fill(200);
    textSize(11);
    textAlign(LEFT, TOP);
    
    int queueSize = commandQueue.size();
    int remaining = commandQueue.remaining();
    
    text("Total commands: " + queueSize, bounds.getLeft() + 10, bounds.getTop() + 35);
    text("Remaining: " + remaining, bounds.getLeft() + 10, bounds.getTop() + 50);
    text("Status: " + (commandQueue.isRunning() ? "RUNNING" : "IDLE"), 
         bounds.getLeft() + 10, bounds.getTop() + 65);
    
    // Draw buttons
    clearBtn.display();
    exportBtn.display();
  }
  
  void handleMousePress(int x, int y) {
    if (clearBtn.isInBounds(x, y)) {
      commandQueue.clear();
      println("Queue cleared");
    }
    if (exportBtn.isInBounds(x, y)) {
      println("Export queue feature not yet implemented");
    }
  }
}

// ==================== CONTROLS PANEL ====================

class ControlsPanel extends UIPanel {
  private SimpleButton penUpBtn;
  private SimpleButton penDownBtn;
  private SimpleButton homeBtn;
  private SimpleButton startBtn;
  private SimpleButton pauseBtn;
  
  ControlsPanel(Rectangle bounds) {
    super(bounds);
    this.title = "Controls";
    
    int row1 = bounds.getTop() + 35;
    int row2 = bounds.getTop() + 65;
    penUpBtn = new SimpleButton(new Rectangle(bounds.getLeft() + 10, row1, 70, 25), "Pen Up");
    penDownBtn = new SimpleButton(new Rectangle(bounds.getLeft() + 90, row1, 70, 25), "Pen Down");
    homeBtn = new SimpleButton(new Rectangle(bounds.getLeft() + 170, row1, 70, 25), "Home");
    
    startBtn = new SimpleButton(new Rectangle(bounds.getLeft() + 10, row2, 70, 25), "Start");
    pauseBtn = new SimpleButton(new Rectangle(bounds.getLeft() + 90, row2, 70, 25), "Pause");
  }
  
  void display() {
    drawPanelHeader(title);
    
    fill(60);
    rect(bounds.getLeft(), bounds.getTop() + 25, bounds.getWidth(), bounds.getHeight() - 25);
    
    penUpBtn.display();
    penDownBtn.display();
    homeBtn.display();
    startBtn.display();
    pauseBtn.display();
  }
  
  void handleMousePress(int x, int y) {
    if (penUpBtn.isInBounds(x, y)) {
      commandQueue.addPenUp();
      println("Pen Up command queued");
    }
    if (penDownBtn.isInBounds(x, y)) {
      commandQueue.addPenDown();
      println("Pen Down command queued");
    }
    if (homeBtn.isInBounds(x, y)) {
      PVector homeMotors = displayMachine.cartesianToNative(
        displayMachine.getHomePoint().x, 
        displayMachine.getHomePoint().y
      );
      commandQueue.addMoveCommand(homeMotors.x, homeMotors.y);
      println("Move to home queued");
    }
    if (startBtn.isInBounds(x, y)) {
      commandQueue.start();
      println("Queue started");
    }
    if (pauseBtn.isInBounds(x, y)) {
      commandQueue.stop();
      println("Queue paused");
    }
  }
}

// ==================== SIMPLE BUTTON ====================

class SimpleButton {
  private Rectangle bounds;
  private String label;
  private boolean hovered = false;
  
  SimpleButton(Rectangle bounds, String label) {
    this.bounds = bounds;
    this.label = label;
  }
  
  void display() {
    // Check if mouse is over button
    hovered = (mouseX >= bounds.getLeft() && mouseX < bounds.getRight() &&
               mouseY >= bounds.getTop() && mouseY < bounds.getBottom());
    
    // Draw button
    fill(hovered ? 120 : 80);
    stroke(150);
    strokeWeight(1);
    rect(bounds.getLeft(), bounds.getTop(), bounds.getWidth(), bounds.getHeight());
    
    // Draw label
    fill(255);
    textSize(10);
    textAlign(CENTER, CENTER);
    text(label, bounds.getCenterX(), bounds.getCenterY());
  }
  
  boolean isInBounds(int x, int y) {
    return x >= bounds.getLeft() && x < bounds.getRight() &&
           y >= bounds.getTop() && y < bounds.getBottom();
  }
}

// ==================== HELPER RECTANGLE CLASS ====================

class Rectangle {
  private float x, y, w, h;
  
  Rectangle(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  float getLeft() { return x; }
  float getTop() { return y; }
  float getRight() { return x + w; }
  float getBottom() { return y + h; }
  float getWidth() { return w; }
  float getHeight() { return h; }
  float getCenterX() { return x + w/2; }
  float getCenterY() { return y + h/2; }
}
