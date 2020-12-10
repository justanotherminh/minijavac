class Main {
    public static void main(String[] args) {
        RandomGenerator g = new RandomGenerator();
        g.setSeed(23);
        int i = 0;
        while (i < 100) {
            System.out.println(g.sample());
            i = i + 1;
        }
    }
}

class RandomGenerator {
    int m = 134456;
    int a = 8121;
    int c = 28411;
    int x;
    // Our grammar doesn't allow functions to return void besides main
    public int setSeed(int x) {
        this.x = x;
        return 0;
    }
    public int sample() {
        x = a*x + c;
        x = x - x/m*m;
        return x;
    }
}
