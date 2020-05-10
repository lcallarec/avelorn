void generator() {
    Test.add_func("/Generator)", () => {
        //given
        var generator = new Generator(new Map(get_big_map()), 0, 0);

        //when
        generator.generate();
        var sprites = generator.get_sprites();

        //then
        assert(sprites.size == 32);
    });

    Test.add_func("/Generator/boxes)", () => {
         //given
         var generator = new Generator(new Map(get_small_map()), 0, 0);

         //when
         generator.generate();
         var boxes = generator.get_boxes();

         //then
         assert(boxes.size == 4);
         assert(boxes.get(0).is_equal(SDL.Video.Rect() {x = 0, y = 0, w = 32 * 2, h = 32 * 2}));
         assert(boxes.get(1).is_equal(SDL.Video.Rect() {x = 32 * 2, y = 0, w = 32, h = 32 * 2}));
         assert(boxes.get(2).is_equal(SDL.Video.Rect() {x = 32, y = 32 * 2, w = 64, h = 32}));
         assert(boxes.get(3).is_equal(SDL.Video.Rect() {x = 0, y = 32, w = 32, h = 32 * 2}));
    });
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