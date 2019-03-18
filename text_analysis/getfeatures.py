# -*- coding: utf-8 -*-
"""
Created on Sat Oct 15 16:10:25 2016

@author: 16727_000
"""

import os
import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import HashingVectorizer

os.chdir("E:/graduate/class/非结构化/文本分析_李翠平/垃圾短信数据集与代码")
mescon_all = pd.read_csv('result.csv',header=None,encoding='gbk')
listtodel = []
#此处目的是将内容为空的短信删除，只保留可以转成特征向量的短信
for i,line in enumerate(mescon_all[1]):
    if type(line)!=np.unicode:
        listtodel.append(i)
mescon_all = mescon_all.drop(listtodel)   

#vector=TfidfVectorizer(CountVectorizer())
#temp = vector.fit_transform(mescon_all[1]).todense()
outfile = open('features.txt','w')

vector = HashingVectorizer(n_features=100)
temp = vector.transform(mescon_all[1]).todense()

x = [[i,j] for i,j in enumerate(mescon_all[0])]
temp = temp.tolist()
for i,line in enumerate(temp):
    outstr = ''
    for word in line:
        outstr += str(word+1)
        outstr += ' ' 
    outfile.write((str(mescon_all[0][x[i][1]])+','+outstr)+'\n')
    
outfile.close()


#unicode是np里面的