/**
 * CommandQueue.pde
 * 
 * Manages the queue of ASCII commands to be sent to the machine
 */

class CommandQueue {
  private ArrayList<String> queue;
  private int currentIndex = 0;
  private boolean isRunning = false;
  
  // Command constants
  private static final String CMD_CHANGELENGTH = "C01,";
  private static final String CMD_PENUP = "C14,";
  private static final String CMD_PENDOWN = "C13,";
  private static final String CMD_SETPOSITION = "C09,";
  
  CommandQueue() {
    queue = new ArrayList<String>();
  }
  
  /**
   * Add a command to the queue
   */
  void add(String command) {
    if (!command.endsWith("END")) {
      command += "END";
    }
    queue.add(command);
  }
  
  /**
   * Add a move command to queue
   */
  void addMoveCommand(float motorA, float motorB) {
    String command = CMD_CHANGELENGTH + (int)motorA + "," + (int)motorB + ",END";
    queue.add(command);
  }
  
  /**
   * Add pen up command (with position value)
   */
  void addPenUp(float pos) {
    queue.add(CMD_PENUP + pos + ",END");
  }
  
  /**
   * Add pen down command (with position value)
   */
  void addPenDown(float pos) {
    queue.add(CMD_PENDOWN + pos + ",END");
  }
  
  /**
   * Get command at index
   */
  String get(int index) {
    if (index >= 0 && index < queue.size()) {
      return queue.get(index);
    }
    return null;
  }
  
  /**
   * Get next command without removing it
   */
  String peek() {
    if (currentIndex < queue.size()) {
      return queue.get(currentIndex);
    }
    return null;
  }
  
  /**
   * Get and remove next command
   */
  String pop() {
    if (currentIndex < queue.size()) {
      return queue.get(currentIndex++);
    }
    return null;
  }
  
  /**
   * Remove command at index
   */
  void remove(int index) {
    if (index >= 0 && index < queue.size()) {
      queue.remove(index);
      if (currentIndex > index) {
        currentIndex--;
      }
    }
  }
  
  /**
   * Clear entire queue
   */
  void clear() {
    queue.clear();
    currentIndex = 0;
    isRunning = false;
  }
  
  /**
   * Get queue size
   */
  int size() {
    return queue.size();
  }
  
  /**
   * Get remaining commands
   */
  int remaining() {
    return queue.size() - currentIndex;
  }
  
  /**
   * Get all commands as array
   */
  String[] getAllCommands() {
    return queue.toArray(new String[0]);
  }
  
  /**
   * Export queue as string for saving
   */
  String exportAsString() {
    StringBuilder sb = new StringBuilder();
    for (String cmd : queue) {
      sb.append(cmd).append("\n");
    }
    return sb.toString();
  }
  
  /**
   * Import commands from string
   */
  void importFromString(String data) {
    queue.clear();
    currentIndex = 0;
    
    String[] lines = data.split("\n");
    for (String line : lines) {
      line = line.trim();
      if (!line.isEmpty()) {
        queue.add(line);
      }
    }
  }
  
  /**
   * Start executing queue
   */
  void start() {
    isRunning = true;
    currentIndex = 0;
  }
  
  /**
   * Stop executing queue
   */
  void stop() {
    isRunning = false;
  }
  
  boolean isRunning() {
    return isRunning;
  }
  
  /**
   * Reset to beginning
   */
  void reset() {
    currentIndex = 0;
  }
}
