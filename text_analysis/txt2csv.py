# -*- coding: utf-8 -*-
"""
Created on Wed Nov 02 22:37:37 2016

@author: 16727_000
"""
import os
os.chdir("E:/graduate/class/非结构化/文本分析_李翠平/垃圾短信数据集与代码")


readfile = open('whole.txt','rb')
outfile = open('temp.csv','w+')
lines = readfile.readlines()
outstr = ''
for line in lines:
    t = line.split()
    outstr =t[1].decode()+','+t[2].decode()
    print(outstr)
    outfile.write(outstr.encode("utf-8").decode("utf-8")+'\n')
readfile.close()
outfile.close()

import pandas as pd
readfile = pd.read_table('whole.txt',header = None,encoding = "utf-8")
readfile.head()
readfile.ix[:,1:].to_csv("temp.csv",header = False)
