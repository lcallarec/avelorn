using SDL;
using SDL.Video;
using SDLGraphics;
using SDLImage;

public struct Position {
    int x;
    int y;
}

public enum NodeDirection {
    UP,
    RIGHT,
    LEFT,
    DOWN
}

public enum NodeOrientation {
    TOP,
    SIDE,
    BOTTOM
}

public class Node {
    public int x { get; private set;}
    public int y { get; private set;}
    public NodeOrientation orientation { get; private set; }
    public NodeDirection direction { get; private set; }

    public Node(int x, int y, NodeOrientation orientation, NodeDirection direction) {
        this.x = x;
        this.y = y;
        this.orientation = orientation;
        this.direction = direction;
    }

    public bool equals(Node other) {
        return other.x == x && other.y == y;
    }
}

public class Generator {

    private Gee.List<Node?> nodes = new Gee.LinkedList<Node?>();

    private const int TILE_SIZE = 32;
    private GLib.Rand rand = new GLib.Rand();

    Gee.List<Sprite?> right_walls = new Gee.ArrayList<Sprite?>();
    Gee.List<Sprite?> top_right_corner_walls = new Gee.ArrayList<Sprite?>();
    Gee.List<Sprite?> bottom_walls = new Gee.ArrayList<Sprite?>();
    Gee.List<Sprite?> bottom_right_corner_walls = new Gee.ArrayList<Sprite?>();
    Gee.List<Sprite?> bottom_left_corner_walls = new Gee.ArrayList<Sprite?>();
    Gee.List<Sprite?> left_walls = new Gee.ArrayList<Sprite?>();
    Gee.List<Sprite?> top_left_corner_walls = new Gee.ArrayList<Sprite?>();
    Gee.List<Sprite?> top_walls = new Gee.ArrayList<Sprite?>();

    Gee.List<Rect?> boxes = new Gee.ArrayList<Rect?>();

    private int x_origin;
    private int y_origin;

    private Map map;

    public Generator(Map map, int x, int y) {
        x_origin = x;
        y_origin = y;
        this.map = map;
    }

    public void generate() {
        //first top left node
        Node first_node = new Node(0, 0, NodeOrientation.TOP, NodeDirection.RIGHT);

        add_top_left_corner_walls(0, 0);

        Node current_node = first_node;
        Node? last_node = null;

        nodes.add(first_node);

        debug ("map width %d\n", map.width);
        debug ("map height %d\n", map.height);

        var i = 0;
        while(true) {
            i++;
            if (i > 300) break;
            current_node = move_to_next_corner(current_node);
            debug ("NODE found at %d,%d\n", current_node.x, current_node.y);
            nodes.add(current_node);
            if (current_node.equals(first_node)) {
                debug ("Visited the whole dungeon\n");
                break;
            }
        }

        create_boxes();
    }

    private void create_boxes() {
        Node? prev_node = null;
        nodes.foreach((node) => {
            if (prev_node == null) {
                prev_node = node;
            }
            if (node.orientation != prev_node.orientation) {
                debug("New node at %d, %d\n", node.x, node.y);
                
                var x = prev_node.x * TILE_SIZE;
                var y = prev_node.y * TILE_SIZE;

                var w = 0;
                var h = 0;
                
                if (prev_node.orientation == NodeOrientation.SIDE) {
                    debug("SIDE\n");
                    w = TILE_SIZE;
                    if (prev_node.direction == NodeDirection.DOWN) {
                        debug(" -> DOWN\n");
                        h = (node.y - prev_node.y) * TILE_SIZE;
                    } else if(prev_node.direction == NodeDirection.UP) {
                        debug(" -> UP\n");
                        h = (prev_node.y - node.y) * TILE_SIZE;
                        x = node.x * TILE_SIZE;
                        y = (node.y + 1) * TILE_SIZE;
                    }
                } else {
                    debug("TOP or BOTTOM\n");
                    h = TILE_SIZE;
                    if (prev_node.orientation == TOP) {
                        debug("TOP\n");
                        h += TILE_SIZE;
                    }

                    if (prev_node.direction == NodeDirection.RIGHT) {
                        debug(" -> RIGHT\n");
                        w = (node.x - prev_node.x) * TILE_SIZE;
                    } 
                    if (prev_node.direction == NodeDirection.LEFT) {
                        debug(" -> LEFT\n");
                        w = (prev_node.x - node.x) * TILE_SIZE;
                        x = (node.x + 1) * TILE_SIZE;
                        y = node.y * TILE_SIZE;
                    }
                  
                }

                var box = Rect() {
                    x = x + (x_origin * TILE_SIZE),
                    y = y + (y_origin * TILE_SIZE),
                    w = w,
                    h = h                    
                };
                debug("Rect.x = %d\n", (int) box.x);
                debug("Rect.y = %d\n", (int) box.y);
                debug("Rect.w = %d\n", (int) box.w);
                debug("Rect.h = %d\n", (int) box.h);
                boxes.add(box);
                prev_node = node;
            }
            
            return true;
        });
    }

