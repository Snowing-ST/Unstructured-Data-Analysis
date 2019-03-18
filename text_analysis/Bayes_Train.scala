import org.apache.spark.mllib.classification.NaiveBayes
import org.apache.spark.mllib.linalg.Vectors
import org.apache.spark.mllib.regression.LabeledPoint
import org.apache.spark.{SparkContext,SparkConf}
object test {
case class RawDataRecord(category: String, text: String)
  def main(args : Array[String]) {
    val conf = new SparkConf().setMaster("local").setAppName("Bayes")
    val sc = new SparkContext(conf)
    val data = sc.textFile("F:/data/features.txt")
    //读入处理好的数据，且以逗号为分隔，取出每个Label与特征向量
    val parsedData = data.map { line =>
      val parts = line.split(',')
      LabeledPoint(parts(0).toDouble,Vectors.dense(parts(1).split(' ').map(_.toDouble)))
    }
    //将整个80万条测试集按训练集与测试集4:1比例随机分配
    val splits = parsedData.randomSplit(Array(0.8,0.2))
    val training = splits(0)
    val test = splits(1)  
    //以贝叶斯方法训练数据，创建模型,lambda为平滑参数，可手动设置
    val model = NaiveBayes.train(training,lambda = 1.0)
    //将测试集用训练出的模型进行预测
    val predictionAndLabel = test.map(p => (model.predict(p.features),p.label))  
    //统计预测出的数据
    val TP = predictionAndLabel.filter(x => x._1 == 0 && x._2 == 0).count()
    val FP = predictionAndLabel.filter(x => x._1 == 0 && x._2 == 1).count()
    val FN = predictionAndLabel.filter(x => x._1 == 1 && x._2 == 0).count()
    val TN = predictionAndLabel.filter(x => x._1 == 1 && x._2 == 1).count()    
    //计算准确率 召回率 F1来评估模型
    val pre = 1.0*TP/(TP+FP)
    val recall = 1.0*TP/(TP+FN)
    val F1 = 2.0*pre*recall/(pre+recall)  
    println("TP为："+TP)
    println("FP为："+FP)
    println("FN为："+FN)
    println("TN为："+TN)
    println("准确率为："+pre)
    println("召回率为："+recall)
    println("F1为："+F1)
  }
}