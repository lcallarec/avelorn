using SDL;
using SDL.Video;
using SDLGraphics;
using SDLImage;

public class RoomSprites {
    private const int TILE_SIZE = 32;
    private GLib.Rand rand = new GLib.Rand();

    public Rect[] top_walls(int count) {
        Rect[] top_walls = new Rect[count];
        for(var i = 0; i < count; i++) {
            top_walls[i]= Rect() {x = rand.int_range(1, 3) * TILE_SIZE, y = 0, w = 32, h = 96};
        }
        return top_walls;
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

    public Room(int width, int heigth, Renderer renderer) {
        this.width = width;
        this.height = heigth;
        this.geometry = Rect() {x = 0, y = 0, w = width * TILE_SIZE, h = heigth * TILE_SIZE};

        this.renderer = renderer;
        texture = Video.Texture.create_from_surface(this.renderer, sprite);

        Rectangle.fill_rgba(this.renderer, (int16) geometry.x, (int16) geometry.y, (int16) geometry.w, (int16) geometry.h, 91, 80, 118, 255);

        var ds = new RoomSprites();

        top_walls = ds.top_walls(width);
    }

    public void render() {
        //top walls
        for(var i = 0; i < top_walls.length; i++) {
            renderer.copy(texture, top_walls[i], Rect() { x = geometry.x + (i * TILE_SIZE), y = geometry.y, w = 32, h = 96});            
        }

        //top walls floor
        for(var i = 0; i < geometry.w; i += TILE_SIZE * 4) {
            renderer.copy(texture, {0, 96, 128, 32}, Rect() { x = geometry.x + i, y = geometry.y + 96, w = 128, h = 32});            
        }
        //left walls
        for(var i = 0; i < geometry.h; i += TILE_SIZE) {
            renderer.copy(texture, {32, 160, 32, 32}, Rect() { x = geometry.x, y = (int) geometry.y + i, w = 32, h = 32});            
        }
        //left walls floor
        for(var i = 96+16; i < geometry.h - TILE_SIZE * 2; i += TILE_SIZE) {
            renderer.copy(texture, {64, 128, 32, 64}, Rect() { x = geometry.x + 32, y = (int) geometry.y + i, w = 32, h = 64});            
        }
        //right walls
        for(var i = 0; i < geometry.h; i += TILE_SIZE) {
            renderer.copy(texture, {0, 160, 32, 32}, Rect() { x = (int) geometry.w - 32, y = (int) geometry.y + i, w = 32, h = 32});            
        }
        //right walls floor
        for(var i = 96+16; i < geometry.h - TILE_SIZE * 2; i += TILE_SIZE) {
            renderer.copy(texture, {96, 128, 32, 62}, Rect() { x = (int) geometry.w - 64, y = (int) geometry.y + i, w = 32, h = 64});            
        }
        //bottom walls
        for(var i = 0; i < geometry.w; i += TILE_SIZE * 4) {
            renderer.copy(texture, {0, 192, 128, 32}, Rect() { x = geometry.x + i, y = (int) geometry.h - 32, w = 128, h = 32});            
        }
    }
}