using SDL;
using SDL.Video;

public class SpriteGenerator {

    private Position origin;
    private const int TILE_SIZE = 32;
    private GLib.Rand rand = new GLib.Rand();

    public SpriteGenerator(Position origin) {
        this.origin = origin;
    }

    public Gee.List<Sprite?> generate(Corner corner) {

        Gee.List<Sprite?> sprites = new Gee.ArrayList<Sprite?>();

        if (CornerFlag.RIGHT in corner.flag) {
            if (CornerFlag.NW in corner.flag) {
                debug("CornerFlag.RIGHT  + CornerFlag.NW for corner x=%d y=%d\n", corner.x, corner.y);
                sprites.add_all(top_walls(corner.x, corner.y, corner.segment.length));
                sprites.add(from_NW_Inner(corner));
            }
            if (CornerFlag.SW in corner.flag) {
                debug("CornerFlag.RIGHT  + CornerFlag.SW\n");
                sprites.add(from_SW_Outer(corner));
                sprites.add_all(top_walls(corner.x, corner.y, corner.segment.length));
            }
        }
        if (CornerFlag.DOWN in corner.flag) {
            if (CornerFlag.NE in corner.flag) {
                debug("CornerFlag.DOWN  + CornerFlag.NE\n");
                sprites.add(from_NE_Inner(corner));
                sprites.add_all(right_walls(corner.x, corner.y, corner.segment.length));
            }
            if (CornerFlag.NW in corner.flag) {
                debug("CornerFlag.DOWN  + CornerFlag.NW\n");
                sprites.add(from_NW_Outer(corner));
                sprites.add_all(right_walls(corner.x, corner.y, corner.segment.length));
            }
        }
        if (CornerFlag.LEFT in corner.flag) {
            if (CornerFlag.SE in corner.flag) {
                debug("CornerFlag.LEFT  + CornerFlag.SE\n");
                sprites.add(from_SE_Inner(corner));
                sprites.add_all(bottom_walls(corner.next.x, corner.next.y, corner.segment.length));
            }
            if (CornerFlag.NE in corner.flag) {
                debug("CornerFlag.LEFT  + CornerFlag.NE\n");
                sprites.add(from_NE_Outer(corner));
                sprites.add_all(bottom_walls(corner.next.x, corner.next.y, corner.segment.length));
            }
        }
        if (CornerFlag.UP in corner.flag) {
            if (CornerFlag.SW in corner.flag) {
                debug("CornerFlag.UP  + CornerFlag.SW\n");
                sprites.add_all(left_walls(corner.next.x, corner.next.y, corner.segment.length));
                sprites.add(from_SW_Inner(corner));
            }
            if (CornerFlag.SE in corner.flag) {
                debug("CornerFlag.UP  + CornerFlag.SE\n");
                sprites.add(from_SE_Outer(corner));
            }
        }

        return sprites;
    }

    private Sprite from_NW_Inner(Corner corner) {
        Sprite sprite = Sprite() {
            priority = Priority.N, // N to override top wall continuation
            src = Rect() {x = 0, y = TILE_SIZE * 7, w = 64, h = 128},
            dest = Rect() { x = (origin.x + corner.x) * TILE_SIZE, y = (origin.y + corner.y) * TILE_SIZE, w = 64, h = 128}
        };
        return sprite;
    }

    private Sprite from_NW_Outer(Corner corner) {
        Sprite sprite = Sprite() {
            priority = Priority.NW,
            src = Rect() {x = 64, y = 0, w = 32, h = 32},
            dest = Rect() { x = (origin.x + corner.x) * TILE_SIZE, y = (origin.y + corner.y) * TILE_SIZE, w = 32, h = 32}
        };
        return sprite;
    }

    private Sprite from_NE_Inner(Corner corner) {
        Sprite sprite = Sprite() {
            priority = Priority.H, //To override top wall
            src = Rect() {x = TILE_SIZE * 2, y = TILE_SIZE * 7, w = 64, h = 128},
            dest = Rect() { x = (origin.x + corner.x - 1) * TILE_SIZE, y = (origin.y + corner.y) * TILE_SIZE, w = 64, h = 128}
        };
        return sprite;
    }

