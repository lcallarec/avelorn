public interface MapReader : Object {

    public abstract int width { get; set;}
    public abstract int height { get; set;}
    public abstract string get_string_from_coord(int x, int y);
}

public class ArrayMapReader : MapReader, Object {

    private unichar[,] source;

    public  int width { get; set;}
    public int height { get; set;}

    public ArrayMapReader(unichar[,] source) {
        this.source = source;
        this.width = source.length[1];
        this.height = source.length[0];
    }

    public string get_string_from_coord(int x, int y) {
        return source[x, y].to_string();
    }
}

public class FileMapReader : MapReader, Object {

    private unichar[,] source = new unichar[1000, 1000];

    public  int width { get; set;}
    public  int height { get; set;}

    public FileMapReader(string path) {
        File file = File.new_for_path(path);
        try {
            FileInputStream is = file.read();
            DataInputStream dis = new DataInputStream(is);
            
            string line;
            while ((line = dis.read_line()) != null) {
                unichar c;
                debug("Read line %s\n", line);
                for (int i = 0; line.get_next_char(ref i, out c);) {
                    debug("Read char %s\n", c.to_string());
                    source[i, height] = c;
                }
                
            }
            height = 1000;
            width = 1000;

        } catch (Error e) {
            print("Error: %s\n", e.message);
        }
    
    }

    public string get_string_from_coord(int x, int y) {
        return source[x, y].to_string();
    }
}