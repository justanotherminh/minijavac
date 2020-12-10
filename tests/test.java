class Main {
    public static void main(String[] args) {
        int[] a = new int[10];
        int[] b = new int[10];
        int i = 0;
        while (i < a.length) {
            a[i] = i;
            b[i] = 9 - i;
            i = i + 1;
        }
        System.out.println(new VectorOp().dotProduct(a, b));
        int[] c = new VectorOp().elemProduct(a, b);
        i = 0;
        while (i < a.length) {
            System.out.println(c[i]);
            i = i + 1;
        }
    }
}

class VectorOp {
    public int dotProduct(int[] a, int[] b) {
        int sum = 0, i = 0;
        while (i < a.length) {
            sum = sum + a[i] * b[i];
            i = i + 1;
        }
        return sum;
    }

    public int[] elemProduct(int[] a, int[] b) {
        int[] result = new int[a.length];
        int i = 0;
        while (i < a.length) {
            result[i] = a[i] * b[i];
            i = i + 1;
        }
        return result;
    }
}
