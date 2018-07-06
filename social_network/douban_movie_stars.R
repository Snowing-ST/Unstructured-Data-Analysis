#########加载包########
library(igraph)
library(Matrix)
library(sand)
library(network)
library(plyr)
library(dplyr)
library(Cairo)
library(ggplot2)


#########读取数据######
setwd("E:/graduate/class/非结构化/social_network/community/data")              #设置工作路径
# load("adajcent.rda")
load("goodadjacent.rda")
g <- graph_from_adjacency_matrix(goodadjacent,mode = c("undirected"),weighted = NULL)
# 7025结点
is.simple(g) #多重图（存在自环/多重边）
E(g)$weight #不含权
E(g)$weight <- 1
g <- simplify(g)
is.simple(g)
E(g)$weight #含权


#提取前n个合作关系最多的演员
adj_mat = get.adjacency(g,attr="weight")#邻接矩阵
# adj_mat[1:20,1:20]
adj_mat_I = adj_mat
adj_mat_I[adj_mat_I>0] = 1 #是否有合作关系的指示邻接矩阵

# adj_list = get.adjlist(g) #得到每个点及其邻居
# adj_list[1:20]

# n_co_weight = colSums(adj_mat);n_co_weight[1:20] #合作演员加权数
# n_co = sapply(adj_list,length);n_co[1:20] #合作演员数

# index =  c(colSums(adj_mat)>3) #权数和大于3的演员
# top_star_adj_mat = adj_mat[index,index]

index =  c(colSums(adj_mat_I)>2) #合作演员数大于2的演员
top_star_adj_mat = adj_mat[index,index]

dim(top_star_adj_mat)
# top_star_adj_mat[1:20,1:20]
top_g <- graph_from_adjacency_matrix(top_star_adj_mat,mode = c("undirected"),weighted = T)
top_g 
is.simple(top_g) #简单图
E(top_g)$weight #含权

set.seed(45)
l=layout.kamada.kawai(top_g)     
plot(top_g,layout=l,vertex.size=3,
     #vertex.label.cex=0.9,
     vertex.label = NA
)

myc <- clusters(top_g, mode="strong")
myc$csize
myc$csize[order(myc$csize,decreasing = T)]
mycolor = rep("gray",length(myc$csize))
mycolor[order(myc$csize,decreasing = T)[1:5]] = c('green', 'yellow', 'red', 'skyblue')
V(top_g)$color <- mycolor[myc$membership]


V(top_g)$sg=myc$membership
V(top_g)$color = rainbow(max(V(top_g)$sg),alpha=0.8)[V(top_g)$sg]
set.seed(45)
l=layout.kamada.kawai(top_g)     
plot(top_g,layout=l,vertex.size=2,vertex.color = V(top_g)$color,
     #vertex.label.cex=0.9,
     vertex.label = NA,vertex.frame.color=NA)




set.seed(45)
l=layout.kamada.kawai(top_g)                     #形成布局
CairoPNG("season3.png", 4000, 4000)              #打开一个图形设备
plot(top_g,layout=l,vertex.size=2,vertex.color = V(top_g)$color,
     vertex.label.cex=0.9,vertex.frame.color=NA
     # vertex.label = NA
)
dev.off()



########描述统计#######
g1 = decompose.graph(top_g)[[1]] #最大连通子网络

#以边权决定边的粗细
set.seed(45)
E(g1)$width = E(g1)$weight
l=layout.kamada.kawai(g1)                     #形成布局
plot(g1,layout=l,vertex.label.cex = 0.9,vertex.size=3,vertex.label = NA,vertex.frame.color=NA)

#（一）节点和边的特征

#1. 节点度特征
vcount(g1)
ecount(g1)
degree<-degree(g1)
table(degree)#度统计
hist(degree(g1),col = "lightblue",xlim = c(0,50),xlab = "Degree",ylab = "Frequence")
#对于含权网络，度的一个有用的推广就是节点的强度
#即与某个节点相连的边的权重之和，强度分布=加权度分布
hist(graph.strength(g1),col = "lightblue",xlim = c(0,50),xlab = "Degree",ylab = "Frequence")


