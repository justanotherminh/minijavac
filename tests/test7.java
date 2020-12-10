class Main {
    public static void main(String[] args) {
        int[][] A = new int[5][5];
        int x = 0, y = 0;
        while (x < 5) {
            while (y < 5) {
                A[x][y] = 3;
                y = y + 1;
            }
            x = x + 1;
        }
    }
}
