import java.util.List;

class FunctionPlot {
    final List<Integer> data = new ArrayList<Integer>();
    final int x;
    final int y;
    final int w;
    final int h;
    final String yAxisLabel;
    final String xAxisLabel;
    
    FunctionPlot(String yAxisLabel, String xAxisLabel, int x, int y, int w, int h) {
        this.xAxisLabel = xAxisLabel;
        this.yAxisLabel = yAxisLabel;
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
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
            scaledData[i] = scale == 0 ? 0 : (int) (((data.get(i) - min) / scale) * (float) h);
        }
        
        return scaledData;
    }
    
    void addDataPoint(int v) {
        if (data.size() >= w) {
            data.remove(0);
        }
        
        data.add(v);
    }
    
    void paint() {
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