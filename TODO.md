# Development TODO - Polargraph Controller P4

## Phase 1: MVP - Core Functionality (In Progress)

### Core Components
- [x] Machine class (physics & conversions)
- [x] CommandQueue class
- [x] SerialComm class
- [x] Basic UIManager
- [x] Main sketch setup

### Serial Communication
- [x] Fix serialEvent() callback integration
- [x] Test serial connection
- [x] Receive and parse machine responses
- [ ] Add serial port selector
- [ ] Handle connection errors gracefully

### UI Refinements
- [x] Improve button styling
- [x] Add serial port dropdown
- [x] Display received messages
- [x] Add slider for motor positions
- [x] Visual command queue with current command highlighting
- [ ] Keyboard shortcuts (delete queue item, etc.)

### Configuration
- [x] Load default.properties on startup
- [x] Save configuration changes
- [ ] Load custom configurations
- [ ] Validate configuration values

### Testing
- [ ] Test without machine (simulation mode)
- [ ] Test with actual machine
- [ ] Verify all button actions
- [ ] Check memory usage
- [ ] Performance optimization if needed

## Phase 2: Image Processing

### Image Loading
- [ ] File browser UI
- [ ] Supported formats (PNG, JPG, BMP)
- [ ] Image preview display
- [ ] Image scaling/rotation

### Image to Raster
- [ ] Area selection tool
- [ ] Pixel extraction with grid
- [ ] Dithering algorithms
- [ ] Threshold controls
- [ ] Preview rendering

### Command Generation
- [ ] Convert pixels to move commands
- [ ] Raster scanning patterns (left-right, spiral, etc.)
- [ ] Optimize command order
- [ ] Preview path on display

## Phase 3: Vector Graphics

### Vector Support
- [ ] SVG loading (using Shape class or Batik)
- [ ] Vector preview display
- [ ] Stroke to commands conversion
- [ ] Bezier curve approximation
- [ ] Vector simplification options

## Phase 4: Advanced Features

### Capture Features
- [ ] Webcam integration (optional)
- [ ] Real-time preview
- [ ] Capture to image

### Advanced Modes
- [ ] Rove mode
- [ ] Sprite drawing
- [ ] Text rendering
- [ ] Random drawing

### Extended UI
- [ ] Tabbed interface
- [ ] Advanced settings panel
- [ ] Command history display
- [ ] Real-time machine status

## Technical Debt & Cleanup

- [ ] Refactor UIManager into separate panel files
- [ ] Add error handling throughout
- [ ] Add logging system
- [ ] Add inline code documentation
- [ ] Create unit tests for core math
- [ ] Performance profiling

## Known Issues

- SerialEvent callback may not work properly in Processing 4 - needs testing
- Rectangle class methods need verification
- Display coordinate system needs validation with actual machine

## Dependencies

Processing 4.0+
- ✅ Serial library (included)
- No external GUI library (using native Processing)
- Optional for Phase 2+: Batik for SVG support

## Quick Start for Contributors

1. Open `Polargraphcontroller_P4.pde` in Processing 4
2. Run the sketch
3. UI should display on right side
4. Check console for debug messages
5. Test functionality without machine first

## Questions / Notes

- [ ] Clarify exact machine dimensions and calibration
- [ ] Get sample commands for testing
- [ ] Determine preferred drawing styles
- [ ] Finalize UI layout preferences
