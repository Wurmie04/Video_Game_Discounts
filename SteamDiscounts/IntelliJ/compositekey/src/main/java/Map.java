import org.apache.hadoop.io.FloatWritable;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

import java.io.IOException;
import java.util.StringTokenizer;

//performs filtering and sorting
public class Map extends Mapper<LongWritable, Text, StGroupKey, Text> {

    public void map(LongWritable key, Text value, Context context
    ) throws IOException, InterruptedException {
        //log.info("INFO: In map method");
        //log.warn("WARN: In map method");

        //break string into tokens
        StringTokenizer itr = new StringTokenizer(value.toString(), ",");
        //get all the info from the value parameter which is from the txt file
        //left to right, split by commas
        String counter = itr.nextToken();
        counter = counter.replace("\"","");

        String GameType = itr.nextToken();
        GameType = GameType.replace("\"","");

        String GameName = itr.nextToken();
        GameName = GameName.replace("\"","");

        String year = itr.nextToken();
        year = year.replace("\"","");
        int yearReleased = new Integer(year);

        String lowestPrice = itr.nextToken();
        lowestPrice = lowestPrice.replace("\"","");
        float firstPartyLowestPrice = Float.parseFloat(lowestPrice);

        String lowestThirdParty = itr.nextToken();
        lowestThirdParty = lowestThirdParty.replace("\"","");
        float thirdPartyLowest = Float.parseFloat(lowestThirdParty);

        String bothPrices = firstPartyLowestPrice + "," + thirdPartyLowest;

        StGroupKey k = new StGroupKey(yearReleased);

        context.write(k, new Text(bothPrices));
    }
}