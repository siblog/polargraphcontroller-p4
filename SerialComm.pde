/**
 * SerialComm.pde
 * 
 * Handles serial communication with the polargraph machine
 */

class SerialComm {
  private Serial serialPort;
  private ArrayList<String> receivedMessages;
  private ArrayList<String> responseMessages;  // Non-READY messages for UI display
  private String currentMessage = "";
  private boolean isConnected = false;
  private boolean machineReady = false;  // Set to true when READY_100 received
  
  // Serial communication parameters
  private int baudRate = 57600;
  private String comPort = null;
  
  // Response parsing
  private static final String READY_SIGNAL = "READY_100";
  private static final int MAX_RESPONSE_DISPLAY = 5;  // Keep last 5 messages for UI
  
  SerialComm() {
    receivedMessages = new ArrayList<String>();
    responseMessages = new ArrayList<String>();
  }
  
  /**
   * Connect to machine via serial port
   */
  boolean connect(String portName) {
    try {
      serialPort = new Serial(Polargraphcontroller_P4.this, portName, baudRate);
      serialPort.bufferUntil('\n');
      comPort = portName;
      isConnected = true;
      println("Connected to " + portName + " at " + baudRate + " baud");
      return true;
    } catch (Exception e) {
      println("Failed to connect to " + portName + ": " + e.getMessage());
      isConnected = false;
      return false;
    }
  }
  
  /**
   * Disconnect from machine
   */
  void disconnect() {
    if (serialPort != null) {
      serialPort.stop();
      isConnected = false;
      println("Disconnected from serial port");
    }
  }
  
  /**
   * Send command to machine
   */
  boolean sendCommand(String command) {
    if (!isConnected || serialPort == null) {
      println("ERROR: Not connected to machine");
      return false;
    }
    
    // Ensure command ends with newline
    if (!command.endsWith("\n")) {
      command += "\n";
    }
    
    serialPort.write(command);
    println(">> " + command.trim());
    return true;
  }
  
  /**
   * Handle incoming serial data (called by Processing)
   */
  void serialEvent(Serial p) {
    String inString = p.readStringUntil('\n');
    if (inString != null) {
      inString = inString.trim();
      if (!inString.isEmpty()) {
        receivedMessages.add(inString);
        println("<< " + inString);
        
        // Check if machine is signaling it's ready for next command
        if (inString.contains(READY_SIGNAL)) {
          machineReady = true;
        } else {
          // Store descriptive responses for UI display
          addResponseMessage(inString);
        }
      }
    }
  }
  
  /**
   * Add response message to display queue (max 5 recent)
   */
  private void addResponseMessage(String msg) {
    responseMessages.add(0, msg);  // Add to front
    if (responseMessages.size() > MAX_RESPONSE_DISPLAY) {
      responseMessages.remove(responseMessages.size() - 1);  // Remove oldest
    }
  }
  
  /**
   * Get recent response messages for UI display
   */
  ArrayList<String> getResponseMessages() {
    return new ArrayList<String>(responseMessages);
  }
  
  /**
   * Clear response display messages
   */
  void clearResponseMessages() {
    responseMessages.clear();
  }
  
  /**
   * Get list of available serial ports
   */
  String[] getAvailablePorts() {
    return Serial.list();
  }
  
  /**
   * Get number of available ports
   */
  int getPortCount() {
    return Serial.list().length;
  }
  
  /**
   * Check if connected
   */
  boolean isConnected() {
    return isConnected;
  }
  
  /**
   * Get current port name
   */
  String getPortName() {
    return comPort;
  }
  
  /**
   * Get last received message
   */
  String getLastMessage() {
    if (receivedMessages.size() > 0) {
      return receivedMessages.get(receivedMessages.size() - 1);
    }
    return null;
  }
  
  /**
   * Get all received messages
   */
  ArrayList<String> getMessages() {
    return new ArrayList<String>(receivedMessages);
  }
  
  /**
   * Clear message buffer
   */
  void clearMessages() {
    receivedMessages.clear();
  }
  
  /**
   * Extract position from response message
   * Expected format: PGMOVE,motorA,motorB
   */
  PVector parsePositionResponse(String message) {
    try {
      String[] parts = message.split(",");
      if (parts.length >= 3) {
        float motorA = Float.parseFloat(parts[1]);
        float motorB = Float.parseFloat(parts[2]);
        return new PVector(motorA, motorB);
      }
    } catch (Exception e) {
      println("Failed to parse position: " + e.getMessage());
    }
    return null;
  }
  
  /**
   * Check if machine ready signal received, and consume the flag
   */
  boolean isMachineReady() {
    if (machineReady) {
      machineReady = false;  // Consume the signal
      return true;
    }
    return false;
  }
  
  /**
   * Test connection by sending PING
   */
  boolean testConnection() {
    if (!isConnected) {
      println("Not connected");
      return false;
    }
    
    sendCommand("C26,END\n"); // REQUEST_MACHINE_SIZE
    delay(100);
    return getLastMessage() != null;
  }
}