m=degree.distribution(g1)#查看度分布??
x=c(seq(1:(length(m)-1)))#画折线图
plot(x,m[-1],col="blue",pch=22,bg="yellow",lwd=2,xlab="degree",main="度分布",
     col.main="blue",font.main=2,asp=0,cex=1.2,type="b",lty=1,ylab = "density")

plot(table(degree),type="h")#绘制直方图

#2.节点中心性
#度中心性
center = data.frame(index = c(1:10))
center$de = names(degree(g1)[order(degree(g1),decreasing = T)][1:10])

#接近中心性
center$cl = names(closeness(g1)[order(closeness(g1),decreasing = T)][1:10])
#介数中心性
center$be = names(betweenness(g1)[order(betweenness(g1),decreasing = T)][1:10])

#特征向量中心性
center$ev = names(evcent(g1)$vector[order(evcent(g1)$vector,decreasing = T)][1:10])

center

#归一化函数
scale1 = function(x)
{5*(x-min(x))/(max(x)-min(x))}

par(mfrow = c(2,2))
l <- layout.kamada.kawai(g1)
plot(g1, layout=l, vertex.label=NA,vertex.frame.color=NA,vertex.color = "red",
     vertex.size=scale1(degree(g1)),main = "degree")
plot(g1, layout=l, vertex.label=NA,vertex.frame.color=NA,vertex.color = "red",
     vertex.size=scale1(closeness(g1)),main = "closeness")
plot(g1, layout=l, vertex.label=NA,vertex.frame.color=NA,vertex.color = "red",
     vertex.size=scale1(betweenness(g1)),main = "betweenness")
plot(g1, layout=l, vertex.label=NA,vertex.frame.color=NA,vertex.color = "red",
     vertex.size=scale1(evcent(g1)$vector),main = "eigen value")
par(mfrow = c(1,1))


neighbors(g1,"加濑亮") #查看某个节点的邻居

#3.边介数
eb <- edge.betweenness(g1)
E(g1)[order(eb, decreasing=T)[1:10]]#边介数前10的边
#边介数前10的图展示
set.seed(45)
E(g1)$width = 0.5
E(g1)[order(eb, decreasing=T)[1:10]]$width = 4
E(g1)$edge.color = "gray"
E(g1)[order(eb, decreasing=T)[1:10]]$edge.color = "black"
l=layout.kamada.kawai(g1)                     #形成布局
plot(g1,layout=l,vertex.label.cex = 0.9,vertex.size=3,vertex.label = NA,vertex.frame.color=NA,vertex.color = "red",edge.color = E(g1)$edge.color)



#（二）凝聚性特征
table(sapply(maximal.cliques(g1), length))
table(sapply(maximal.cliques(g1), length))
maximal.cliques(g1)[sapply(maximal.cliques(g1), length)==4]
########稀疏性网络#######
graph.density(g1) #网络密度
mean(degree(g1))      #平均度

########小世界网络#####

transitivity(g1)
mean_distance(g1)#平均路径长度
diameter(g1)           #最长路径长度/网络直径


CairoPNG("three.png", 3000, 3000)              #打开一个图形设备
plot(g1,layout=l,vertex.label.cex = 0.9,vertex.size=2)
dev.off()

#连通度
#节点和边的连通度均为1，说明要将g1分为两个不同的额组件只需移除一个恰到的节点和边
vertex.connectivity(g1)
edge.connectivity(g1)

#点割集/关键点集：网络的脆弱之处
g1.cut.vertices = articulation.points(g1)
length(g1.cut.vertices)



#############社区发现########

#按membership更改颜色
com = leading.eigenvector.community(g1) #谱分割
V(g1)$sg=com$membership
V(g1)$color = rainbow(max(V(g1)$sg),alpha=0.8)[V(g1)$sg]
plot(g1,layout=l,vertex.size=2,vertex.color=V(g1)$color,edge.width=0.4,edge.arrow.size=0.08,edge.color = rgb(1,1,1,0.4),vertex.frame.color=NA,margin= rep(0, 4),vertex.label=NA)

#算法
edge.betweenness.community()
fastgreedy.community()
leading.eigenvector.community()
spinglass.community()
walktrap.community()
multilevel.community()#即Louvain 、BGLL 稳定准确快速 特别是稀疏图的时候