    public Gee.List<Rect?> get_boxes() {
        return boxes;
    }

    public Gee.List<Sprite?> get_sprites() {
        var sprites = new Gee.ArrayList<Sprite?>();

        sprites.add_all(right_walls);
        sprites.add_all(bottom_left_corner_walls);
        sprites.add_all(bottom_walls);
        sprites.add_all(bottom_right_corner_walls);
        sprites.add_all(left_walls);
        sprites.add_all(top_left_corner_walls);
        sprites.add_all(top_walls);
        sprites.add_all(top_right_corner_walls);

        return sprites;
    }

    protected Node move_to_next_corner(Node node) {
        Node found_node = node;
        if (node.direction == NodeDirection.RIGHT) {
            debug("Start seek at %d,%d while col < %d\n", node.x + 1, node.y, map.width);

            for (var col = node.x + 1; col < map.width; col++) {
                debug ("RIGHT : current char at %d,%d: %s \n", col, node.y, map.get_string_from_coord(node.y, col));
                if (map.get_string_from_coord(node.y, col) == "─") {
                    debug ("Straight wall to RIGHT\n");
                    add_top_walls(col, node.y);
                } else if (map.get_string_from_coord(node.y, col) == "┐") {
                    debug ("Found corner : goes DOWN\n");
                    add_top_right_corner_walls(col, node.y);
                    return new Node(col, node.y, NodeOrientation.SIDE, NodeDirection.DOWN);
                } else if (map.get_string_from_coord(node.y, col) == "┘") {
                    debug ("Found corner : goes UP\n");
                    add_top_left_corner_walls(col, node.y);
                    return new Node(col, node.y, NodeOrientation.SIDE, NodeDirection.UP);
                }
            }
        }

        if (node.direction == NodeDirection.DOWN) {
            for (var row = node.y + 1; row < map.height; row++) {
                debug ("DOWN : current char at %d,%d: %s \n", node.x, row, map.get_string_from_coord(row, node.x));
                if (map.get_string_from_coord(row, node.x) == "│") {
                    debug ("Straight wall to DOWN\n");
                    add_right_walls(node.x, row);
                } else if (map.get_string_from_coord(row, node.x) == "└") {
                    debug ("Found corner : goes RIGHT (from DOWN)\n");
                    add_bottom_right_corner_walls(node.x, row);
                    return new Node(node.x, row, NodeOrientation.TOP, NodeDirection.RIGHT);
                } else if (map.get_string_from_coord(row, node.x) == "┘") {
                    debug ("Found corner : goes LEFT\n");
                    add_bottom_left_corner_walls(node.x, row);
                    return new Node(node.x, row, NodeOrientation.BOTTOM, NodeDirection.LEFT);
                }
            }
        }

        if (node.direction == NodeDirection.LEFT) {
            debug ("ENTER LEFT\n");
            for (var col = node.x - 1; col >= 0; col--) {
                debug ("LEFT : current char at %d,%d: %s \n", col, node.y, map.get_string_from_coord(node.y, col));
                if (map.get_string_from_coord(node.y, col) == "─") {
                    debug ("Straight wall to LEFT\n");
                    add_bottom_walls(col, node.y);
                } else if (map.get_string_from_coord(node.y, col) == "└") {
                    add_bottom_right_corner_walls(col, node.y);
                    debug ("Found corner : goes UP\n");
                    return new Node(col, node.y, NodeOrientation.SIDE, NodeDirection.UP);
                } else if (map.get_string_from_coord(node.y, col) == "┌") {
                    debug ("Found corner : goes DOWN\n");
                    add_bottom_left_corner_walls(col, node.y);
                    return new Node(col, node.y, NodeOrientation.SIDE, NodeDirection.DOWN);
                }
            }
        }

        if (node.direction == NodeDirection.UP) {
            debug ("ENTER UP\n");
            for (var row = node.y - 1; row >= 0; row--) {
                debug ("UP : current char at %d,%d: %s \n", node.x, row, map.get_string_from_coord(row, node.x));
                if (map.get_string_from_coord(row, node.x) == "│") {
                    debug ("Straight wall to UP\n");
                    add_left_walls(node.x, row);
                } else if (map.get_string_from_coord(row, node.x) == "┌") {
                    debug ("Found corner : goes RIGHT (from UP)\n");
                    return new Node(node.x, row, NodeOrientation.TOP, NodeDirection.RIGHT);
                } else if (map.get_string_from_coord(row, node.x) == "┐") {
                    debug ("Found corner : goes LEFT\n");
                    return new Node(node.x, row, NodeOrientation.SIDE, NodeDirection.LEFT);
                }
            }
        }
        
        return found_node;
    }

