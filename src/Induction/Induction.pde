import java.util.concurrent.ThreadLocalRandom;

// Class declarations

class HomogeneousVectorField {
    final Rectangle bounds;
    Vector value;
    
    HomogeneousVectorField(int x, int y, int w, int h, Vector value) {
        bounds = new Rectangle(x, y, w, h);
        this.value = value;
    }
    
    boolean contains(int x, int y) {
        return x > topLeft.getX() && x < bottomRight.getX()
                && y > topLeft.getY() && y < bottomRight.getY();
    }
    
    void normScaleValue(float newLength) {
        value = value.normScale(newLength);
    }
    
    Vector getValue(int x, int y) {
        if (contains(x, y)) {
            return value;
        } else {
            return new Vector(0, 0);
        }
    }
    
    void paint() {
        stroke(160);
        int yStep = max(value.getY(), 10);
        int xStep = 15;
        for (int y=topLeft.getY(); y<bottomRight.getY(); y+=yStep) {
            for (int x=topLeft.getX(); x<bottomRight.getX(); x+=xStep) {
                value.paint(x, y);
            }
        }
    }
}

class Magnet {
    final Rectangle frame;
    final int s = 20;
    final HomogeneousVectorField bField;
    
    Magnet(int x, int y, int w, int h) {
        frame = new Rectangle(x, y, w, h);
        bField = new HomogeneousVectorField(x + s, y + s, w, h - s, new Vector(0, 10));
    }
    
    Vector getMagneticFluxDensity(Vector pos) {
        return bField.getValue(pos.getX(), pos.getY());
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

class Cable {
    final int symbolRadius = 20;
    Vector pos;
    Vector velocity;
    float voltage;
    
    Cable(int x, int y, int vX, int vY) {
        pos = new Vector(x, y);
        velocity = new Vector(vX, vY);
    }
    
    Vector getPos() { return pos; }
    
    Vector getVelocity() { return velocity; }
    
    void update(float cableLength, Vector magneticFlux) {
        voltage = cableLength * velocity.cross(magneticFlux);
    }
    
    float getVoltage() {
        return voltage;
    }
    
    void paint() {
        int r = symbolRadius;
        int d = r * 2;
        int l = (int) (r * sin(PI / 4));
        
        fill(0);
        textSize(16);
        text("v = " + velocity.toString() + " m/s", pos.getX(), pos.getY() - d);
        text("U = " + Float.toString(voltage) + " V", pos.getX(), pos.getY() - r);
        stroke(0);
        noFill();
        ellipse(pos.getX(), pos.getY(), r, r);
        line(pos.getX() - r + l, pos.getY() - r + l, pos.getX() + r - l, pos.getY() + r - l);
        line(pos.getX() + r - l, pos.getY() - r + l, pos.getX() - r + l, pos.getY() + r - l);
        
        velocity = velocity.scale(0.5);
    }
}

// Field declarations

final Slider cableLengthSlider = new Slider(10, 10, 1, 50);
final Slider magneticFluxSlider = new Slider(10, 25, 1, 50);
Magnet magnet;
FunctionPlot voltagePlot;
Cable cable = null;
boolean showHint = true;

// Method declarations

void setup() {
    size(640, 480);
    magnet = new Magnet(20, 50, 400, 200);
    voltagePlot = new FunctionPlot("U", "t", 20, 260, 400, 180);
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
            
            if (cable != null) {
                velocity = cable.getPos().sub(new Vector(mouseX, mouseY));
                
                if (velocity.isZero()) {
                    velocity = cable.getVelocity();
                }
            }
            
            cable = new Cable(mouseX, mouseY, velocity.getX(), velocity.getY());
        }
    }
    
    if (cable != null) {
        cable.update(cableLengthSlider.getValue(), magnet.getMagneticFluxDensity(cable.getPos()));
        voltagePlot.addDataPoint((int) cable.getVoltage());
        cable.paint();
    }
    
    cableLengthSlider.paint(" m (Cable length)");
    magneticFluxSlider.paint(" T (Magnetic flux density)");
    
    if (showHint) {
        textSize(15);
        text("Drag sliders to change parameters - Right click to place cable", 10, height - 10);
    }
}