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
        var ratio = 2;

        //when
        generator.generate();
        var boxes = generator.get_boxes();

        //then
        assert(boxes.size == 4);
        assert(boxes.get(1).is_equal(SDL.Video.Rect() {x = 32 * 2 * ratio, y = 0, w = 32, h = 32 * 2 * ratio}));
        assert(boxes.get(2).is_equal(SDL.Video.Rect() {x = 0, y = 32 * 2  * ratio, w = 64  * ratio, h = 32}));
        assert(boxes.get(3).is_equal(SDL.Video.Rect() {x = 0, y = 0, w = 32, h = 32 * 2  * ratio}));
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