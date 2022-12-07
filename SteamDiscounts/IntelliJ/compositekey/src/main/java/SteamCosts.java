import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

//edit configurations to change text file input
//sudo su - hadoop
//hdfs namenode -format
//start-dfs.sh
//start-yarn.sh
//jps   verify

//dont forget to delete output everytime you run
public class SteamCosts {
    public static void main(String[] args) throws Exception {
        //you need to declare these no matter what. No idea why.
        Configuration conf = new Configuration();
        //change here to type of sort
        Job job = Job.getInstance(conf, "Avg Price Per Year for First and Third Party");
        //change here to file name at top
        job.setJarByClass(SteamCosts.class);
        job.setMapperClass(Map.class);
        // job.setCombinerClass(Reduce.class);
        job.setReducerClass(Reduce.class);
        job.setOutputKeyClass(StGroupKey.class);
        job.setOutputValueClass(Text.class);
        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}