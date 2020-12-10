class Main {
    public static void main(String[] args) {
        C c = new C();
        c.setx(123);
        c.sety(456);
        System.out.println(c.x);
        System.out.println(c.y);
    }
}
class A {
    int x;
    public int setx(int x) {
        this.x = x;
    }
}

class C extends B {}

class B extends A {
    int y;
    public int sety(int y) {
        this.y = y;
    }
}
