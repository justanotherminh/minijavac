class Main {
    public static void main(String[] args) {
        int n;
        System.out.println(n);
        n = Integer.parseInt(args[0]);
        System.out.println(new Sequences().Fib(n));
        System.out.println(new Sequences().FibNoRC(n));
    }
}

class Sequences {
    public int Fib(int n) {
        if (n < 2) {
            return n;
        } else {
            return this.Fib(n-1) + this.Fib(n-2);
        }
    }

    public int FibNoRC(int n) {
        int a = 1, b = 1, i = 3;
        while (i <= n) {
            if (i-i/2*2 == 1) {
                a = a + b;
            } else {
                b = a + b;
            }
            i = i + 1;
        }
        if (a > b) {
            return a;
        } else {
            return b;
        }
    }
}