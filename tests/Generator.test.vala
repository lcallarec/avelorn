void generator() {
    Test.add_func("/Generator)", () => {
        //given
        unichar[,] map = {
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

        var generator = new Generator(new Map(map), 0, 0);

        //when
        generator.generate();
        var sprites = generator.get_sprites();

        //then
        assert(sprites.size == 36);
    });
}