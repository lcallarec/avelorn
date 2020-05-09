using SDL;
using SDL.Video;
using SDLGraphics;
using SDLImage;

private const unichar[,] map = {
    {'┌', '─', '─', '─', '─', '─', '─', '─', '┐', ' ', ' ', ' '},
    {'│', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '│', ' ', ' ', ' '},
    {'│', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '└', '─', '┐', ' '},
    {'│', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '│', ' '},
    {'│', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '│', ' '},
    {'│', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '│', ' '},
    {'│', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '│', ' '},
    {'│', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '┌', '─', '┘', ' '},
    {'└', '─', '─', '─', '─', '─', '─', '─', '┘', ' ', ',', ' '}
};

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

public class Node {

    private Node[] linked;
    public Position position { get; private set; }
    public NodeDirection direction { get; private set; }

    public Node(Position position, NodeDirection direction) {
        this.position = position;
        this.direction = direction;
    }

    public bool equals(Node other) {
        return other.position == position;
    }
}

public class Generator {

    private Node[] nodes;

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

    private int x_origin;
    private int y_origin;

    public Generator(int x, int y) {
        x_origin = x;
        y_origin = y;
    }

    public void generate() {
        //first top left node
        Node first_node = new Node({0, 0}, NodeDirection.RIGHT);

        add_top_left_corner_walls(0, 0);

        Node current_node = first_node;
        Node? last_node = null;

        nodes += first_node;

        stdout.printf ("map width %d\n", map.length[1]);
        stdout.printf ("map height %d\n", map.length[0]);
        var i = 0;
        while(true) {
            i++;
            if (i > 300) break;
            current_node = move_to_next_corner(current_node);
            stdout.printf ("NODE found at %d,%d\n", current_node.position.x, current_node.position.y);
            if (current_node.equals(first_node)) break;
            nodes += current_node;
        }
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
            stdout.printf("Start seek at %d,%d while col < %d\n", node.position.x + 1, node.position.y, map.length[0]);

            for (var col = node.position.x + 1; col < map.length[1]; col++) {
                stdout.printf ("RIGHT : current char at %d,%d: %s \n", col, node.position.y, map[node.position.y, col].to_string());
                if (map[node.position.y, col].to_string() == "─") {
                    stdout.printf ("Straight wall to RIGHT\n");
                    add_top_walls(col, node.position.y);
                } else if (map[node.position.y, col].to_string() == "┐") {
                    stdout.printf ("Found corner : goes DOWN\n");
                    add_top_right_corner_walls(col, node.position.y);
                    return new Node({col, node.position.y}, NodeDirection.DOWN);
                } else if (map[node.position.y, col].to_string() == "┘") {
                    stdout.printf ("Found corner : goes UP\n");
                    add_top_left_corner_walls(col, node.position.y);
                    return new Node({col, node.position.y}, NodeDirection.UP);
                }
            }
        }

        if (node.direction == NodeDirection.DOWN) {
            for (var row = node.position.y + 1; row < map.length[0]; row++) {
                stdout.printf ("DOWN : current char at %d,%d: %s \n", node.position.x, row, map[row, node.position.x].to_string());
                if (map[row, node.position.x].to_string() == "│") {
                    stdout.printf ("Straight wall to DOWN\n");
                    add_right_walls(node.position.x, row);
                } else if (map[row, node.position.x].to_string() == "└") {
                    stdout.printf ("Found corner : goes RIGHT (from DOWN)\n");
                    add_bottom_right_corner_walls(node.position.x, row);
                    return new Node({node.position.x, row}, NodeDirection.RIGHT);
                } else if (map[row, node.position.x].to_string() == "┘") {
                    stdout.printf ("Found corner : goes LEFT\n");
                    add_bottom_left_corner_walls(node.position.x, row);
                    return new Node({node.position.x, row}, NodeDirection.LEFT);
                }
            }
        }

        if (node.direction == NodeDirection.LEFT) {
            stdout.printf ("ENTER LEFT\n");
            for (var col = node.position.x - 1; col >= 0; col--) {
                stdout.printf ("LEFT : current char at %d,%d: %s \n", col, node.position.y, map[node.position.y, col].to_string());
                if (map[node.position.y, col].to_string() == "─") {
                    stdout.printf ("Straight wall to LEFT\n");
                    add_bottom_walls(col, node.position.y);
                } else if (map[node.position.y, col].to_string() == "└") {
                    add_bottom_right_corner_walls(col, node.position.y);
                    stdout.printf ("Found corner : goes UP\n");
                    return new Node({col, node.position.y}, NodeDirection.UP);
                } else if (map[node.position.y, col].to_string() == "┌") {
                    stdout.printf ("Found corner : goes DOWN\n");
                    add_bottom_left_corner_walls(col, node.position.y);
                    return new Node({col, node.position.y}, NodeDirection.DOWN);
                }
            }
        }

        if (node.direction == NodeDirection.UP) {
            stdout.printf ("ENTER UP\n");
            for (var row = node.position.y - 1; row >= 0; row--) {
                stdout.printf ("DOWN : current char at %d,%d: %s \n", node.position.x, row, map[row, node.position.x].to_string());
                if (map[row, node.position.x].to_string() == "│") {
                    stdout.printf ("Straight wall to UP\n");
                    add_left_walls(node.position.x, row);
                } else if (map[row, node.position.x].to_string() == "┌") {
                    stdout.printf ("Found corner : goes RIGHT (from UP)\n");
                    return new Node({node.position.x, row}, NodeDirection.RIGHT);
                } else if (map[row, node.position.x].to_string() == "┐") {
                    stdout.printf ("Found corner : goes LEFT\n");
                    return new Node({node.position.x, row}, NodeDirection.LEFT);
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