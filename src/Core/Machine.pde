/**
 * Machine.pde
 * 
 * Represents the physical polargraph machine with its specifications
 * Handles coordinate conversions, calculations, and machine state
 */

class Machine {
  
  // Machine specifications
  private int width;           // Machine width in steps
  private int height;          // Machine height in steps
  private float stepsPerRev;   // Motor steps per revolution
  private float mmPerRev;      // mm per motor revolution
  
  // Calculated values
  private float mmPerStep;     // Derived from stepsPerRev and mmPerRev
  private float stepsPerMM;    // Derived
  private float maxLength;     // Diagonal of machine workspace
  
  // Drawing parameters
  private float gridSize = 100.0;
  private PVector homePoint = new PVector(1395, 1395);
  private float penWidth = 0.3;
  private int penUpPosition = 15;
  private int penDownPosition = 88;
  
  // UI display parameters
  private Rectangle machineOutline;
  private float displayScale = 0.3;
  private PVector displayOffset = new PVector(50, 50);
  
  // Current state
  private PVector currentPosition = new PVector(0, 0);
  private boolean penIsUp = true;
  
  /**
   * Constructor
   */
  Machine(int w, int h, float stepsPerRev, float mmPerRev) {
    this.width = w;
    this.height = h;
    this.stepsPerRev = stepsPerRev;
    this.mmPerRev = mmPerRev;
    
    // Calculate derived values
    this.mmPerStep = mmPerRev / stepsPerRev;
    this.stepsPerMM = stepsPerRev / mmPerRev;
    this.maxLength = dist(0, 0, w, h);
    
    println("Machine initialized: " + w + "x" + h + " steps");
    println("  Steps/Rev: " + stepsPerRev + ", MM/Rev: " + mmPerRev);
    println("  MM/Step: " + mmPerStep);
  }
  
  // ===== GETTERS =====
  
  int getWidth() { return width; }
  int getHeight() { return height; }
  float getMMPerStep() { return mmPerStep; }
  float getStepsPerMM() { return stepsPerMM; }
  float getMaxLength() { return maxLength; }
  PVector getHomePoint() { return homePoint; }
  float getPenWidth() { return penWidth; }
  
  // ===== SETTERS =====
  
  void setHomePoint(float x, float y) {
    homePoint.x = x;
    homePoint.y = y;
  }
  
  void setPenWidth(float w) {
    penWidth = w;
  }
  
  void setPenLiftPositions(int up, int down) {
    penUpPosition = up;
    penDownPosition = down;
  }
  
  void setGridSize(float g) {
    gridSize = g;
  }
  
  // ===== COORDINATE CONVERSIONS =====
  
  /**
   * Convert display coordinates to machine steps
   */
  PVector displayToMachineSteps(PVector displayCoords) {
    float x = (displayCoords.x - displayOffset.x) / displayScale;
    float y = (displayCoords.y - displayOffset.y) / displayScale;
    return new PVector(x, y);
  }
  
  /**
   * Convert machine steps to display coordinates
   */
  PVector machineStepsToDisplay(PVector machineCoords) {
    float x = machineCoords.x * displayScale + displayOffset.x;
    float y = machineCoords.y * displayScale + displayOffset.y;
    return new PVector(x, y);
  }
  
  /**
   * Convert cartesian coordinates to polar (motor A/B lengths)
   */
  PVector cartesianToNative(float x, float y) {
    float distA = dist(0, 0, x, y);
    float distB = dist(width, 0, x, y);
    return new PVector(distA, distB);
  }
  
  /**
   * Convert polar coordinates (motor lengths) to cartesian
   */
  PVector nativeToCartesian(float motorA, float motorB) {
    float x = (pow(width, 2) - pow(motorB, 2) + pow(motorA, 2)) / (width * 2);
    float y = sqrt(pow(motorA, 2) - pow(x, 2));
    return new PVector(x, y);
  }
  
  // ===== DISPLAY =====
  
  void display() {
    // Draw machine outline
    fill(50);
    stroke(150);
    strokeWeight(2);
    float displayWidth = width * displayScale;
    float displayHeight = height * displayScale;
    rect(displayOffset.x, displayOffset.y, displayWidth, displayHeight);
    
    // Draw home point
    fill(100, 200, 100);
    PVector homeDisplay = machineStepsToDisplay(homePoint);
    ellipse(homeDisplay.x, homeDisplay.y, 10, 10);
    
    // Draw current position
    fill(200, 100, 100);
    PVector currentDisplay = machineStepsToDisplay(currentPosition);
    ellipse(currentDisplay.x, currentDisplay.y, 8, 8);
    
    // Draw grid
    drawGrid();
  }
  
  private void drawGrid() {
    if (gridSize <= 0) return;
    
    stroke(80);
    strokeWeight(1);
    float gridDisplay = gridSize * displayScale;
    
    float displayWidth = width * displayScale;
    float displayHeight = height * displayScale;
    
    // Vertical lines
    for (float x = 0; x < displayWidth; x += gridDisplay) {
      line(displayOffset.x + x, displayOffset.y, 
           displayOffset.x + x, displayOffset.y + displayHeight);
    }
    
    // Horizontal lines
    for (float y = 0; y < displayHeight; y += gridDisplay) {
      line(displayOffset.x, displayOffset.y + y, 
           displayOffset.x + displayWidth, displayOffset.y + y);
    }
  }
  
  // ===== STATE =====
  
  void setCurrentPosition(float x, float y) {
    currentPosition.x = x;
    currentPosition.y = y;
  }
  
  void setPenUp(boolean up) {
    penIsUp = up;
  }
  
  boolean isPenUp() {
    return penIsUp;
  }
}
