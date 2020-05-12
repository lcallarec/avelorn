using SDL;
using SDL.Video;
using SDLGraphics;
using SDLImage;

public struct Position {
    int x;
    int y;
}

public enum CornerOrientation {
    NW,
    NE,
    SE,
    SW;
}

public enum SegmentOrientation {
    TOP,
    RIGHT,
    BOTTOM,
    LEFT
}

public enum CornerDirection {
    UP,
    RIGHT,
    LEFT,
    DOWN
}

public enum CornerSpace {
    OUTER,
    INNER
}

[Flags]
public enum CornerFlag {
    NW,
    NE,
    SE,
    SW,
    UP,
    RIGHT,
    LEFT,
    DOWN
}

public class Corner {
    public int x { get; private set;}
    public int y { get; private set;}

    public CornerFlag flag { get; private set;}
    public CornerDirection direction { get; private set;}

    public Segment segment;
    public Corner next { get; private set;}

    public Corner(CornerFlag flag, int x, int y) {
        this.flag = flag;
        this.x = x;
        this.y = y;
    }

    public void link(Corner corner) {
        next = corner;
        close(next);
    }

    public void close(Corner next) {
        segment = new Segment(this, next);
    }

    public bool equals(Corner other) {
        return other.x == x && other.y == y;
    }
}

public class Segment {
    public int length { get; private set;}
    public SegmentOrientation orientation { get; private set;}

    public Segment(Corner from, Corner to) {
        if (CornerFlag.RIGHT in from.flag) {
            orientation = SegmentOrientation.TOP;
            length = to.x - from.x;
        }
        if (CornerFlag.DOWN in from.flag) {
            orientation = SegmentOrientation.RIGHT;
            length = to.y - from.y;
        }
        if (CornerFlag.LEFT in from.flag) {
            orientation = SegmentOrientation.BOTTOM;
            length = from.x - to.x;
        }
        if (CornerFlag.UP in from.flag) {
            orientation = SegmentOrientation.LEFT;
            length = from.y - to.y;
        }
    }
}

public class Edge {
    private Corner first_corner = null;
    private Corner current_corner = null;
    private bool closed = false;

    public int corner_size { get; private set; default = 0;}

    public void add_corner(Corner corner) {
        if (first_corner == null) {
            first_corner = corner;
        } else {
            if (corner.equals(first_corner)) {
                current_corner.link(corner);
                closed = true;
                return;
            }
            current_corner.link(corner);
        }
        current_corner = corner;
        corner_size++;
    }

    public bool has_next() {
        return current().segment != null;
    }

    public Corner current() {
        return current_corner;
    }

    public void next() {
        var next = current_corner.next;
        current_corner = next;
    }

    public Corner first() {
        return first_corner;
    }

    public void reset() {
        current_corner = first_corner;
    }

    public bool is_closed() {
        return closed;
    }
}

public class Generator {

    private Edge edge = new Edge();

    private const int TILE_SIZE = 32;
    private GLib.Rand rand = new GLib.Rand();

    Gee.List<Rect?> boxes = new Gee.ArrayList<Rect?>();
    Gee.List<Position?> outlines = new Gee.ArrayList<Position?>();
    Gee.List<Sprite?> sprites = new Gee.ArrayList<Sprite?>();

    private Position origin;

    private Map map;


    public Generator(Map map, Position origin) {
        this.origin = origin;
        this.map = map;
    }

    public Edge get_edge() {
        return edge;
    }

    public Gee.List<Position?> get_outlines() {
        return outlines;
    }

    public void generate() {
        var first_corner = new Corner(CornerFlag.NW | CornerFlag.RIGHT, 0, 0);
        edge.add_corner(first_corner);
        stdout.printf("Start generation\n");

        while (!edge.is_closed()) {
            stdout.printf("Loop\n");
            var corner = next_corner();
            debug("Found next corner at %d,%d", corner.x, corner.y);
            edge.add_corner(corner);
        }   

        create_boxes();
        create_sprites();
        create_outlines();
    }   

