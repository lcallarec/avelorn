using SDL;
using SDL.Video;
using SDLGraphics;
using SDLImage;


public struct Structure {
    public Sprite[] sprites;
    public Rect box;
}

public class RoomBuilder {
    private const int TILE_SIZE = 32;
    private GLib.Rand rand = new GLib.Rand();
    private Rect geometry;

    public Structure[] structures;

    public RoomBuilder(Rect geometry) {
        this.geometry = geometry;
        structures = new Structure[2 * TILE_SIZE * (geometry.w + geometry.h)];
    }

    public Structure top(int count) {
        Sprite[] sprites = new Sprite[count]; //Remove last top wall to not overlaps with right wall
        //Top & right connection
        sprites[0].src = Rect() {x = rand.int_range(1, 5) * TILE_SIZE, y = 0, w = 32, h = 112};
        sprites[0].dest = Rect() { x = geometry.x + (0 * TILE_SIZE), y = geometry.y, w = TILE_SIZE, h = 112};
       
        sprites[1].src = Rect() {x = rand.int_range(1, 5) * TILE_SIZE, y = 0, w = 32, h = 112};
        sprites[1].dest = Rect() { x = geometry.x + (1 * TILE_SIZE), y = geometry.y, w = TILE_SIZE, h = 112};
       
        var last_idx = count - 2;
        for(var i = 2; i < last_idx; i++) {
            sprites[i].src = Rect() {x = rand.int_range(1, 5) * TILE_SIZE, y = 0, w = 32, h = 128};
            sprites[i].dest = Rect() { x = geometry.x + (i * TILE_SIZE), y = geometry.y, w = TILE_SIZE, h = 128};
        }
        
        //Top & right connection
        sprites[last_idx].src = Rect() {x = rand.int_range(1, 5) * TILE_SIZE, y = 0, w = 32, h = 112};
        sprites[last_idx].dest = Rect() { x = geometry.x + (last_idx * TILE_SIZE), y = geometry.y, w = TILE_SIZE, h = 112};

        return Structure() {sprites = sprites, box = Rect() { x = geometry.x, y = geometry.y + 32, w = geometry.w, h = 32}};
    }

    public Structure right(int count) {
        Sprite[] sprites = new Sprite[count];
                
        sprites[0].src = Rect() { x = 32, y = 128, w = 32, h = 32};
        sprites[0].dest = Rect() { x = (int) geometry.w - TILE_SIZE, y = geometry.y, w = TILE_SIZE, h = TILE_SIZE};
        
        for(var i = 1; i < count; i++) {
            sprites[i].src  = Rect() {x = 128, y = rand.int_range(4, 6) * TILE_SIZE, w = 64, h = 32};
            sprites[i].dest = Rect() { x = (int) geometry.w - TILE_SIZE * 2, y = (int) geometry.y + (i * TILE_SIZE), w = TILE_SIZE * 2, h = TILE_SIZE};
        }

        return Structure() {sprites = sprites, box = Rect() { x = (int) geometry.w - 32, y = geometry.y, w = 32, h = geometry.h}};
    }

    public Structure bottom(int count) {
        Sprite[] sprites = new Sprite[count - 1]; //Remove last right to not overlap with right wall
        sprites[0].src = Rect() {x = 2 * TILE_SIZE, y = 192, w = 32, h = 32};
        sprites[0].dest = Rect() { x = geometry.x, y = (int) geometry.h - 32, w = 32, h = 32};
        for(var i = 1; i < count - 1; i++) {
            sprites[i].src = Rect() {x = rand.int_range(0, 5) * TILE_SIZE, y = 192, w = 32, h = 32};
            sprites[i].dest = Rect() { x = geometry.x + (i * TILE_SIZE), y = (int) geometry.h - 32, w = 32, h = 32};
        }
        return Structure() {sprites = sprites, box = Rect() { x = (int) geometry.x, y = (int) geometry.h - 32, w = geometry.w, h = 32}};
    }

    public Structure left(int count) {
        Sprite[] sprites = new Sprite[count];

        sprites[0].src = Rect() {x = 0, y = 128, w = 32, h = 32};
        sprites[0].dest = Rect() { x = geometry.x, y = (int) geometry.y, w = 32, h = 32};

        for(var i = 1; i < count - 1; i++) {
            sprites[i].src = Rect() {x = 64, y = rand.int_range(4, 6) * TILE_SIZE, w = 64, h = 32};
            sprites[i].dest = Rect() { x = geometry.x, y = (int) geometry.y + (i * TILE_SIZE), w = 64, h = 32};
        }
     
        return Structure() {sprites = sprites, box = Rect() { x = geometry.x, y = geometry.y, w = 32, h = geometry.h}};
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

    private Structure top_walls;
    private Structure right_walls;
    private Structure bottom_walls;
    private Structure left_walls;

    public Room(int width, int heigth, Renderer renderer) {
        this.width = width;
        this.height = heigth;
        this.geometry = Rect() {x = 0, y = 0, w = width * TILE_SIZE, h = heigth * TILE_SIZE};

        this.renderer = renderer;
        texture = Video.Texture.create_from_surface(this.renderer, sprite);

        Rectangle.fill_rgba(this.renderer, (int16) geometry.x, (int16) geometry.y, (int16) geometry.w, (int16) geometry.h, 91, 80, 118, 255);

        var builder = new RoomBuilder(geometry);

        top_walls = builder.top(width);
        right_walls = builder.right(height);
        bottom_walls = builder.bottom(width);
        left_walls = builder.left(height);
    }

    public Rect[] get_boxes() {
        return {top_walls.box, right_walls.box, bottom_walls.box, left_walls.box};
    }

    public void render() {
        for(var i = 0; i < right_walls.sprites.length ; i++) {
            renderer.copy(texture, right_walls.sprites[i].src, right_walls.sprites[i].dest);
        }
        for(var i = 0; i < bottom_walls.sprites.length ; i++) {
            renderer.copy(texture, bottom_walls.sprites[i].src, bottom_walls.sprites[i].dest);
        }
        for(var i = 0; i < left_walls.sprites.length ; i++) {
            renderer.copy(texture, left_walls.sprites[i].src, left_walls.sprites[i].dest);
        }
        for(var i = 1; i < top_walls.sprites.length; i++) {
            renderer.copy(texture, top_walls.sprites[i].src, top_walls.sprites[i].dest);
        }
    }
}