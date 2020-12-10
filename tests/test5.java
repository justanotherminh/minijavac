class Main {
    public static void main(String[] args) {
        Foo f = new Foo();
        f.foo(23);
        int i = 0;
        while (i < 23) {
            System.out.println(f.x[i]);
            i = i + 1;
        }
    }
}

class Foo {
    int[] x;
    public int foo(int n) {
        x = new int[n];
        int i = 0;
        while (i < n) {
            this.x[i] = i;
            i = i + 1;
        }
    }
}
