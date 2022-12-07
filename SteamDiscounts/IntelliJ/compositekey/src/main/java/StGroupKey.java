import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.WritableComparable;
import org.apache.hadoop.util.StringUtils;

import java.io.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

//only for key variables
public class StGroupKey implements WritableComparable<StGroupKey> {

    //define the keys in Map class
    public int releaseDate;

    public StGroupKey(){}

    //change depending on how many keys there are
    public StGroupKey(int date) {
        releaseDate = date;
    }
    /*
        @Override
        public String toString() {
            return "gender='" + gender + '\'' +
                    ", level=" + level;
        }
    */
    //compares the key items to see if they should be before or after
    //checks if the age should be before or after the other age
    //50s first, then 40s, then 30s, then 20s
    public int compareTo(StGroupKey o) {    // 1. 0. -1
        if (releaseDate < o.releaseDate) return 1;
        else if(releaseDate > o.releaseDate) return -1;
        else
            return 0;
    }

    // Serialization
    //process that converts structure data manually back to the original form
    public void write(DataOutput dataOutput) throws IOException {
        new IntWritable(releaseDate).write(dataOutput);
    }

    // De-serialization
    //process of turning a byte stream back into a series of structured objects
    //used to read data from hadoop
    //needs this in order to write to output file
    public void readFields(DataInput dataInput) throws IOException {
        IntWritable dateText = new IntWritable();
        dateText.readFields(dataInput);
        releaseDate = dateText.get();
    }

    //outputs as the Group instead of StKey....
    public String toString() {
        return releaseDate + " : ";
    }

    public static void main(String[] args) throws Exception {

    }
}