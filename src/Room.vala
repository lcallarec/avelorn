using SDL;
using SDL.Video;
using SDLGraphics;
using SDLImage;

public class RoomSprites {
    private const int TILE_SIZE = 32;
    private GLib.Rand rand = new GLib.Rand();

    public Rect[] top_walls(int count) {
        Rect[] top_walls = new Rect[count - 1]; //Remove last top wall to not overlaps with right wall
        for(var i = 0; i < count - 1; i++) {
            top_walls[i] = Rect() {x = rand.int_range(1, 5) * TILE_SIZE, y = 0, w = 32, h = 128};
        }
        return top_walls;
    }

    public Rect[] right_walls(int count) {
        Rect[] right_walls = new Rect[count];
        for(var i = 0; i < count; i++) {
            right_walls[i] = Rect() {x = 128, y = rand.int_range(4, 6) * TILE_SIZE, w = 64, h = 32};
        }
        return right_walls;
    }

    public Rect[] bottom_walls(int count) {
        Rect[] bottom_walls = new Rect[count - 1]; //Remove last right to not overlap with right wall
        for(var i = 0; i < count - 1; i++) {
            bottom_walls[i] = Rect() {x = rand.int_range(0, 5) * TILE_SIZE, y = 192, w = 32, h = 32};
        }
        return bottom_walls;
    }

    public Rect[] left_walls(int count) {
        Rect[] left_walls = new Rect[count - 1]; //Remove last bottom wall to avoid overlaps with bottom wall
        for(var i = 0; i < count - 1; i++) {
            left_walls[i] = Rect() {x = 64, y = rand.int_range(4, 6) * TILE_SIZE, w = 64, h = 32};
        }
        return left_walls;
    }
}

public class Room {
    private Video.Texture texture;
    private unowned Video.Renderer renderer;
    private SDL.Video.Surface sprite = load_png(new RWops.from_file("./resources/dungeon.png", "r"));
    
    private int width;
    private int height;
    private Rect geometry;

    private const int TILE_SIZE = 32;

    private Rect[] top_walls;
    private Rect[] right_walls;
    private Rect[] bottom_walls;
    private Rect[] left_walls;

    public Room(int width, int heigth, Renderer renderer) {
        this.width = width;
        this.height = heigth;
        this.geometry = Rect() {x = 0, y = 0, w = width * TILE_SIZE, h = heigth * TILE_SIZE};

        this.renderer = renderer;
        texture = Video.Texture.create_from_surface(this.renderer, sprite);

        Rectangle.fill_rgba(this.renderer, (int16) geometry.x, (int16) geometry.y, (int16) geometry.w, (int16) geometry.h, 91, 80, 118, 255);

        var ds = new RoomSprites();

        top_walls = ds.top_walls(width);
        right_walls = ds.right_walls(height);
        bottom_walls = ds.bottom_walls(width);
        left_walls = ds.left_walls(height);
    }

    public void render() {
        for(var i = 0; i < right_walls.length ; i++) {
            renderer.copy(texture, right_walls[i], Rect() { x = (int) geometry.w - TILE_SIZE * 2, y = (int) geometry.y + (i * TILE_SIZE), w = TILE_SIZE * 2, h = TILE_SIZE});
        }
        for(var i = 0; i < bottom_walls.length ; i++) {
            renderer.copy(texture, bottom_walls[i], Rect() { x = geometry.x + (i * TILE_SIZE), y = (int) geometry.h - 32, w = 32, h = 32});
        }
        for(var i = 0; i < left_walls.length ; i++) {
            renderer.copy(texture, left_walls[i], Rect() { x = geometry.x, y = (int) geometry.y + (i * TILE_SIZE), w = 64, h = 32});
        }
        for(var i = 1; i < top_walls.length; i++) {
            renderer.copy(texture, top_walls[i], Rect() { x = geometry.x + (i * TILE_SIZE), y = geometry.y, w = TILE_SIZE, h = 96});            
        }
    }
}