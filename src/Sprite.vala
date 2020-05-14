using SDL.Video;

public enum Priority {
    NE,
    E,
    SE,
    S,
    SW,
    W,
    NW,
    N,
    H
}

public class FrameOptions {

    public int step;
    public int speed;
    public int frame;

    public FrameOptions(int step = 0, int speed = 8, int frame = 0) {
        this.step = step;
        this.speed = speed;
        this.frame = frame;
    }
}

public struct Sprite {
    public Rect src;
    public Rect dest;
    public Priority priority;
    public FrameOptions? frame_options;
    public void render(Renderer renderer, Texture texture) {
        
        if (frame_options != null) {
            if (++frame_options.frame % 8 == 1) {
                frame_options.step = (++frame_options.step) % 4;
            }
            renderer.copy(
                texture,
                Rect() {x = src.x + (int) (frame_options.step * src.w), y = src.y, w = src.w, h = src.h},
                dest
            );
        } else {
            renderer.copy(texture, src, dest);
        }
    }
}
