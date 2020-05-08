using SDL;
using SDLGraphics;

public class Game {

    private const int SCREEN_WIDTH = 1024;
    private const int SCREEN_HEIGHT = 748;
    private const int SCREEN_BPP = 32;
    private const int DELAY = 10;

    private Video.Window window;
    private Video.Renderer renderer;
    
    private Room room;
    private Player player;

    private GLib.Rand rand = new GLib.Rand();
    private bool done;

    public void run() {
        init_video();
        while(!done) {
            process_events();
            draw();
            SDL.Timer.delay(DELAY);
        }
    }

    private void init_video() {
        SDL.Video.WindowFlags video_flags = SDL.Video.WindowFlags.OPENGL | SDL.Video.WindowFlags.BORDERLESS;
        Video.Renderer.create_with_window(SCREEN_WIDTH, SCREEN_HEIGHT, video_flags, out window, out renderer);

        player = new Player(renderer);
        room = new Room(20, 20, renderer);

        var color = new Video.PixelFormat(window.get_pixelformat());
    }

    private void draw () {
        renderer.clear();

        room.render();
        player.render();

        renderer.present();
    }

    private void process_events() {
        Event event;
        uint8[] keystate = (uint8[]) Input.Keyboard.get_state();
        if (Event.poll(out event) != 0) {
            if (event.type == EventType.QUIT) this.done = true;

        }
        this.on_keyboard_event(keystate, event.key);
    }

    private void on_keyboard_event (uint8[] keystate, KeyboardEvent event) {
        stdout.printf(
            "Key pressed scancode 0x%08X = %s, keycode 0x%08X = %s\n",
            event.keysym.scancode,
            event.keysym.scancode.get_name(),
            event.keysym.sym,
            event.keysym.sym.get_name()
        );

        if (keystate[Input.Scancode.E] == 1) {
            player.move(Direction.UP, room.get_boxes());
        }
        if (keystate[Input.Scancode.S] == 1) {
            player.move(Direction.LEFT, room.get_boxes());
        }
        if (keystate[Input.Scancode.F] == 1) {
            player.move(Direction.RIGHT, room.get_boxes());
        }
        if (keystate[Input.Scancode.D] == 1) {
            player.move(Direction.DOWN, room.get_boxes());
        }
    }

    public static int main (string[] args) {
        SDL.init(InitFlag.VIDEO);

        var game = new Game();
        game.run();

        SDL.quit();

        return 0;
    }
}