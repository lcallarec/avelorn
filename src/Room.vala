using SDL;
using SDL.Video;
using SDLGraphics;
using SDLImage;

public class Room {
    private Video.Texture texture;
    private unowned Video.Renderer renderer;
    private SDL.Video.Surface sprite = load_png(new RWops.from_file("./resources/dungeon.png", "r"));
    
    private int width;
    private int height;

    private Rect geometry;

    private const int TILE_SIZE = 32;

    private Sprite[] floor; 

    private Torch torch;

    private Gee.List<Sprite?> sprites;
    private Gee.List<Rect?> boxes;
    private Gee.List<Position?> outlines;


    public Room(int width, int heigth, Renderer renderer) {
        this.width = width;
        this.height = heigth;
        this.geometry = Rect() {x = 0, y = 0, w = width * TILE_SIZE, h = heigth * TILE_SIZE};

        this.renderer = renderer;
        texture = Video.Texture.create_from_surface(this.renderer, sprite);

        torch = new Torch(renderer);

        unichar[,] map = {
            {'┌', '─', '─', '─', '─', '─', '─', '─', '┐', ' ', ' '},
            {'│', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '│', ' ', ' '},
            {'│', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '└', '─', '┐'},
            {'│', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '│'},
            {'│', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '┌', '─', '┘'},
            {'└', '─', '─', '─', '┐', ' ', '┌', '─', '┘', ' ', ','},
            {' ', ' ', ' ', ' ', '│', ' ', '│', ' ', ' ', ' ', ','},
            {' ', ' ', ' ', ' ', '└', '─', '┘', ' ', ' ', ' ', ','}
        };
        var generator = new Generator(new ArrayMapReader(map), {2, 2});
        generator.generate();
        sprites = generator.get_sprites();
        boxes = generator.get_boxes();
        outlines = generator.get_outlines();
    }

    public Gee.List<Rect?> get_boxes() {
        return boxes;
    }

    public void render() {

        int16[] vx = new int16[outlines.size];
        int16[] vy = new int16[outlines.size];
        var i = 0;
        outlines.foreach((point) => {
            vx[i] = (int16) point.x;
            vy[i] = (int16) point.y;
            i++;
            return true;
        });
        Polygon.fill_rgba(renderer, vx, vy, outlines.size, 91, 80, 118, 255);

        sprites.foreach((sprite) => {
            renderer.copy(texture, sprite.src, sprite.dest);
            return true;
        });

        var r = 0;
        boxes.foreach((box) => {
            renderer.set_draw_color(r, 80, 118, 255);
            r += 50;
            renderer.draw_rect(box);
            return true;
        });
        


        //torch.render();
    }
}

public class Torch {
    
    private Video.Texture texture;
    private unowned Video.Renderer renderer;
    private SDL.Video.Surface sprite = load_png(new RWops.from_file("./resources/torch.png", "r"));
    private int step = 0;
    private int frame = 0;

    public Torch(Renderer renderer) {
        this.renderer = renderer;
        texture = Video.Texture.create_from_surface(this.renderer, sprite);
    }

    public void render() {
        if (++frame % 8 == 1) {
            step = (++step) % 4;
        }
        renderer.copy(
            texture,
            Rect() {x = 24 * step, y = 0, w = 24, h = 42},
            Rect() {x = 64, y = 64, w = 24, h = 42 }
        );
    }
}