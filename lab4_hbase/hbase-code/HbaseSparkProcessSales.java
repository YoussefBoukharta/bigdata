import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.mapreduce.TableInputFormat;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.*;
import org.apache.spark.api.java.function.Function;
import org.apache.spark.api.java.function.Function2;
import java.io.Serializable;

public class HbaseSparkProcessSales implements Serializable {
    
    public void calculateTotalSales() {
        Configuration config = HBaseConfiguration.create();
        SparkConf sparkConf = new SparkConf()
            .setAppName("SparkHBaseSalesSum")
            .setMaster("local[4]");
        JavaSparkContext jsc = new JavaSparkContext(sparkConf);
        config.set(TableInputFormat.INPUT_TABLE, "products");
        
        JavaPairRDD<ImmutableBytesWritable, Result> hBaseRDD = jsc.newAPIHadoopRDD(
            config, TableInputFormat.class, ImmutableBytesWritable.class, Result.class);
        
        long count = hBaseRDD.count();
        System.out.println("Nombre d'enregistrements: " + count);
        
        JavaRDD<Double> pricesRDD = hBaseRDD.map(new Function<scala.Tuple2<ImmutableBytesWritable, Result>, Double>() {
            public Double call(scala.Tuple2<ImmutableBytesWritable, Result> tuple) throws Exception {
                Result result = tuple._2();
                byte[] priceBytes = result.getValue(Bytes.toBytes("cf"), Bytes.toBytes("price"));
                if (priceBytes != null) {
                    return Double.parseDouble(Bytes.toString(priceBytes));
                }
                return 0.0;
            }
        });
        
        Double totalSales = pricesRDD.reduce(new Function2<Double, Double, Double>() {
            public Double call(Double p1, Double p2) throws Exception {
                return p1 + p2;
            }
        });
        
        System.out.println("===============================================");
        System.out.println("Somme totale des ventes: $" + String.format("%.2f", totalSales));
        System.out.println("Nombre de transactions: " + count);
        System.out.println("Prix moyen par transaction: $" + String.format("%.2f", totalSales / count));
        System.out.println("===============================================");
        jsc.close();
    }
    
    public static void main(String[] args) {
        HbaseSparkProcessSales processor = new HbaseSparkProcessSales();
        processor.calculateTotalSales();
    }
}
