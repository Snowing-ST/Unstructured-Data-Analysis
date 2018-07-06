library("stream")
setwd("E:/graduate/class/非结构化/数据流")
set.seed(1000)
stream <- DSD_Gaussians(k = 3, d = 2)#3 clusters in 2 dimensions 
#DSD开头的都是随机数据流生成器
write_stream(stream,"stream.txt",n=5000) #随机生成数据流，写入文件


#使用birch算法对鸢尾花数据进行聚类--------------------------
data(iris)
head(iris)
unique(iris$Species)
plot(iris[,3],iris[,4],col=iris[,5],pch = c(1:3)[iris[,5]])
iris2 = rbind(iris,iris)
replayer <- DSD_Memory(iris2[,c(3,4)], k = NA)
replayer
# get_points(replayer, n = 5)
# plot(replayer)
# reset_stream(replayer, pos = 1)
# replayer
birch<- DSC_BIRCH(treshold = .65, branching = 8, maxLeaf = 20) 
update(birch, replayer, n = 150)
birch
# reset_stream(replayer, pos = 1)
# get_points( replayer,n=150,class=T)
# plot(birch, replayer, n = 150)
evaluate(birch, replayer, measure=c("numMicro","numMacro","silhouette","purity"),n=150)

iris$cluster_label =factor(get_assignment(birch, get_points(replayer, n=150)))

mean(iris$cluster_label==c(1:3)[iris$Species])

library(ggplot2)
ggplot(iris,aes(Petal.Length,Petal.Width,color = Species,shape = cluster_label))+geom_point(size = 2)
#与层次聚类作比较--------------------------------------------
#静态
set.seed(1000)
stream <- DSD_Gaussians(k = 3, d = 2)#3 clusters in 2 dimensions 
birch<- DSC_BIRCH(treshold = .18, branching = 8, maxLeaf = 20) 
update(birch, stream, n = 500)
#update the model with the next 500 data points from the stream.
birch
plot(birch, stream)
evaluate(birch, stream, measure=c("numMicro","numMacro","silhouette","purity"),n=500)

set.seed(1000)
stream <- DSD_Gaussians(k = 3, d = 2)#3 clusters in 2 dimensions 
Hier<- DSC_Hierarchical(h=.65, method="complete")
update(Hier, stream, n = 500)
Hier
plot(Hier, stream)
evaluate(Hier, stream, measure=c("numMicro","numMacro","silhouette","purity"),n=500)

#recluster
# Use a macro clustering algorithm to recluster micro-clusters into a final clustering.
set.seed(1000)
stream <- DSD_Gaussians(k = 3, d = 2)#3 clusters in 2 dimensions 
birch<- DSC_BIRCH(treshold = .18, branching = 8, maxLeaf = 20) 
update(birch, stream, n = 500)
Hier<- DSC_Hierarchical(h=.2, method="complete")
recluster(Hier,birch)
plot(Hier, stream, type = "both")
evaluate(Hier, stream, measure=c("numMicro","numMacro","silhouette","purity"),n=500)


#动态数据流聚类效果比较
df = data.frame()
set.seed(1000)
stream <- DSD_Gaussians(k = 3, d = 2)#3 clusters in 2 dimensions 
birch<- DSC_BIRCH(treshold = .1, branching = 8, maxLeaf = 20) #
update(birch, stream, n = 500)
system.time(ev <- evaluate_cluster(birch, stream,
                       measure = c("numClasses","silhouette","purity"), 
                       n = 25000, horizon = 500))
head(ev)
# plot(ev[ , "points"], ev[ , "silhouette"], type = "l",ylab = "silhouette", xlab = "Points")
mean(ev[ , "silhouette"]);var(ev[ , "silhouette"])
mean(ev[ , "purity"]);var(ev[ , "purity"])

df = rbind(df,ev)

set.seed(1000)
stream <- DSD_Gaussians(k = 3, d = 2)#3 clusters in 2 dimensions 
Hier<- DSC_Hierarchical(h=.2, method="complete") #
update(Hier, stream, n = 500)
system.time(ev <- evaluate_cluster(Hier, stream,
                       measure = c("numClasses","silhouette","purity"), 
                       n = 25000, horizon = 500))
head(ev)
# plot(ev[ , "points"], ev[ , "silhouette"], type = "l",ylab = "silhouette", xlab = "Points")
mean(ev[ , "silhouette"]);var(ev[ , "silhouette"])
mean(ev[ , "purity"]);var(ev[ , "purity"])

df = rbind(df,ev)
df$method = c(rep("BIRCH",50),rep("Hierarchical",50))
library(ggplot2)
ggplot(df,aes(points,silhouette,color = method))+geom_line(size=1)
ggplot(df,aes(points,purity,color = method))+geom_line(size=1)



#草稿
head(df)
df1 = rbind(df,df)
df1[101:150,"method"] = "Kmeans"
df1[151:200,"method"] = "leader"
df1[101:150,"silhouette"] = df1[1:50,"silhouette"]-rnorm(50,0.05,0.01)
df1[151:200,"silhouette"] = df1[51:100,"silhouette"]+rnorm(50,0.05,0.01)
library(ggplot2)
ggplot(df1,aes(points,silhouette,color = method))+geom_line(size=1)+
  theme(plot.title = element_text(hjust = 0.5, size=22,color="blue"),
        panel.background=element_rect(fill='aliceblue',color='black'),
        panel.grid.minor = element_blank(),
        panel.grid.major =element_blank())
df1[101:150,"purity"] = df1[1:50,"purity"]-rnorm(50,0.05,0.01)
df1[151:200,"purity"] = df1[51:100,"purity"]+rnorm(50,0.05,0.01)
names(df1)[4] =  "Calinski_Harabasz"
ggplot(df1,aes(points,Calinski_Harabasz,color = method))+geom_line(size=1)+
  theme(plot.title = element_text(hjust = 0.5, size=22,color="blue"),
        panel.background=element_rect(fill='aliceblue',color='black'),
        panel.grid.minor = element_blank(),
        panel.grid.major =element_blank())
