import java.util.List;
import java.util.Map;

class Button {
    final String label;
    final Vector pos;
    final Runnable action;
    color background = #DDDDDD;
    color foreground = #000000;
    Rectangle frame;
    
    Button(String label, Runnable action, int x, int y) {
        this.label = label;
        this.action = action;
        pos = new Vector(x, y);
    }
    
    void setForeground(color foreground) {
        this.foreground = foreground;
    }
    
    void setBackground(color background) {
        this.background = background;
    }
    
    void updateFrame() {
        frame = new Rectangle(pos.getX(), pos.getY(), (int) (textWidth(label) * 1.5F), (int) (textAscent() * 1.5F));
    }
    
    Rectangle getFrame() { return frame; }
    
    void paint() {
        textSize(14);
        updateFrame();
        fill(background);
        frame.paint();
        fill(foreground);
        text(label, frame.getX() + (frame.getWidth() * 0.1), frame.getY() + (frame.getHeight() * 0.8));
        if (mousePressed && mouseButton == LEFT && frame.contains(new Vector(mouseX, mouseY))) {
            action.run();
        }
    }
}

class Switcher {
    final Vector pos;
    final Map<String, Runnable> actions = new HashMap<String, Runnable>();
    String selected = null;
    
    Switcher(int x, int y) {
        pos = new Vector(x, y);
    }
    
    void addAction(String label, Runnable onClick) {
        actions.put(label, onClick);
    }
    
    void select(String label) {
        selected = label;
        actions.get(selected).run();
    }
    
    Vector getPos() { return pos; }
    
    void paint() {
        int x = pos.getX();
        int y = pos.getY();
        
        for (final String label : actions.keySet()) {
            Button button = new Button(label, new Runnable() {
                @Override
                public void run() {
                    select(label);
                }
            }, x, y);
            
            if (selected == null) {
                select(label);
            }
            if (selected == label) {
                button.setForeground(#FFFFFF);
                button.setBackground(#555555);
            }
            
            button.paint();
            x += button.getFrame().getWidth();
        }
    }
}

class FunctionPlot {
    final List<Integer> data = new ArrayList<Integer>();
    final Rectangle bounds;
    final String yAxisLabel;
    final String xAxisLabel;
    
    FunctionPlot(String yAxisLabel, String xAxisLabel, int x, int y, int w, int h) {
        this.xAxisLabel = xAxisLabel;
        this.yAxisLabel = yAxisLabel;
        bounds = new Rectangle(x, y, w, h);
    }
    
    int[] generateScaledData() {
        int min = Integer.MAX_VALUE;
        int max = Integer.MIN_VALUE;
        int[] scaledData = new int[data.size()];
        
        for (int value : data) {
            min = min(min, value);
            max = max(max, value);
        }
        for (int i=0; i<scaledData.length; i++) {
            float scale = max - min;
            scaledData[i] = scale == 0 ? 0 : (int) (((data.get(i) - min) / scale) * (float) bounds.getHeight());
        }
        
        return scaledData;
    }
    
    void addDataPoint(int v) {
        if (data.size() >= bounds.getWidth()) {
            data.remove(0);
        }
        
        data.add(v);
    }
    
    void paint() {
        int x = bounds.getX();
        int y = bounds.getY();
        int w = bounds.getWidth();
        int h = bounds.getHeight();
        int labelSize = 18;
        
        stroke(0);
        textSize(labelSize);
        fill(0);
        
        text(yAxisLabel, x + (labelSize / 2), y + labelSize);
        text(xAxisLabel, x + w - (labelSize / 2), y + h - labelSize);
        new Vector(0, -h).paint(x, y + h);
        new Vector(w, 0).paint(x, y + h);
        
        stroke(0, 0, 255);
        strokeWeight(2);
        
        int[] scaledData = generateScaledData();
        int currentX = x;
        int lastValue = 0;
        for (int value : scaledData) {
            line(currentX - 1, y + h - lastValue, currentX, y + h - value);
            lastValue = value;
            currentX++;
        }
        
        strokeWeight(1);
    }
}

class Slider {
    final int w = 200;
    final int h = 10;
    int x;
    int y;
    int sliderX;
    int sliderY;
    float min;
    float max;
    float value;
    boolean dragging = false;
    
    Slider(int x, int y, float min, float max) {
        this.x = x;
        this.y = y;
        sliderX = x;
        sliderY = y;
        this.min = min;
        this.max = max;
        value = min;
    }
    
    float getValue() {
        return value;
    }
    
    boolean containsX(int x) {
        return x >= this.x && x <= (this.x + w);
    }
    
    boolean containsY(int y) {
        return y >= this.y && y <= (this.y + h);
    }
    
    boolean contains(int x, int y) {
        return containsX(x) && containsY(y);
    }
    
    void paint(String suffix) {
        stroke(128);
        fill(128);
        rect(x, y, w, h);
        
        if (mousePressed) {
            if (contains(mouseX, mouseY) && mouseButton == LEFT) {
                dragging = true;
            }
            if (dragging && containsX(mouseX)) {
                sliderX = mouseX;
                value = (((sliderX - x) / (float) w) * (max - min)) + min;
            }
        } else {
            dragging = false;
        }
        
        stroke(0);
        fill(0);
        textSize(14);
        text(String.format("%.2f", value) + suffix, x + w + 10, y + h);
        rect(sliderX, sliderY, h, h);
    }
}