class Main {
    public static void main(String[] args) {
        D d = new D();
        System.out.println(d.c.b.a.x);
        d.c.b.a.setx(69420);
        System.out.println(d.c.b.a.x);
    }
}

class A {
    int x = 100;
    public int setx(int x) {
        this.x = x;
    }
}

class B {
    A a = new A();
}

class C {
    B b = new B();
}

class D {
    C c = new C();
}
