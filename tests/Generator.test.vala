void generator() {
    Test.add_func("/Generator/Edge)", () => {
        //given
        var generator = new Generator(new Map(get_small_map()), {0, 0});

        //when
        generator.generate();
        var edge = generator.get_edge();

        //then
        assert(edge.corner_size == 4);
    });

    Test.add_func("/Generator/Boxes)", () => {
        //given
        var generator = new Generator(new Map(get_small_map()), {0, 0});

        //when
        generator.generate();
        var boxes = generator.get_boxes();

        //then
        assert(boxes.size == 4);
        debug("Founf Rect() x=%d y=%d w=%d h=%d\n", boxes.get(0).x, boxes.get(0).y, (int) boxes.get(0).w, (int) boxes.get(0).h);
        debug("Founf Rect() x=%d y=%d w=%d h=%d\n", boxes.get(1).x, boxes.get(1).y, (int) boxes.get(1).w, (int) boxes.get(1).h);
        debug("Founf Rect() x=%d y=%d w=%d h=%d\n", boxes.get(2).x, boxes.get(2).y, (int) boxes.get(2).w, (int) boxes.get(2).h);
        debug("Founf Rect() x=%d y=%d w=%d h=%d\n", boxes.get(3).x, boxes.get(3).y, (int) boxes.get(3).w, (int) boxes.get(3).h);
        assert(boxes.get(0).is_equal(SDL.Video.Rect() {x = 0, y = 0, w = 32 * 2, h = 32 * 2}));
        assert(boxes.get(1).is_equal(SDL.Video.Rect() {x = 32 * 2, y = 0, w = 32, h = 32 * 2}));
        //   assert(boxes.get(2).is_equal(SDL.Video.Rect() {x = 32, y = 32 * 2, w = 64, h = 32}));
        //   assert(boxes.get(3).is_equal(SDL.Video.Rect() {x = 0, y = 32, w = 32, h = 32 * 2}));
    });

    //  Test.add_func("/Generator/Edge)", () => {
    //      //given
    //      var generator = new Generator(new Map(get_big_map()), {0, 0});

    //      //when
    //      generator.generate();
    //      var sprites = generator.get_sprites();

    //      //then
    //      assert(sprites.size == 32);
    //  });

    //  Test.add_func("/Generator/boxes)", () => {
    //       //given
    //       var generator = new Generator(new Map(get_small_map()), {0, 0});

    //       //when
    //       generator.generate();
    //       var boxes = generator.get_boxes();

    //       //then
    //       assert(boxes.size == 4);
    //       assert(boxes.get(0).is_equal(SDL.Video.Rect() {x = 0, y = 0, w = 32 * 2, h = 32 * 2}));
    //       assert(boxes.get(1).is_equal(SDL.Video.Rect() {x = 32 * 2, y = 0, w = 32, h = 32 * 2}));
    //       assert(boxes.get(2).is_equal(SDL.Video.Rect() {x = 32, y = 32 * 2, w = 64, h = 32}));
    //       assert(boxes.get(3).is_equal(SDL.Video.Rect() {x = 0, y = 32, w = 32, h = 32 * 2}));
    //  });
}

private unichar[,] get_small_map() {
    return {
        {'┌', '─', '┐'},
        {'│', ' ', '│'},
        {'└', '─', '┘'}
    };
}

private unichar[,] get_big_map() {
    return {
        {'┌', '─', '─', '─', '─', '─', '─', '─', '┐'},
        {'│', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '│'},
        {'│', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '│'},
        {'│', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '│'},
        {'│', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '│'},
        {'│', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '│'},
        {'│', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '│'},
        {'│', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '│'},
        {'└', '─', '─', '─', '─', '─', '─', '─', '┘'}
    };
}