import java.util.Properties;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;

/**
 * Config.pde
 *
 * Simple wrapper for reading the default.properties configuration file.
 * Stores commonly-used values so the rest of the application can access them.
 */

class Config {
  Properties props;
  String filename = "data/config/default.properties";

  // stored config values
  float penUpPosition = 15;
  float penDownPosition = 88;
  float penWidth = 0.3;

  float motorMaxSpeed = 1600;
  float motorAccel = 1000;

  float homeX = 1395;
  float homeY = 1395;

  float machineWidth = 2790;
  float machineHeight = 2347;

  Config() {
    props = new Properties();
    load();
  }

  void load() {
    try {
      File f = new File(filename);
      if (f.exists()) {
        FileInputStream fis = new FileInputStream(f);
        props.load(fis);
        fis.close();
      }

      penUpPosition = get("machine.penlift.up", penUpPosition);
      penDownPosition = get("machine.penlift.down", penDownPosition);
      penWidth = get("machine.pen.size", penWidth);

      motorMaxSpeed = get("machine.motors.maxSpeed", motorMaxSpeed);
      motorAccel = get("machine.motors.accel", motorAccel);

      homeX = get("controller.homepoint.x", homeX);
      homeY = get("controller.homepoint.y", homeY);

      machineWidth = get("machine.width", machineWidth);
      machineHeight = get("machine.height", machineHeight);

      println("Configuration loaded from " + filename);
    } catch (Exception e) {
      println("Failed to load configuration: " + e);
    }
  }

  void save() {
    try {
      // Update properties with current values
      props.setProperty("machine.penlift.up", str(penUpPosition));
      props.setProperty("machine.penlift.down", str(penDownPosition));
      props.setProperty("machine.pen.size", str(penWidth));

      props.setProperty("machine.motors.maxSpeed", str(motorMaxSpeed));
      props.setProperty("machine.motors.accel", str(motorAccel));

      props.setProperty("controller.homepoint.x", str(homeX));
      props.setProperty("controller.homepoint.y", str(homeY));

      props.setProperty("machine.width", str(machineWidth));
      props.setProperty("machine.height", str(machineHeight));

      // Ensure directory exists
      File configDir = new File("data/config");
      if (!configDir.exists()) {
        configDir.mkdirs();
      }

      // Save to file
      FileOutputStream fos = new FileOutputStream(filename);
      props.store(fos, "Polargraph Controller P4 Configuration");
      fos.close();

      println("Configuration saved to " + filename);
    } catch (Exception e) {
      println("Failed to save configuration: " + e);
    }
  }

  String get(String key, String def) {
    return props.getProperty(key, def);
  }

  float get(String key, float def) {
    String s = props.getProperty(key);
    if (s != null && s.length() > 0) {
      try {
        return Float.parseFloat(s);
      } catch (NumberFormatException nfe) {
        // ignore
      }
    }
    return def;
  }

  int get(String key, int def) {
    return (int)get(key, (float)def);
  }
}
