using SDL;
using SDLGraphics;
using SDLImage;

public class Game : Object {

    private const int SCREEN_WIDTH = 1024;
    private const int SCREEN_HEIGHT = 748;
    private const int SCREEN_BPP = 32;
    private const int DELAY = 10;

    private Video.Window window;
    private Video.Renderer renderer;
    
    private Room room;
    private Player player;
    private Wall[] walls = {};

    private GLib.Rand rand;
    private bool done;

    public Game () {
        this.rand = new GLib.Rand();
    }

    public void run () {
        init_video ();

        while (!done) {
            draw();
            process_events();
            SDL.Timer.delay(DELAY);
        }
    }

    private void init_video () {
        SDL.Video.WindowFlags video_flags = SDL.Video.WindowFlags.OPENGL | SDL.Video.WindowFlags.BORDERLESS;
        Video.Renderer.create_with_window(SCREEN_WIDTH, SCREEN_HEIGHT, video_flags, out window, out renderer);

        player = new Player(renderer);
        room = new Room(20, 20, renderer);

        var color = new Video.PixelFormat(window.get_pixelformat());

        walls[0] = new Wall(renderer, 100, 100);
    }

    private void draw () {
        renderer.clear();

        room.render();
        walls[0].render();
        player.render();

        renderer.present();
    }

    private void process_events () {
        Event event;
        while (Event.poll (out event) == 1) {
            switch (event.type) {
            case EventType.QUIT:
                this.done = true;
                break;
            case EventType.KEYDOWN:
                this.on_keyboard_event (event.key);
                break;
            }
        }
    }

    private void on_keyboard_event (KeyboardEvent event) {
        //window.set_fullscreen(SDL.Video.WindowFlags.FULLSCREEN);
        stdout.printf("key : %d\n", event.keysym.sym);
        switch(event.keysym.sym) {
            case Input.Keycode.z:
                player.move(Direction.UP, room.get_boxes());
                break;
            case Input.Keycode.q:
                player.move(Direction.LEFT, room.get_boxes());
                break;
            case Input.Keycode.d:
                player.move(Direction.RIGHT, room.get_boxes());
                break;
            case Input.Keycode.s:
                player.move(Direction.DOWN, room.get_boxes());
                break;
        }
    }

    public static int main (string[] args) {
        SDL.init (InitFlag.VIDEO);

        var game = new Game();
        game.run();

        SDL.quit();

        return 0;
    }
}

public class Wall {
    public Video.Rect pos;
    private Video.Texture texture;
    private unowned Video.Renderer renderer;
    private SDL.Video.Surface sprite = load_png(new RWops.from_file("./resources/rock.png", "r"));

    public Wall(Video.Renderer renderer, int xx, int yy) {
        this.renderer = renderer;
        texture = Video.Texture.create_from_surface(this.renderer, sprite);
        pos = Video.Rect() { w = 32, h = 32, x = xx, y = yy };
    }

    public void render() {
        renderer.copy(texture, null, pos); 
    }
}

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
    private Video.Rect dest = Video.Rect() { w = 26, h = 43, x = 300, y = 300 };
    private Video.Rect src = Video.Rect() { w = 26, h = 43, x = 3, y = 5 };

    private uint8 speed = 5;

    private uint8 step = 0;

    public Player(Video.Renderer renderer) {
        this.renderer = renderer;
        texture = Video.Texture.create_from_surface(this.renderer, sprite);
    }

    public bool collide_with(Video.Rect rect) {
        return dest.is_intersecting(rect);
    }

    public void move(Direction direction, Video.Rect[] boxes) {
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

       for (var i = 0; i < boxes.length; i++) {
           if (new_dest.is_intersecting(boxes[i])) return;
       }

        dest = new_dest;
    }

    private void inc_step() {
        step = (++step) % 3;
    }

    public void render() {
        renderer.copy(texture, src, dest); 
    }
}