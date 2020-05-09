public class Map {

    private unichar[,] source;

    public int width { get; private set;}
    public int height { get; private set;}

    public Map(unichar[,] source) {
        this.source = source;
        this.width = source.length[1];
        this.height = source.length[0];
    }

    public string get_string_from_coord(int x, int y) {
        return source[x, y].to_string();
    }
}