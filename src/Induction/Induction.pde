import java.util.concurrent.ThreadLocalRandom;

// Class declarations

class Magnet {
    final Rectangle frame;
    final int s = 20;
    final HomogeneousVectorField bField;
    
    Magnet(int x, int y, int w, int h) {
        frame = new Rectangle(x, y, w, h);
        bField = new HomogeneousVectorField(x + s, y + s, w - s, h - (2 * s), new Vector(0, 10));
    }
    
    Vector getMagneticFluxDensity(Vector pos) {
        return bField.getValue(pos);
    }

    void updateStrength(float absMagneticFluxDensity) {
        bField.normScaleValue(absMagneticFluxDensity);
    }

    void paint() {
        int segHeight = (frame.getHeight() - (2 * s)) / 2;
        
        noStroke();
        fill(255, 0, 0);
        rect(frame.getX(), frame.getY(), frame.getWidth(), s);
        rect(frame.getX(), frame.getY() + s, s, segHeight);
        fill(0, 255, 0);
        rect(frame.getX(), frame.getY() + s + segHeight, s, segHeight);
        rect(frame.getX(), frame.getY() + s + (segHeight * 2), frame.getWidth(), s);
        bField.paint();
    }
}

// Field declarations

final Slider cableLengthSlider = new Slider(10, 10, 1, 50);
final Slider magneticFluxSlider = new Slider(10, 25, 1, 50);
final Switcher itemSwitcher = new Switcher(450, 10);
Magnet magnet;
FunctionPlot voltagePlot;
ConductorSupplier condSupplier;
Conductor conductor;
boolean showHint = true;

// Method declarations

void createConductor() {
    if (conductor == null) {
        conductor = condSupplier.newConductor(-100, -100, 0, 0);
    } else {
        Vector pos = conductor.getPos();
        Vector v = conductor.getVelocity();
        conductor = condSupplier.newConductor(pos.getX(), pos.getY(), v.getX(), v.getY());
    }
}

void setup() {
    size(640, 480);
    magnet = new Magnet(20, 50, 400, 200);
    voltagePlot = new FunctionPlot("U", "t", 20, 260, 400, 180);
    
    itemSwitcher.addAction("Cable", new Runnable() { @Override public void run() {
        condSupplier = new ConductorSupplier() { @Override public Conductor newConductor(int x, int y, int vX, int vY) {
            return new Cable(x, y, vX, vY);
        }};
        createConductor();
    }});
    // TODO:
    /*itemSwitcher.addAction("Loop", new Runnable() { @Override public void run() {
        condSupplier = new ConductorSupplier() { @Override public Conductor newConductor(int x, int y, int vX, int vY) {
            return new ConductorLoop(x, y, vX, vY);
        }};
        createConductor();
    }});*/
}

void draw() {
    clear();
    background(255);
    
    magnet.updateStrength(magneticFluxSlider.getValue());
    magnet.paint();
    voltagePlot.paint();
    
    if (mousePressed) {
        showHint = false;
        
        if (mouseButton == RIGHT) {
            Vector velocity = new Vector(0, 0);
            
            if (conductor != null) {
                velocity = conductor.getPos().sub(new Vector(mouseX, mouseY));
                
                if (velocity.isZero()) {
                    velocity = conductor.getVelocity();
                }
            }
            
            conductor = condSupplier.newConductor(mouseX, mouseY, velocity.getX(), velocity.getY());
        }
    }
    
    if (conductor != null) {
        conductor.updateVoltage(magnet.getMagneticFluxDensity(conductor.getPos()), cableLengthSlider.getValue());
        voltagePlot.addDataPoint((int) conductor.getVoltage());
        conductor.paint();
    
        fill(0);
        textSize(12);
        text(conductor.getDescription(), itemSwitcher.getPos().getX(), itemSwitcher.getPos().getY() + 40);
    }
    
    cableLengthSlider.paint(" m (Conductor length)");
    magneticFluxSlider.paint(" T (Magnetic flux density)");
    itemSwitcher.paint();
    
    if (showHint) {
        textSize(15);
        text("Drag sliders to change parameters - Right click to place cable", 10, height - 10);
    }
}