    private Corner next_corner() {
        var corner = edge.current();
        if (CornerFlag.RIGHT in corner.flag) {
            debug("Enter CornerOrientation.NW\n");
            for (var col = corner.x + 1; col < map.width; col++) {
                debug ("RIGHT : current char at %d,%d: %s \n", col, corner.y, map.get_string_from_coord(corner.y, col));
                if (map.get_string_from_coord(corner.y, col) == "┐") {
                    debug ("Found next corner : goes DOWN\n");
                    return new Corner(CornerFlag.NE | CornerFlag.DOWN, col, corner.y);
                } else if (map.get_string_from_coord(corner.y, col) == "┘") {
                    debug ("Found corner : goes UP\n");
                    return new Corner(CornerFlag.SE | CornerFlag.UP, col, corner.y);
                }
            }
        }

        if (CornerFlag.DOWN in corner.flag) {
            debug("CornerOrientation.NE\n");
            for (var row = corner.y + 1; row < map.height; row++) {
                debug ("DOWN : current char at %d,%d: %s \n", corner.x, row, map.get_string_from_coord(row, corner.x));
                if (map.get_string_from_coord(row, corner.x) == "└") {
                    debug ("Found corner : goes RIGHT (from DOWN)\n");
                    return new Corner(CornerFlag.SW | CornerFlag.RIGHT, corner.x, row);
                } else if (map.get_string_from_coord(row, corner.x) == "┘") {
                    debug ("Found corner : goes LEFT\n");
                    return new Corner(CornerFlag.SE | CornerFlag.LEFT, corner.x, row);
                }
            }
        }

        if (CornerFlag.LEFT in corner.flag) {
            debug("Enter CornerOrientation.SE\n");
            for (var col = corner.x - 1; col >= 0; col--) {
                debug ("LEFT : current char at %d,%d: %s \n", col, corner.y, map.get_string_from_coord(corner.y, col));
                if (map.get_string_from_coord(corner.y, col) == "└") {
                    debug ("Found corner : goes UP\n");
                    return new Corner(CornerFlag.SW | CornerFlag.UP, col, corner.y);
                } else if (map.get_string_from_coord(corner.y, col) == "┌") {
                    debug ("Found corner : goes DOWN\n");
                    return new Corner(CornerFlag.NW | CornerFlag.DOWN, col, corner.y);
                }
            }
        }

        if (corner.direction == CornerDirection.UP) {
            debug("Enter CornerOrientation.SW\n");
            for (var row = corner.y - 1; row >= 0; row--) {
                debug ("UP : current char at %d,%d: %s \n", corner.x, row, map.get_string_from_coord(row, corner.x));
                if (map.get_string_from_coord(row, corner.x) == "┌") {
                    debug ("Found corner : goes RIGHT (from UP)\n");
                    return new Corner(CornerFlag.NW | CornerFlag.RIGHT, corner.x, row);
                } else if (map.get_string_from_coord(row, corner.x) == "┐") {
                    debug ("Found corner : goes LEFT\n");
                    return new Corner(CornerFlag.NE | CornerFlag.LEFT, corner.x, row);
                }
            }
        }

        return corner;
    }

    private void create_boxes() {
        edge.reset();
        while(edge.has_next()) {
            var corner = edge.current();

            int x = 0;
            int y = 0;
            int w = 0;
            int h = 0;
            if (CornerFlag.RIGHT in corner.flag) {
                debug("At RIGHT ");
                x = corner.x;
                y = corner.y;
                w = corner.segment.length;
                h = corner.segment.orientation == SegmentOrientation.TOP ? 2 : 1;
            }
            if (CornerFlag.DOWN in corner.flag) {
                debug("At DOWN ");
                x = corner.x;
                y = corner.y;
                w = 1;
                h = corner.segment.length;
            }
            if (CornerFlag.LEFT in corner.flag) {
                debug("At LEFT ");
                var next = corner.next; 
                x = next.x;
                y = next.y;
                w = corner.segment.length;
                h = 1;
            }
            if (CornerFlag.UP in corner.flag) {
                debug("At UP ");
                var next = corner.next; 
                x = next.x;
                y = next.y;
                w = 1;
                h = corner.segment.length;
            }
            var box = Rect() { x = (x + origin.x) * TILE_SIZE, y = (y + origin.y) * TILE_SIZE, w = w * TILE_SIZE, h = h * TILE_SIZE};
            debug("create box at %d, %d, %d, %d\n", box.x, box.y, (int) box.w, (int) box.h);
            
            boxes.add(box);
            edge.next();
        }
    }

    private void create_outlines() {
        edge.reset();
        while(edge.has_next()) {
            var corner = edge.current();
            var point = Position() { x = (corner.x + origin.x) * TILE_SIZE, y = (corner.y + origin.y) * TILE_SIZE};
            outlines.add(point);
            edge.next();
        }
    }

    public void create_sprites() {
        edge.reset();
        var sg = new SpriteGenerator(origin);
        debug("Start create sprite loop\n");
        while(edge.has_next()) {
            debug("Create sprites loop\n");
            var corner = edge.current(); 
            sprites.add_all(sg.generate(corner));
            edge.next();
        }

        sprites.sort((a, b) => {
            return a.priority - b.priority;
        });
    }

    public Gee.List<Rect?> get_boxes() {
        return boxes;
    }

    public Gee.List<Sprite?> get_sprites() {
        return sprites;
    }
}