    protected void add_right_walls(int x, int y) {
        Sprite sprite = Sprite() {
            src  = Rect() {x = 128, y = rand.int_range(4, 6) * TILE_SIZE, w = 64, h = 32},
            dest = Rect() { x = (x_origin + x - 1) * TILE_SIZE, y = (y_origin + y) * TILE_SIZE, w = TILE_SIZE * 2, h = TILE_SIZE}
        };

        right_walls.add(sprite);
    }

    protected void add_bottom_walls(int x, int y) {
        Sprite sprite = Sprite() {
            src = Rect() {x = rand.int_range(1, 5) * TILE_SIZE, y = TILE_SIZE * 7, w = 32, h = 32},
            dest = Rect() { x = (x_origin + x) * TILE_SIZE, y = (int) (y_origin + y) * TILE_SIZE, w = 32, h = 32}
        };

        bottom_walls.add(sprite);
    }

    protected void add_left_walls(int x, int y) {
        Sprite sprite = Sprite() {
            src = Rect() {x = 64, y = rand.int_range(4, 6) * TILE_SIZE, w = 64, h = 32},
            dest = Rect() { x = (x_origin + x) * TILE_SIZE, y = (y_origin + y) * TILE_SIZE, w = 64, h = 32}
        };

        left_walls.add(sprite);
    }

    protected void add_top_walls(int x, int y) {
        Sprite sprite = Sprite() {
            src = Rect() {x = rand.int_range(1, 5) * TILE_SIZE, y = 0, w = TILE_SIZE, h = TILE_SIZE * 4},
            dest = Rect() { x = (x_origin + x) * TILE_SIZE, y = (y_origin + y) * TILE_SIZE, w = TILE_SIZE, h = TILE_SIZE * 4}
        };

        top_walls.add(sprite);
    }

    protected void add_bottom_right_corner_walls(int x, int y) {
        Sprite sprite = Sprite() {
            src = Rect() {x = 1 * TILE_SIZE, y = TILE_SIZE * 7, w = 32, h = 32},
            dest = Rect() { x = (x_origin + x) * TILE_SIZE, y = (int) (y_origin + y) * TILE_SIZE, w = 32, h = 32}
        };
    
        bottom_right_corner_walls.add(sprite);
    }

    protected void add_bottom_left_corner_walls(int x, int y) {
        Sprite sprite = Sprite() {
            src = Rect() {x = 64, y = 5 * TILE_SIZE, w = 32, h = 32},
            dest = Rect() { x = (x_origin + x) * TILE_SIZE, y = (y_origin + y) * TILE_SIZE, w = 32, h = 32}
        };

        bottom_left_corner_walls.add(sprite);
    }

    protected void add_top_left_corner_walls(int x, int y) {
        Sprite sprite = Sprite() {
            src = Rect() {x = 64, y = rand.int_range(4, 6) * TILE_SIZE, w = 64, h = 32},
            dest = Rect() { x = (x_origin + x) * TILE_SIZE, y = (y_origin + y) * TILE_SIZE, w = 64, h = 32}
        };

        top_left_corner_walls.add(sprite);
    }

    protected void add_top_right_corner_walls(int x, int y) {
        Sprite sprite = Sprite() {
            src = Rect() {x =  TILE_SIZE, y = 128, w = TILE_SIZE, h = TILE_SIZE},
            dest = Rect() { x = (x_origin + x) * TILE_SIZE, y = (y_origin + y) * TILE_SIZE, w = TILE_SIZE, h = TILE_SIZE}
        };
    
        top_right_corner_walls.add(sprite);
    }
}