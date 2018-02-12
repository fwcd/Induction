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

class Rectangle {
    final int x;
    final int y;
    final int w;
    final int h;
    
    Rectangle(int x, int y, int w, int h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }
    
    Rectangle(Vector topLeft, Vector bottomRight) {
        x = topLeft.getX();
        y = topLeft.getY();
        w = bottomRight.getX() - x;
        h = bottomRight.getY() - y;
    }
    
    Vector getTopLeft() {
        return new Vector(x, y);
    }
    
    Vector getBottomRight() {
        return new Vector(x + w, y + h);
    }
    
    boolean contains(Vector pos) {
        return pos.getX() > x && pos.getX() < (x + w)
                && pos.getY() > y && pos.getY() < (y + h);
    }
    
    void paint() {
        rect(x, y, w, h);
    }
    
    int getX() { return x; }
    
    int getY() { return y; }
    
    int getWidth() { return w; }
    
    int getHeight() { return h; }
}