void generator() {
    Test.add_func("/Generator)", () => {
        //given
        var generator = new Generator(0, 0);

        //when
        generator.generate();
        var sprites = generator.get_sprites();

        //then
        assert(sprites.size == 36);
    });
}