    private Sprite from_NE_Outer(Corner corner) {
        Sprite sprite = Sprite() {
            priority = Priority.NE,
            src = Rect() {x = TILE_SIZE * 7, y = 0, w = 32, h = 32},
            dest = Rect() { x = (origin.x + corner.x) * TILE_SIZE, y = (origin.y + corner.y) * TILE_SIZE, w = 32, h = 32}
        };
        return sprite;
    }

    private Sprite from_SE_Inner(Corner corner) {
        Sprite sprite = Sprite() {
            priority = Priority.SE,
            src = Rect() {x = TILE_SIZE * 7, y = TILE_SIZE * 3, w = 32, h = 32},
            dest = Rect() { x = (origin.x + corner.x) * TILE_SIZE, y = (origin.y + corner.y) * TILE_SIZE, w = 32, h = 32}
        };
        return sprite;
    }

    private Sprite from_SE_Outer(Corner corner) {
        Sprite sprite = Sprite() {
            priority = Priority.SE,
            src = Rect() {x = 64, y = 0, w = 32, h = 32},
            dest = Rect() { x = (origin.x + corner.x) * TILE_SIZE, y = (origin.y + corner.y) * TILE_SIZE, w = 32, h = 32}
        };
        return sprite;
    }

    private Sprite from_SW_Inner(Corner corner) {
        Sprite sprite = Sprite() {
            priority = Priority.SW,
            src = Rect() {x = 64, y = 0, w = 32, h = 32},
            dest = Rect() { x = (origin.x + corner.x) * TILE_SIZE, y = (origin.y + corner.y) * TILE_SIZE, w = 32, h = 32}
        };
        return sprite;
    }

    private Sprite from_SW_Outer(Corner corner) {
        Sprite sprite = Sprite() {
            priority = Priority.SW,
            src = Rect() {x = 0, y = TILE_SIZE * 3, w = TILE_SIZE * 3, h = TILE_SIZE * 4},
            dest = Rect() { x = (origin.x + corner.x - 2) * TILE_SIZE, y = (origin.y + corner.y) * TILE_SIZE, w = TILE_SIZE * 3, h = TILE_SIZE * 4}
        };
        return sprite;
    }

    private Gee.List<Sprite?> top_walls(int x, int y, int length) {
        Gee.List<Sprite?> walls = new Gee.ArrayList<Sprite?>();
        debug("Add top walls from %d to %d\n", TILE_SIZE, length * TILE_SIZE);

        var items = new TopWallGenerator().generate(length);

        var pos = TILE_SIZE;
        items.foreach((item) => {
            Sprite sprite = Sprite() {
                priority = Priority.N,
                src = item.src,
                dest = Rect() { x = (origin.x + x) * TILE_SIZE + pos, y = (origin.y + y) * TILE_SIZE, w = item.src.w, h = item.src.h}
            };
            walls.add(sprite);

            var t = 0;
            if (item.hold_embellishment == true) {
                var torch = Sprite() {
                    priority = Priority.H,
                    src = Rect() { x = TILE_SIZE * 14, y = 0, w = 24, h = 42 },
                    dest = Rect() { x = (origin.x + x + 1) * TILE_SIZE + pos, y = (origin.y + y + 1) * TILE_SIZE, w = 24, h = 42},
                    frame_options = new FrameOptions(t)
                };
                walls.add(torch);
                t += 3;
            }

            pos += (int) item.src.w;
            return true;
        });
      
        return walls;
    }

    private Gee.List<Sprite?> bottom_walls(int x, int y, int length) {
        Gee.List<Sprite?> walls = new Gee.ArrayList<Sprite?>();
        
        var len = length * TILE_SIZE;

        debug("Add bottom walls from %d to %d\n", 0, len);
       
        // try to put the special bottom wall
        //  if (length >= 7) {
        //      Sprite sprite = Sprite() {
        //          priority = Priority.S,
        //          src = Rect() {x = 4 * TILE_SIZE, y = 7 * TILE_SIZE, w = 160, h = 64},
        //          dest = Rect() { x = (origin.x + x + 1) * TILE_SIZE, y = (origin.y + y - 1) * TILE_SIZE, w = 160, h = 64}
        //      };
        //      walls.add(sprite);
        //      return walls;
        //  }

        for (var i = 0; i < len; i += TILE_SIZE) {
            debug("Add bottom walls at %d\n", i);
            Sprite sprite = Sprite() {
                priority = Priority.S,
                src = Rect() {x = 3 * TILE_SIZE, y = 0, w = 32, h = 32},
                dest = Rect() { x = (origin.x + x) * TILE_SIZE + i, y = (origin.y + y) * TILE_SIZE, w = 32, h = 32}
            };
            walls.add(sprite);
            debug("Rect at x=%d y=%d w=%d h=%d", sprite.dest.x, sprite.dest.y, (int) sprite.dest.w, (int) sprite.dest.h);
        }
      
        return walls;
    }

