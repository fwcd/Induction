final int textPadding = 20;

interface ConductorSupplier {
    Conductor newConductor(int x, int y, int velocityX, int velocityY);
}

interface Conductor {
    Vector getPos();
    
    Vector getVelocity();
    
    String getDescription();
    
    void updateVoltage(Vector magneticFluxDensity, float length);
    
    float getVoltage();
    
    void paint();
}
class Cable implements Conductor {
    final int symbolRadius = 20;
    final Vector pos;
    Vector velocity;
    float voltage;
    
    Cable(int x, int y, int vX, int vY) {
        pos = new Vector(x, y);
        velocity = new Vector(vX, vY);
    }
    
    @Override
    Vector getPos() { return pos; }
    
    @Override
    Vector getVelocity() { return velocity; }
    
    @Override
    void updateVoltage(Vector magneticFlux, float cableLength) {
        voltage = cableLength * velocity.cross(magneticFlux);
    }
    
    @Override
    float getVoltage() {
        return voltage;
    }
    
    @Override
    String getDescription() {
        return "A straight cable that\n"
                + "points into the screen.\n"
                + "The voltage is calculated using\n"
                + "a formula derived from the\n"
                + "Lorentz force:\n"
                + "\n"
                + "U = l * v x B";
    }
    
    void paint() {
        int r = symbolRadius;
        int d = r * 2;
        int l = (int) (r * sin(PI / 4));
        
        fill(0);
        textSize(16);
        text("v = " + velocity.toString() + " m/s", pos.getX(), pos.getY() - (textPadding * 2));
        text("U = " + Float.toString(voltage) + " V", pos.getX(), pos.getY() - textPadding);
        stroke(0);
        noFill();
        ellipse(pos.getX(), pos.getY(), r, r);
        line(pos.getX() - r + l, pos.getY() - r + l, pos.getX() + r - l, pos.getY() + r - l);
        line(pos.getX() + r - l, pos.getY() - r + l, pos.getX() - r + l, pos.getY() + r - l);
        
        velocity = velocity.scale(0.5);
    }
}

// TODO:
/*class ConductorLoop implements Conductor {
    final HomogeneousVectorField bField;
    final Vector pos;
    Vector velocity;
    int loopRadius = 20;
    float voltage;
    
    ConductorLoop(HomogeneousVectorField bField, int x, int y, int vX, int vY) {
        this.bField = bField;
        pos = new Vector(x, y);
        velocity = new Vector(vX, vY);
    }
    
    @Override
    Vector getPos() { return pos; }
    
    @Override
    Vector getVelocity() { return velocity; }
    
    int getArea(int intersectedRadius) {
        return (int) (PI * (intersectedRadius * intersectedRadius));
    }
    
    @Override
    void updateVoltage(Vector magneticFlux, float cableLength) {
        loopRadius = (int) ((cableLength / PI) / 2);
        voltage = getArea() * ;
    }
    
    @Override
    float getVoltage() {
        return voltage;
    }
    
    @Override
    String getDescription() {
        return "A conductor loop that\n"
                + "points into the screen\n"
                + "(thus only it's side is visible).\n"
                + "The voltage is calculated using\n"
                + "the area of a circle\n"
                + "\n"
                + "A = pi * r^2\n"
                + "\n"
                + "and Faraday's law\n"
                + "\n"
                + "U = B * -d(A)/dt";
    }
    
    void paint() {
        fill(0);
        textSize(16);
        text("v = " + velocity.toString() + " m/s", pos.getX(), pos.getY() - (textPadding * 2));
        text("U = " + Float.toString(voltage) + " V", pos.getX(), pos.getY() - textPadding);
        stroke(0);
        strokeWeight(5);
        noFill();
        line(pos.getX() - loopRadius, pos.getY(), pos.getX() + loopRadius, pos.getY());
        strokeWeight(1);
        
        velocity = velocity.scale(0.5);
    }
}*/