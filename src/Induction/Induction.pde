import java.util.concurrent.ThreadLocalRandom;

class Vector {
    final int x;
    final int y;

    Vector(int x, int y) {
        this.x = x;
        this.y = y;
    }
    
    int getX() { return x; }
    
    int getY() { return y; }
    
    boolean isZero() { return x == 0 && y == 0; }
    
    double length() {
        return sqrt((x * x) + (y * y));
    }
    
    Vector add(Vector other) {
        return new Vector(x + other.x, y - other.y);
    }
    
    Vector sub(Vector other) {
        return new Vector(x - other.x, y - other.y);
    }
    
    Vector scale(double factor) {
        return new Vector((int) (x * factor), (int) (y * factor));
    }
    
    float cross(Vector other) {
        return (x * other.y) - (y * other.x);
    }
    
    Vector normScale(double l) {
        double length = length();
        return new Vector((int) ((x / length) * l), (int) ((y / length) * l));
    }

    void paint(int sX, int sY) {
        int eX = sX + x;
        int eY = sY + y;
        float theta = atan2(y, x);
        line(sX, sY, eX, eY);
        translate(eX, eY);
        rotate(-(PI / 2) + theta);
        line(-5, -5, 0, 0);
        rotate(PI / 2);
        line(-5, -5, 0, 0);
        rotate(-theta);
        translate(-eX, -eY);
    }
    
    @Override
    String toString() {
        return "(" + Integer.toString(x) + ", " + Integer.toString(y) + ")";
    }
}

class HomogeneousVectorField {
    final Vector topLeft;
    final Vector bottomRight;
    Vector value;
    
    HomogeneousVectorField(int tlX, int tlY, int brX, int brY, Vector value) {
        topLeft = new Vector(tlX, tlY);
        bottomRight = new Vector(brX, brY);
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
    final int x;
    final int y;
    final int w;
    final int h;
    final int s = 20;
    final HomogeneousVectorField bField;
    
    Magnet(int x, int y, int w, int h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        bField = new HomogeneousVectorField(x + s, y + s, x + w, y + h - s, new Vector(0, 10));
    }
    
    Vector getMagneticFlux(Vector pos) {
        return bField.getValue(pos.getX(), pos.getY());
    }

    void updateStrength(float magneticFlux) {
        bField.normScaleValue(magneticFlux);
    }

    void paint() {
        int segHeight = (h - (2 * s)) / 2;
        noStroke();
        fill(255, 0, 0);
        rect(x, y, w, s);
        rect(x, y + s, s, segHeight);
        fill(0, 255, 0);
        rect(x, y + s + segHeight, s, segHeight);
        rect(x, y + s + (segHeight * 2), w, s);
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

final Slider cableLengthSlider = new Slider(10, 10, 0, 100);
final Slider magneticFluxSlider = new Slider(10, 25, 1, 100);
Magnet magnet;
FunctionPlot voltagePlot;
Cable cable = null;
boolean showHint = true;

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
        cable.update(cableLengthSlider.getValue(), magnet.getMagneticFlux(cable.getPos()));
        voltagePlot.addDataPoint((int) cable.getVoltage());
        cable.paint();
    }
    
    cableLengthSlider.paint(" m (Cable length)");
    magneticFluxSlider.paint(" B (Magnetic flux)");
    
    if (showHint) {
        textSize(15);
        text("Drag sliders to change parameters - Right click to place cable", 10, height - 10);
    }
}