    private Gee.List<Sprite?> right_walls(int x, int y, int length) {
        Gee.List<Sprite?> walls = new Gee.ArrayList<Sprite?>();
        debug("Add right walls from %d to %d\n", 0, length * TILE_SIZE);
       
        for (var i = 0; i < length * TILE_SIZE; i += TILE_SIZE) {
            debug("Add right walls at %d\n", i);
            Sprite sprite = Sprite() {
                priority = Priority.E,
                src = Rect() {x = TILE_SIZE, y = 2 * TILE_SIZE, w = 64, h = 32},
                dest = Rect() { x = (origin.x + x - 1) * TILE_SIZE, y = (origin.y + y) * TILE_SIZE + i, w = 64, h = 32}
            };
            walls.add(sprite);
            debug("Rect at x=%d y=%d w=%d h=%d", sprite.dest.x, sprite.dest.y, (int) sprite.dest.w, (int) sprite.dest.h);
        }
      
        return walls;
    }

    private Gee.List<Sprite?> left_walls(int x, int y, int length) {
        Gee.List<Sprite?> walls = new Gee.ArrayList<Sprite?>();
        debug("Add left walls from %d to %d\n", 0, length * TILE_SIZE);
       
        for (var i = 0; i < length * TILE_SIZE; i += TILE_SIZE) {
            debug("Add left walls at %d\n", i);
            Sprite sprite = Sprite() {
                priority = Priority.W,
                src = Rect() {x = 7 * TILE_SIZE, y = 2 * TILE_SIZE, w = 64, h = 32},
                dest = Rect() { x = (origin.x + x) * TILE_SIZE, y = (origin.y + y) * TILE_SIZE + i, w = 64, h = 32}
            };
            walls.add(sprite);
            debug("Rect at x=%d y=%d w=%d h=%d", sprite.dest.x, sprite.dest.y, (int) sprite.dest.w, (int) sprite.dest.h);
        }
      
        return walls;
    }
}

public struct SceneryItem {
    public int length;
    public Rect? src;
    public bool hold_embellishment;

    public SceneryItem() {
        hold_embellishment = false;
    }
}

public class TopWallGenerator {

    private const int TILE_SIZE = 32;

    private GLib.Rand rand = new GLib.Rand();

    private SceneryItem pillar = SceneryItem() { length = 5 };

    private SceneryItem walls_with_torch = SceneryItem() { length = 3 };

    private SceneryItem walls = SceneryItem() { length = 3 };

    private SceneryItem wall = SceneryItem() { length = 1 };
    
    public Gee.List<SceneryItem?> generate(int length) {
        var nums = new Gee.ArrayList<SceneryItem?>();

        var remaining_length = length - 1;
        while (remaining_length > 0) {
            var item = get_item();
            if (remaining_length - item.length < 0) {
                continue;
            }

            remaining_length -= item.length;
            nums.add(item);
        }

        return nums;
    }

    private SceneryItem get_item() {
       var random = rand.int_range(0, 4);
       var item = wall;
       debug("RANDOM %d\n", random);
        switch (random) {
            case 0:
                item = pillar;
                item.src = Rect() { x = 9 * TILE_SIZE, y = 0, w = 160, h = 128 };
                break;
            case 1:
                item = walls_with_torch;
                item.hold_embellishment = true;
                item.src = Rect() {x = TILE_SIZE * 3, y = TILE_SIZE * 3, w = 32 * 3, h = 128};
                break;
            case 2:
                item = walls_with_torch;
                item.hold_embellishment = true;
                item.src = Rect() {x = TILE_SIZE * 3, y = TILE_SIZE * 3, w = 32 * 3, h = 128};
                break;
            case 3:
                item = wall;
                item.src = Rect() {x = rand.int_range(3, 6) * TILE_SIZE, y = TILE_SIZE * 3, w = 32, h = 128};
                break;
        }
        return item;
    }
}