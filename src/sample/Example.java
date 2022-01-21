package sample;

public class Example {

    public int fizzbuzz(int num) {
        if (num % 15 == 0) {
            return 15;
        } else if (num % 5 == 0) {
            return 5;
        } else if (num % 3 == 0) {
            return 3;
        }
        return 0;
    }

}
