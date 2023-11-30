import org.apache.hadoop.io.FloatWritable;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

import java.io.IOException;

//performs a summary operation
//takes the output of the Mapper (intermediate key-value pair) process each of them to generate the output
public class Reduce extends Reducer<StGroupKey, Text, StGroupKey, Text> {

    //gets the (key, value) input thats the same as map
    public void reduce(StGroupKey key, Iterable<Text> values,
                       Context context
    ) throws IOException, InterruptedException {
        //log.info("INFO: In reduce method with key " + key);
        //log.warn("WARN: In reduce method with key " + key);

        //Sort
        //The framework merge sorts Reducer inputs by keys (since different Mappers may have output the same key).

        //delcare variables that will be passed
        float Fsum = 0;
        int Fcnt = 0;
        float Favg = 0;

        float Tsum = 0;
        int Tcnt = 0;
        float Tavg = 0;

        for(Text f : values){
            String temp = f.toString();
            String[] split = temp.split(",");
            float tempF = Float.parseFloat(split[0]);
            float tempT = Float.parseFloat(split[1]);
            Fsum += tempF;
            Tsum += tempT;
            Fcnt += 1;
        }

        //System.out.println(T)
        Favg = Fsum / (float) Fcnt;
        Tavg = Tsum / (float) Fcnt;

        Tavg = Tsum / (float) Tcnt;*/

        String returnText = Favg + " " + Tavg;

        //Reduce
        context.write(key, new Text(returnText));
    }

}
