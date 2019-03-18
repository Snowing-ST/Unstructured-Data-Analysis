# -*- coding: utf-8 -*-
"""
Created on Wed Oct 12 19:36:39 2016

@author: 16727_000
"""


import pandas as pd
import jieba
import re
import os

os.chdir("E:/graduate/class/非结构化/文本分析_李翠平/垃圾短信数据集与代码")

mescon_all = pd.read_csv('whole.csv',header=None,encoding='utf8')
mescon_all.ix[:,1].value_counts()#9:1


outfile = open('result.csv','w')
ns = 0
ps = 0
for i in range(len(mescon_all)):
    mescon_single = mescon_all[2][i]
    me_cate = mescon_all[1][i]
    outstr = ''
    temp = re.sub(u'[^\u4e00-\u9fa5A-Za-z]','',mescon_single)
    ms_cut = list(jieba.cut(temp,cut_all=False))
    for word in ms_cut:
        if word != ' ':
            outstr += word+' '

    if me_cate == 1:#下采样
        ns = ns+1
        if ns <80000:
            outfile.write((str(me_cate)+','+outstr)+'\n')
    if me_cate == 0:
        ps = ps+1
        if ps <80000:
            outfile.write((str(me_cate)+','+outstr)+'\n')

outfile.close()


#遇到问题：can't concat bytes to str
#这是因为encode返回的是bytes型的数据，不可以和str相加，write函数参数需要为str类型，不要encode即可
#但是，bytes和string并不是毫无关系的，bytes对象有一个decode()方法，
#向该方法传递一个字符编码参数，该方法会返回使用该种编码解码后的字符串。
#同样的，string有一个encode()方法，完成反向的工作。