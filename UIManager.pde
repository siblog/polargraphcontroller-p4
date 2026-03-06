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
    
    // Machine Response Panel
    panels.add(new ResponsePanel(new Rectangle(710, 260, 430, 100)));
    
    // Motor Control Panel
    panels.add(new MotorPanel(new Rectangle(710, 370, 430, 120)));
    
    // Command Queue Panel
    panels.add(new QueuePanel(new Rectangle(710, 500, 430, 140)));
    
    // Controls Panel
    panels.add(new ControlsPanel(new Rectangle(710, 650, 430, 150)));
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
  
  void handleMouseDrag(int x, int y) {
    for (UIPanel panel : panels) {
      panel.handleMouseDrag(x, y);
    }
  }
  
  void handleMouseRelease(int x, int y) {
    for (UIPanel panel : panels) {
      panel.handleMouseRelease(x, y);
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
  abstract void handleMouseDrag(int x, int y);
  abstract void handleMouseRelease(int x, int y);
  
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
  private SimpleButton saveBtn;
  
  StatusPanel(Rectangle bounds) {
    super(bounds);
    this.title = "Status";
    
    float btnY = bounds.getTop() + 65;
    saveBtn = new SimpleButton(new Rectangle(bounds.getLeft() + 10, btnY, 60, 20), "Save");
  }
  
  void display() {
    drawPanelHeader(title);
    
    fill(60);
    rect(bounds.getLeft(), bounds.getTop() + 25, bounds.getWidth(), bounds.getHeight() - 25);
    
    fill(200);
    textSize(11);
    textAlign(LEFT, TOP);
    
    String machineStatus = serialComm.isConnected() ? "Machine: CONNECTED" : "Machine: DISCONNECTED";
    String penStatus = displayMachine.isPenUp() ? "Pen: UP" : "Pen: DOWN";
    
    text(machineStatus, bounds.getLeft() + 10, bounds.getTop() + 35);
    text(penStatus, bounds.getLeft() + 200, bounds.getTop() + 35);
    
    // queue info
    text("Queue size: " + commandQueue.size(), bounds.getLeft() + 10, bounds.getTop() + 55);
    text("Remaining: " + commandQueue.remaining(), bounds.getLeft() + 200, bounds.getTop() + 55);
    
    // Draw save button
    saveBtn.display();
  }
  
  void handleMousePress(int x, int y) {
    if (saveBtn.isInBounds(x, y)) {
      cfg.save();
    }
  }
  
  void handleMouseDrag(int x, int y) {
    // No draggable elements
  }
  
  void handleMouseRelease(int x, int y) {
    // No draggable elements
  }
}

// ==================== SERIAL PANEL ====================

class SerialPanel extends UIPanel {
  private SimpleButton connectBtn;
  private SimpleButton disconnectBtn;
  private SimpleDropdown portDropdown;
  private SimpleButton refreshBtn;
  private boolean dropdownExpanded = false;
  
  SerialPanel(Rectangle bounds) {
    super(bounds);
    this.title = "Serial Connection";
    
    float row1 = bounds.getTop() + 35;
    float row2 = bounds.getTop() + 65;
    
    // Port selection dropdown
    portDropdown = new SimpleDropdown(new Rectangle(bounds.getLeft() + 10, row1, 200, 25));
    refreshBtn = new SimpleButton(new Rectangle(bounds.getLeft() + 220, row1, 70, 25), "Refresh");
    
    // Connection buttons
    connectBtn = new SimpleButton(new Rectangle(bounds.getLeft() + 10, row2, 100, 25), "Connect");
    disconnectBtn = new SimpleButton(new Rectangle(bounds.getLeft() + 120, row2, 100, 25), "Disconnect");
    
    // Initialize port list
    refreshPorts();
  }
  
  void display() {
    drawPanelHeader(title);
    
    fill(60);
    rect(bounds.getLeft(), bounds.getTop() + 25, bounds.getWidth(), bounds.getHeight() - 25);
    
    fill(200);
    textSize(10);
    textAlign(LEFT, TOP);
    
    String statusInfo = "Status: ";
    if (serialComm.isConnected()) {
      statusInfo += "CONNECTED to " + serialComm.getPortName();
    } else {
      statusInfo += "Not connected";
    }
    
    text(statusInfo, bounds.getLeft() + 10, bounds.getTop() + 35);
    
    // Draw dropdown and buttons
    portDropdown.display();
    refreshBtn.display();
    connectBtn.display();
    disconnectBtn.display();
  }
  
  void handleMousePress(int x, int y) {
    // Handle dropdown first
    if (portDropdown.isInBounds(x, y)) {
      portDropdown.toggle();
      return;
    }
    
    // Handle dropdown options if expanded
    if (portDropdown.isExpanded()) {
      int selectedIndex = portDropdown.getSelectedOption(x, y);
      if (selectedIndex >= 0) {
        portDropdown.selectOption(selectedIndex);
        portDropdown.collapse();
        return;
      }
    }
    
    // Handle other buttons
    if (refreshBtn.isInBounds(x, y)) {
      refreshPorts();
    }
    if (connectBtn.isInBounds(x, y)) {
      String selectedPort = portDropdown.getSelectedValue();
      if (selectedPort != null && !selectedPort.isEmpty()) {
        serialComm.connect(selectedPort);
      }
    }
    if (disconnectBtn.isInBounds(x, y)) {
      serialComm.disconnect();
    }
  }
  
  void handleMouseDrag(int x, int y) {
    // No draggable elements
  }
  
  void handleMouseRelease(int x, int y) {
    // No draggable elements
  }
  
  private void refreshPorts() {
    String[] ports = serialComm.getAvailablePorts();
    portDropdown.setOptions(ports);
    if (ports.length > 0 && portDropdown.getSelectedValue() == null) {
      portDropdown.selectOption(0); // Select first port by default
    }
  }
}

// ==================== MACHINE RESPONSE PANEL ====================

class ResponsePanel extends UIPanel {
  private SimpleButton clearBtn;
  
  ResponsePanel(Rectangle bounds) {
    super(bounds);
    this.title = "Machine Response";
    
    float btnY = bounds.getTop() + 35;
    clearBtn = new SimpleButton(new Rectangle(bounds.getLeft() + 350, btnY, 70, 20), "Clear");
  }
  
  void display() {
    drawPanelHeader(title);
    
    fill(60);
    rect(bounds.getLeft(), bounds.getTop() + 25, bounds.getWidth(), bounds.getHeight() - 25);
    
    // Display recent machine responses
    ArrayList<String> responses = serialComm.getResponseMessages();
    
    fill(200);
    textSize(9);
    textAlign(LEFT, TOP);
    
    float textY = bounds.getTop() + 35;
    float lineHeight = 12;
    
    if (responses.size() == 0) {
      fill(120);
      text("(No responses)", bounds.getLeft() + 10, textY);
    } else {
      for (String response : responses) {
        // Truncate long messages
        String displayText = response;
        if (displayText.length() > 50) {
          displayText = displayText.substring(0, 50) + "...";
        }
        
        fill(200);
        text(displayText, bounds.getLeft() + 10, textY);
        textY += lineHeight;
      }
    }
    
    // Draw clear button
    clearBtn.display();
  }
  
  void handleMousePress(int x, int y) {
    if (clearBtn.isInBounds(x, y)) {
      serialComm.clearResponseMessages();
    }
  }
  
  void handleMouseDrag(int x, int y) {
    // No draggable elements
  }
  
  void handleMouseRelease(int x, int y) {
    // No draggable elements
  }
}

// ==================== MOTOR CONTROL PANEL ====================

class MotorPanel extends UIPanel {
  private SimpleSlider motorASlider;
  private SimpleSlider motorBSlider;
  private SimpleButton sendBtn;
  private SimpleButton homeBtn;
  
  MotorPanel(Rectangle bounds) {
    super(bounds);
    this.title = "Motor Control";
    
    float sliderY = bounds.getTop() + 35;
    float btnY = bounds.getTop() + 75;
    
    // Motor position sliders (0 to machine max)
    motorASlider = new SimpleSlider(new Rectangle(bounds.getLeft() + 10, sliderY, 180, 20), 
                                   0, cfg.machineWidth, 0);
    motorBSlider = new SimpleSlider(new Rectangle(bounds.getLeft() + 220, sliderY, 180, 20), 
                                   0, cfg.machineHeight, 0);
    
    // Control buttons
    sendBtn = new SimpleButton(new Rectangle(bounds.getLeft() + 10, btnY, 80, 25), "Send Pos");
    homeBtn = new SimpleButton(new Rectangle(bounds.getLeft() + 100, btnY, 80, 25), "Go Home");
  }
  
  void display() {
    drawPanelHeader(title);
    
    fill(60);
    rect(bounds.getLeft(), bounds.getTop() + 25, bounds.getWidth(), bounds.getHeight() - 25);
    
    fill(200);
    textSize(10);
    textAlign(LEFT, TOP);
    
    // Labels
    text("Motor A: " + (int)motorASlider.getValue(), bounds.getLeft() + 10, bounds.getTop() + 30);
    text("Motor B: " + (int)motorBSlider.getValue(), bounds.getLeft() + 220, bounds.getTop() + 30);
    
    // Draw sliders and buttons
    motorASlider.display();
    motorBSlider.display();
    sendBtn.display();
    homeBtn.display();
  }
  
  void handleMousePress(int x, int y) {
    motorASlider.handleMousePress(x, y);
    motorBSlider.handleMousePress(x, y);
    
    if (sendBtn.isInBounds(x, y)) {
      float motorA = motorASlider.getValue();
      float motorB = motorBSlider.getValue();
      commandQueue.addMoveCommand(motorA, motorB);
      println("Motor position queued: A=" + (int)motorA + ", B=" + (int)motorB);
    }
    if (homeBtn.isInBounds(x, y)) {
      motorASlider.setValue(cfg.homeX);
      motorBSlider.setValue(cfg.homeY);
      commandQueue.add("C09," + cfg.homeX + "," + cfg.homeY + ",END");
      println("Home position queued: " + cfg.homeX + "," + cfg.homeY);
    }
  }
  
  void handleMouseDrag(int x, int y) {
    motorASlider.handleMouseDrag(x, y);
    motorBSlider.handleMouseDrag(x, y);
  }
  
  void handleMouseRelease(int x, int y) {
    motorASlider.handleMouseRelease();
    motorBSlider.handleMouseRelease();
  }
}

// ==================== QUEUE PANEL ====================

class QueuePanel extends UIPanel {
  private SimpleButton clearBtn;
  private SimpleButton exportBtn;
  
  QueuePanel(Rectangle bounds) {
    super(bounds);
    this.title = "Command Queue";
    
    float btnY = bounds.getTop() + 35;
    clearBtn = new SimpleButton(new Rectangle(bounds.getLeft() + 10, btnY, 80, 25), "Clear");
    exportBtn = new SimpleButton(new Rectangle(bounds.getLeft() + 100, btnY, 80, 25), "Export");
  }
  
  void display() {
    drawPanelHeader(title);
    
    fill(60);
    rect(bounds.getLeft(), bounds.getTop() + 25, bounds.getWidth(), bounds.getHeight() - 25);
    
    fill(200);
    textSize(10);
    textAlign(LEFT, TOP);
    
    float textY = bounds.getTop() + 35;
    float lineHeight = 14;
    
    // Show current command (being executed)
    String currentCmd = commandQueue.getCurrentCommand();
    if (currentCmd != null) {
      fill(255, 255, 0); // Yellow for current command
      rect(bounds.getLeft() + 5, textY - 2, bounds.getWidth() - 10, lineHeight);
      fill(0);
      text("▶ " + currentCmd, bounds.getLeft() + 10, textY);
      textY += lineHeight + 2;
    }
    
    // Show queued commands
    String[] allCommands = commandQueue.getAllCommands();
    int startIndex = commandQueue.remaining() > 0 ? allCommands.length - commandQueue.remaining() : 0;
    
    for (int i = startIndex; i < allCommands.length && i < startIndex + 8; i++) { // Show max 8 queued commands
      fill(200);
      String displayCmd = allCommands[i];
      if (displayCmd.length() > 35) {
        displayCmd = displayCmd.substring(0, 32) + "...";
      }
      text(displayCmd, bounds.getLeft() + 10, textY);
      textY += lineHeight;
    }
    
    // Show queue status at bottom
    fill(150);
    textSize(9);
    text("Status: " + (commandQueue.isRunning() ? "RUNNING" : "IDLE"), 
         bounds.getLeft() + 10, bounds.getBottom() - 25);
    text("Total: " + commandQueue.size() + " | Remaining: " + commandQueue.remaining(), 
         bounds.getLeft() + 10, bounds.getBottom() - 10);
    
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
  
  void handleMouseDrag(int x, int y) {
    // No draggable elements
  }
  
  void handleMouseRelease(int x, int y) {
    // No draggable elements
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
    
    float row1 = bounds.getTop() + 35;
    float row2 = bounds.getTop() + 65;
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
      commandQueue.addPenUp(cfg.penUpPosition);
      displayMachine.setPenUp(true);
      println("Pen Up command queued ("+cfg.penUpPosition+")");
    }
    if (penDownBtn.isInBounds(x, y)) {
      commandQueue.addPenDown(cfg.penDownPosition);
      displayMachine.setPenUp(false);
      println("Pen Down command queued ("+cfg.penDownPosition+")");
    }
    if (homeBtn.isInBounds(x, y)) {
      // queue absolute home using configured steps
      commandQueue.add("C09," + cfg.homeX + "," + cfg.homeY + ",END");
      println("Move to home queued ("+cfg.homeX+","+cfg.homeY+")");
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
  
  void handleMouseDrag(int x, int y) {
    // No draggable elements
  }
  
  void handleMouseRelease(int x, int y) {
    // No draggable elements
  }
}

// ==================== SIMPLE DROPDOWN ====================

class SimpleDropdown {
  private Rectangle bounds;
  private String[] options;
  private int selectedIndex = -1;
  private boolean expanded = false;
  private int maxVisibleOptions = 5;
  
  SimpleDropdown(Rectangle bounds) {
    this.bounds = bounds;
    this.options = new String[0];
  }
  
  void setOptions(String[] options) {
    this.options = options;
    if (selectedIndex >= options.length) {
      selectedIndex = -1;
    }
  }
  
  void selectOption(int index) {
    if (index >= 0 && index < options.length) {
      selectedIndex = index;
    }
  }
  
  String getSelectedValue() {
    if (selectedIndex >= 0 && selectedIndex < options.length) {
      return options[selectedIndex];
    }
    return null;
  }
  
  void toggle() {
    expanded = !expanded;
  }
  
  void collapse() {
    expanded = false;
  }
  
  boolean isExpanded() {
    return expanded;
  }
  
  boolean isInBounds(int x, int y) {
    if (expanded) {
      // Include dropdown area
      float dropdownHeight = min(options.length, maxVisibleOptions) * bounds.getHeight();
      return x >= bounds.getLeft() && x < bounds.getRight() &&
             y >= bounds.getTop() && y < bounds.getBottom() + dropdownHeight;
    } else {
      return x >= bounds.getLeft() && x < bounds.getRight() &&
             y >= bounds.getTop() && y < bounds.getBottom();
    }
  }
  
  int getSelectedOption(int x, int y) {
    if (!expanded) return -1;
    
    for (int i = 0; i < min(options.length, maxVisibleOptions); i++) {
      float optionY = bounds.getBottom() + (i * bounds.getHeight());
      if (y >= optionY && y < optionY + bounds.getHeight()) {
        return i;
      }
    }
    return -1;
  }
  
  void display() {
    // Draw main dropdown button
    fill(selectedIndex >= 0 ? 100 : 80);
    stroke(150);
    strokeWeight(1);
    rect(bounds.getLeft(), bounds.getTop(), bounds.getWidth(), bounds.getHeight());
    
    // Draw selected text or placeholder
    fill(255);
    textSize(10);
    textAlign(LEFT, CENTER);
    String displayText = selectedIndex >= 0 ? options[selectedIndex] : "Select port...";
    text(displayText, bounds.getLeft() + 8, bounds.getCenterY());
    
    // Draw dropdown arrow
    fill(200);
    triangle(bounds.getRight() - 15, bounds.getCenterY() - 3,
             bounds.getRight() - 5, bounds.getCenterY() - 3,
             bounds.getRight() - 10, bounds.getCenterY() + 3);
    
    // Draw expanded options
    if (expanded && options.length > 0) {
      int visibleOptions = min(options.length, maxVisibleOptions);
      
      // Draw dropdown background
      fill(80);
      stroke(150);
      rect(bounds.getLeft(), bounds.getBottom(), bounds.getWidth(), visibleOptions * bounds.getHeight());
      
      // Draw each option
      for (int i = 0; i < visibleOptions; i++) {
        float optionY = bounds.getBottom() + (i * bounds.getHeight());
        
        // Highlight on hover
        boolean hovered = mouseX >= bounds.getLeft() && mouseX < bounds.getRight() &&
                         mouseY >= optionY && mouseY < optionY + bounds.getHeight();
        fill(hovered ? 120 : 80);
        rect(bounds.getLeft(), optionY, bounds.getWidth(), bounds.getHeight());
        
        // Draw option text
        fill(255);
        textAlign(LEFT, CENTER);
        text(options[i], bounds.getLeft() + 8, optionY + bounds.getHeight()/2);
      }
    }
  }
}

// ==================== SIMPLE SLIDER ====================

class SimpleSlider {
  private Rectangle bounds;
  private float minValue, maxValue, currentValue;
  private boolean dragging = false;
  
  SimpleSlider(Rectangle bounds, float minValue, float maxValue, float initialValue) {
    this.bounds = bounds;
    this.minValue = minValue;
    this.maxValue = maxValue;
    this.currentValue = constrain(initialValue, minValue, maxValue);
  }
  
  void setValue(float value) {
    currentValue = constrain(value, minValue, maxValue);
  }
  
  float getValue() {
    return currentValue;
  }
  
  void handleMousePress(int x, int y) {
    if (isInBounds(x, y)) {
      dragging = true;
      updateValueFromMouse(x);
    }
  }
  
  void handleMouseDrag(int x, int y) {
    if (dragging) {
      updateValueFromMouse(x);
    }
  }
  
  void handleMouseRelease() {
    dragging = false;
  }
  
  private void updateValueFromMouse(int x) {
    float relativeX = constrain(x - bounds.getLeft(), 0, bounds.getWidth());
    float ratio = relativeX / bounds.getWidth();
    currentValue = minValue + (maxValue - minValue) * ratio;
  }
  
  boolean isInBounds(int x, int y) {
    return x >= bounds.getLeft() && x < bounds.getRight() &&
           y >= bounds.getTop() && y < bounds.getBottom();
  }
  
  void display() {
    // Draw slider track
    fill(100);
    rect(bounds.getLeft(), bounds.getTop() + bounds.getHeight()/2 - 2, 
         bounds.getWidth(), 4);
    
    // Draw slider handle
    float handleX = bounds.getLeft() + (currentValue - minValue) / (maxValue - minValue) * bounds.getWidth();
    fill(dragging ? 150 : 120);
    ellipse(handleX, bounds.getCenterY(), 12, 12);
    
    // Draw value text
    fill(200);
    textSize(8);
    textAlign(CENTER, BOTTOM);
    text(nf(currentValue, 0, 0), handleX, bounds.getTop() - 2);
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
