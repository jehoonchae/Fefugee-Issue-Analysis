from bs4 import BeautifulSoup
import nltk
from konlpy.tag import Okt
import pandas as pd

import os
import datetime
import re
import pickle

pos_tagger = Okt()

with open('data/comment/comment.pickle', 'rb') as f:
    mydata = pickle.load(f)

comment_count = []
df_count = pd.DataFrame(comment_count, columns=['url', 'comment_count'])
for count in mydata:
    comment_count.append([count[0], count[1]])

df_count.drop_duplicates()

# df.to_csv('data/merged.csv', index=False)
df = pd.read_csv('data/merged.csv')

df.groupby(['month']).comment_count.sum()
df.comment_count.sum()


df['comment'].notnull().sum()

len(df[df['comment'].str.len() > 1000])

df.groupby(['publisher', 'date']).comment.count()

datetime.datetime.strptime(df['date'][0], "%Y-%m-%d")  # 수집 시작 날짜
time.strftime('%Y-%m-%d', df['date'])
df['date'] = df['date'].astype(str)
df['month'] = df['date'].str[0:7]

df.groupby(['publisher', 'month']).comment.count()

pd.DataFrame(df.groupby(['publisher', 'month']).comment.count()).to_csv('data/bymonth.csv', index=True)

# pos_tagger = Twitter()

def pos(doc):
    with open('stopwords.txt', 'r', encoding='utf8') as f:
        stopwords_list = [re.sub(r'\n', '', i) for i in f.readlines()]

    doc = re.sub('|'.join(stopwords_list), '', doc)

    # return [t[0] for t in pos_tagger.pos(doc, norm=True, stem=True) if 'Noun' in t[1] and len(t[0]) > 1]
    return [t for t in pos_tagger.nouns(doc) if len(str(t)) > 1]

df['content'] = df['content'].str.replace('[^가-힣]', ' ')
df['content'] = df['content'].str.replace('조선일보|동아일보|한겨레|경향신문|채널A|JTBC|MBN|TV조선', ' ')
df['content'] = df['content'].str.replace('[가-힣]{2,3}\s{1,3}기자', '')
df['content'] = df['content'].str.replace(r'[연합뉴스] <저작권자 ⓒ 1980-2018 ㈜연합뉴스. 무단 전재 재배포 금지.>', ' ')
df['content'] = df['content'].str.replace(r'연합뉴스 모바일', ' ')
df['content'] = df['content'].str.replace(r'동영상 뉴스|앵커', ' ')
df['content'] = df['content'].str.strip()


df = df[df['content'].str.len() > 50].reset_index(drop=True)

df['pos'] = df['content']

df['pos'] = pd.Series([pos(i) for i in df['pos']])  # 명사만 넣어두기

# df.to_csv('data_processed/preprocessed.csv', index = False)