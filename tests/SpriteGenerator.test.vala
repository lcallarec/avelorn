void sprite_generator() {
    Test.add_func("/TopWallGenerator/generate", () => {
        //given
        var generator = new TopWallGenerator();
        var rand = new GLib.Rand();
        int len = rand.int_range(2, 1000);
        //when
        var items = generator.generate(len);

        //then
        var sum = 0;
        items.foreach((item) => {
            sum += item.length;
            return true;
        });
        assert(sum == len - 1);
    });
}