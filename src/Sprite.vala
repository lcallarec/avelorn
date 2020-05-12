using SDL.Video;

public enum Priority {
    NE,
    E,
    SE,
    S,
    SW,
    W,
    NW,
    N
}

public struct Sprite {
    public Rect src;
    public Rect dest;
    public Priority priority;
}
