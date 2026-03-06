# Polargraph Controller - Processing 4

A complete rewrite of the Polargraph controller application in Processing 4, migrated from the original Processing 2 codebase.

## About Polargraph

Polargraph is a networked drawing robot that creates art by manipulating pen position using two stepper motors and string tension. This application provides the desktop controller for managing the machine.

## Current Status

**Phase 1 - MVP (Initial Build)**
- ✅ Core machine physics and math
- ✅ Serial communication framework
- ✅ Command queue system
- ✅ Basic UI (processing native, no dependencies)
- ✅ Pen control (up/down)
- ✅ Position control
- ⏳ Image processing (Phase 2)
- ⏳ Vector graphics support (Phase 3)

## Project Structure

```
Polargraphcontroller_P4/
├── Polargraphcontroller_P4.pde    # Main sketch
├── src/
│   ├── Core/
│   │   ├── Machine.pde            # Machine specifications & conversions
│   │   ├── CommandQueue.pde       # Command management
│   │   └── SerialComm.pde         # Serial communication
│   ├── UI/
│   │   ├── UIManager.pde          # UI panels and controls
│   │   └── Panels/                # Individual panel implementations
│   ├── Drawing/
│   │   ├── CommandGenerator.pde   # Generate commands from input
│   │   ├── ImageProcessor.pde     # Convert images to commands
│   │   └── VectorProcessor.pde    # Convert vectors to commands
│   └── Utils/
│       ├── Config.pde             # Configuration management
│       └── FileUtils.pde          # File I/O utilities
└── data/
    └── config/                    # Store user configurations
```

## Requirements

- **Processing 4.0+**
- USB serial cable (for machine communication)
- Polargraph machine hardware

## Installation

1. Open `Polargraphcontroller_P4.pde` in Processing 4
2. Click Run (Play button)
3. Use the UI to configure and test

## Usage

### Basic Workflow

1. **Serial Connection**
   - Select COM port from dropdown
   - Click "Connect"
   - Machine should respond to status query

2. **Machine Setup**
   - Configure machine width/height
   - Set motor specs (steps/rev, mm/rev)
   - Set home position
   - Save configuration

3. **Drawing**
   - Load image or vector file
   - Select area to draw
   - Generate commands
   - Review queue
   - Execute

### Quick Controls

| Button | Action |
|--------|--------|
| **Pen Up** | Queue pen up command |
| **Pen Down** | Queue pen down command |
| **Home** | Queue move to home position |
| **Start** | Begin executing command queue |
| **Pause** | Pause queue execution |
| **Clear** | Clear all queued commands |

## Machine Commands

### Supported Commands

- **C01,A,B,END** - Change motor position (A=motorA, B=motorB steps)
- **C13,END** - Pen down
- **C14,END** - Pen up
- **C09,A,B,END** - Set absolute position
- **C26,END** - Request machine size/status
- **C27,END** - Reset machine

*See original README for complete command set*

## Configuration

Machine settings are stored in `data/config/default.properties`

Key properties:
```properties
machine.width=2790
machine.height=2347
machine.motors.stepsPerRev=200
machine.motors.mmPerRev=40
machine.penlift.up=15
machine.penlift.down=88
controller.homepoint.x=1395
controller.homepoint.y=1395
```

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| **Q** | Clear command queue |

## Architecture Notes

### Why No GUI Library?

The MVP uses Processing's native drawing capabilities instead of ControlP5 for:
- Simpler debugging
- Fewer dependencies
- Easier to maintain and modify
- Full control over UI responsiveness
- Processing 4 compatibility guaranteed

### Future Enhancements

Phase 2+ will add:
- Image loading and processing
- Vector graphics support
- Advanced rendering modes
- Webcam capture integration
- Configuration UI improvements

## Troubleshooting

**Can't connect to machine**
- Verify USB cable is connected
- Check COM port is correct (should show in dropdown)
- Machine may need power cycled
- Try a different USB port

**Commands not executing**
- Verify serial connection is active
- Check command queue has commands
- Review machine status messages in console

**Performance issues**
- Reduce grid size if drawing is slow
- Close other applications
- Check CPU usage

## License

GNU General Public License v3.0

Based on original work by Sandy Noble (euphy)
https://github.com/euphy/polargraphcontroller

## Migration Notes

This is a **clean rewrite** of the Processing 2 version for Processing 4. Key changes:

- **No ControlP5** - Using native Processing UI for MVP
- **No Geomerative** - Will use built-in shape() or Batik for SVG
- **No diewald_CV_kit** - Optional blob detection can be added later
- **Modular architecture** - Easier to test and extend
- **Processing 4 native** - Uses current Processing standards

See `REWRITE_SPECIFICATION.md` in parent directory for detailed migration notes.
