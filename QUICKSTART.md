# Quick Start Guide - Polargraph Controller P4

## Opening the Project

1. **In VS Code:**
   - File → Open Folder
   - Select: `c:\Users\simon\OneDrive\Documents 1\GitHub\Polargraphcontroller_P4`

2. **In Processing 4:**
   - File → Open
   - Navigate to `Polargraphcontroller_P4.pde` in the root folder
   - Click Open

3. **Run the sketch:**
   - Click the Play (Run) button
   - A window should open showing:
     - Machine representation on the left (gray rectangle with grid)
     - Control panels on the right (Status, Serial, Queue, Controls)

## First-Time Setup

### Step 1: Connect to Machine
1. Plug in USB cable from machine
2. In the **Serial Connection** panel, click "Connect"
   - Should see connection status change to "CONNECTED"
3. Check the console for messages

### Step 2: Verify Machine Communication
1. Click "Home" button in Controls panel
   - Should add a command to the queue
2. Watch the console for debug output

### Step 3: Test Controls
- Click **Pen Up** - adds command to queue
- Click **Pen Down** - adds command to queue
- Click **Start** - begins sending commands (if connected)
- Click **Clear** - empties the queue

## File Organization

```
Polargraphcontroller_P4/
├── Polargraphcontroller_P4.pde     ← Main file (open this in Processing)
├── README.md                        ← Project overview
├── TODO.md                         ← Development checklist
├── .gitignore                      ← Git ignore rules
│
├── src/Core/                       ← Core logic (don't usually edit)
│   ├── Machine.pde
│   ├── CommandQueue.pde
│   └── SerialComm.pde
│
├── src/UI/                         ← UI panels (can customize here)
│   └── UIManager.pde
│
├── src/Drawing/                    ← Command generation (Phase 2+)
│   ├── CommandGenerator.pde
│   ├── ImageProcessor.pde
│   └── VectorProcessor.pde
│
├── src/Utils/                      ← Utilities (Phase 2+)
│   └── Config.pde
│
└── data/config/                    ← Configuration files
    └── default.properties
```

## Common Tasks

### Add a new button to the UI
1. Open `src/UI/UIManager.pde`
2. Add to `ControlsPanel.pde` section:
```processing
private SimpleButton myNewBtn;

// In constructor:
myNewBtn = new SimpleButton(new Rectangle(x, y, 70, 25), "My Button");

// In display():
myNewBtn.display();

// In handleMousePress():
if (myNewBtn.isInBounds(x, y)) {
  // Do something when clicked
}
```

### Send a command to the machine
```processing
commandQueue.add("C01,1000,1000,END");  // Move to position
commandQueue.addPenUp();                 // Pen up
commandQueue.addPenDown();               // Pen down
```

### Check if machine is connected
```processing
if (serialComm.isConnected()) {
  // Machine is connected
}
```

### Read received messages
```processing
String lastMessage = serialComm.getLastMessage();
println("Machine said: " + lastMessage);
```

## Troubleshooting

**Sketch won't run:**
- Make sure you're using Processing 4.0 or later
- Check that all files are present in the folder structure
- Try Re-loading the sketch (Ctrl+R)

**Can't connect to machine:**
- Check USB cable connection
- Try different USB port
- Verify machine is powered on
- Look for error messages in console

**UI not displaying properly:**
- Check window size (defaults to 1200x800)
- Try resizing the window
- Look for error messages in console

**Commands not being sent:**
- Make sure serial connection is active (green "CONNECTED" indicator)
- Check that commands are in the queue
- Click "Start" to begin execution
- Monitor console output for debug messages

## Next Steps

1. **Test without machine:**
   - Run the sketch
   - Test all buttons
   - Verify queue operations
   - Check UI responsiveness

2. **Connect to machine:**
   - Hook up USB cable
   - Test serial communication
   - Verify command transmission
   - Check position feedback

3. **Customize for your setup:**
   - Edit `data/config/default.properties` with your machine specs
   - Adjust UI layout if needed
   - Add any custom controls

4. **Report Issues:**
   - Check console for error messages
   - Document what went wrong
   - Note any error messages
   - Share configuration for testing

## File Structure Reference

### Main Sketch (`Polargraphcontroller_P4.pde`)
- Application entry point
- Global variables
- main `draw()` loop
- Keyboard/mouse input handling

### Machine Physics (`src/Core/Machine.pde`)
- Machine size and motor specs
- Coordinate transformations
- Display rendering

### Command Queue (`src/Core/CommandQueue.pde`)
- Queues ASCII commands
- Manages execution
- Export/import operations

### Serial Communication (`src/Core/SerialComm.pde`)
- Serial port connection
- Sending/receiving data
- Message parsing

### User Interface (`src/UI/UIManager.pde`)
- Panel layout
- Button controls
- Display rendering

## For Developers

### Adding a new feature:
1. Create a new .pde file in appropriate folder
2. Keep logic separate from UI
3. Test incrementally
4. Document with comments
5. Update TODO.md

### Code style:
- Use camelCase for variables/methods
- Use UPPER_CASE for constants
- Add comments for complex logic
- Keep methods under 30 lines

### Testing approach:
- Test without machine first
- Use console output for debug
- Check edge cases
- Verify error handling

---

**Questions?** Check README.md or TODO.md for more info.