#????
label.propagation.community()
cluster_louvain()
cluster_edge_betweenness()
cluster_fast_greedy()
cluster_infomap()
cluster_label_prop()
cluster_leading_eigen()
cluster_optimal()
cluster_spinglass()
cluster_walktrap()

# 社区结构划分的若干评价指标
modularity()#模块度
#模块密度D
#社区度C
#fitness函数

#对比各个社区发现算法的效果
layout(matrix(c(1,2,3,4),nr = 2, byrow = T))

community_detection = list()
g <- g1
set.seed(45)
l=layout.kamada.kawai(g)  


system.time(ec <- edge.betweenness.community(g,weight=E(g)$weight,directed=F))
print(modularity(ec))
# dendPlot(ec, mode="hclust")
plot(ec, g,main = paste("edge.betweenness \n groups =",length(ec),sep = " "),vertex.label=NA,vertex.size = 2,layout=l)
community_detection$edge.betweenness = data.frame(len = length(ec),Q = modularity(ec))

system.time(wc <- walktrap.community(g,weights=E(g)$weight,step=4))
#step代表游走步长，越大代表分类越粗糙，分类类别越小。默认为4.
print(modularity(wc))
#membership(wc)
plot(wc , g,main = paste("walktrap \n groups =",length(wc),sep = " "),vertex.label=NA,vertex.label=NA,vertex.size = 2,layout=l)
community_detection$walktrap = data.frame(len = length(wc),Q = modularity(wc))

# system.time(lec <-leading.eigenvector.community(g))
# print(modularity(lec))
# plot(lec,g,main = paste("leading.eigenvector \n groups =",length(lec),sep = " "),vertex.label=NA,vertex.label=NA,vertex.size = 2)
# community_detection$leading.eigenvector = data.frame(len = length(lec),Q = modularity(lec))

system.time(fc <- fastgreedy.community(g))
# length(fc) #发现社团个数
# sizes(fc) #每个社团包含的节点数
print(modularity(fc))
plot(fc, g,main = paste("fastgreedy \n groups =",length(fc),sep = " "),vertex.label=NA,vertex.label=NA,vertex.size = 2,layout=l)
community_detection$fastgreedy = data.frame(len = length(fc),Q = modularity(fc))


system.time(mc <- multilevel.community(g))
print(modularity(mc))
plot(mc, g,main = paste("mulstilevel \n groups =",length(mc),sep = " "),vertex.label=NA,vertex.label=NA,vertex.size = 2,layout=l)
community_detection$multilevel = data.frame(len = length(mc),Q = modularity(mc))

system.time(lc <- label.propagation.community(g,weights = E(g)$weight))
print(modularity(lc))
# plot(lc , g,main = paste("label.propagation \n groups =",length(lc),sep = " "),vertex.label=NA,vertex.label=NA,vertex.size = 2,layout=l)
community_detection$label.propagation = data.frame(len = length(lc),Q = modularity(lc))

t(sapply(community_detection,function(x){x}))

sc<-spinglass.community(g,weights=E(g)$weight,spins=3)  
#spins代表产生的社群数，默认值为25
print(modularity(sc))
set.seed(45)
l=layout.kamada.kawai(g)  
plot(sc, g,main = paste("spinglass \n groups =",length(sc),sep = " "),vertex.label=NA,vertex.label=NA,vertex.size = 2,layout=l)
#这个社群分类函数有了自己定义分类数量的效果


#提取spinglass子群
subgroup = split(sc$names, sc$membership)
subgroup[[1]] #日本电影演员
subgroup[[2]] #欧美
subgroup[[3]] #日本配音演员

#提取multilevel的子群
subgroup = split(mc$names, mc$membership)
subgroup[[1]] 
subgroup[[2]]
subgroup[[3]] 

set.seed(45)
l=layout.kamada.kawai(g)                     #形成布局
CairoPNG("edge.png", 3000, 3000)              #打开一个图形设备
plot(ec, g,main = paste("edge.betweenness \n groups =",length(ec),sep = " "),
     vertex.size = 2)
dev.off()