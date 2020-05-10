using SDL;
using SDLImage;

public enum Direction {
    UP,
    DOWN,
    LEFT,
    RIGHT
}

public class Player {
    private Video.Texture texture;
    private unowned Video.Renderer renderer;
    private SDL.Video.Surface sprite = load_png(new RWops.from_file("./resources/vx_chara03_d.png", "r"));
    private Video.Rect dest = Video.Rect() { w = 26, h = 43, x = 200, y = 200 };
    private Video.Rect src = Video.Rect() { w = 26, h = 43, x = 3, y = 5 };

    private uint8 speed = 2;
    private uint8 step = 0;

    private int frame = 0;


    public Player(Video.Renderer renderer) {
        this.renderer = renderer;
        texture = Video.Texture.create_from_surface(this.renderer, sprite);
    }

    public bool collide_with(Video.Rect rect) {
        return dest.is_intersecting(rect);
    }

    public void move(Direction direction, Gee.List<Video.Rect?> boxes) {
        inc_step();
        src.x = (29 * step) + (3 * step + 1);
        
        Video.Rect new_dest = dest;

        switch(direction) {
            case Direction.UP:
                new_dest.y -= speed;
                src.y = 48 * 3;
                break;
            case Direction.DOWN:
                new_dest.y += speed;
                src.y = 48 * 0;
                break;
            case Direction.LEFT:
                new_dest.x -= speed;
                src.y = 48 * 1;
                break;
            case Direction.RIGHT:
                new_dest.x += speed;
                src.y = 48 * 2;
                break;
        }


        foreach(var box in boxes) {
            debug("check if %d,%d,%d,%d collide with %d,%d,%d,%d\n", (int) new_dest.x,  (int) new_dest.y,  (int) new_dest.w,  (int) new_dest.h,  (int) box.x,  (int) box.y,  (int) box.w,  (int) box.h);
            if (new_dest.is_intersecting(box)) return;
        }

        dest = new_dest;
    }

    private void inc_step() {
        if (++frame % 4 == 1) {
            step = (++step) % 3;
        }
    }

    public void render() {
        renderer.copy(texture, src, dest); 
    }
}