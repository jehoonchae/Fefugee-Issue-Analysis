import pandas as pd
import os
import datetime
import re
import pickle
from bs4 import BeautifulSoup
import nltk
from konlpy.tag import Okt

os.chdir('/Users/jhchae/Dropbox/Pycharm/IC2S2-2020')
os.getcwd()

pos_tagger = Okt()

from konlpy.tag import Mecab
pos_tagger = Mecab()

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
    with open('/Users/jhchae/Dropbox/MA/프로젝트/YemenRefugee/News_Framing_Refugee/Data/news_stopwords.txt', 'r', encoding='utf8') as f:
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

# df.to_csv('data/preprocessed.csv', index = False)

# !wget https://raw.githubusercontent.com/lovit/soynlp/master/tutorials/2016-10-20.txt -O 2016-10-20.txt

from soynlp import DoublespaceLineCorpus

# 문서 단위 말뭉치 생성
corpus = DoublespaceLineCorpus("2016-10-20.txt")
len(corpus)  # 문서의 갯수

# 앞 5개의 문서 인쇄
i = 0
for d in corpus:
    print(i, d)
    i += 1
    if i > 4:
        break

# 문장 단위 말뭉치 생성
corpus = DoublespaceLineCorpus("2016-10-20.txt", iter_sent=True)
len(corpus)  # 문장의 갯수

# 앞 5개의 문장 인쇄
i = 0
for d in corpus:
    print(i, d)
    i += 1
    if i > 4:
        break

%%time
from soynlp.word import WordExtractor

word_extractor = WordExtractor()
word_extractor.train(corpus)

word_score = word_extractor.extract()

word_score["연합"].cohesion_forward
word_score["연합뉴"].cohesion_forward
word_score["연합뉴스"].cohesion_forward
word_score["연합뉴스는"].cohesion_forward

word_score["연합"].right_branching_entropy
# '연합뉴' 다음에는 항상 '스'만 나온다.
word_score["연합뉴"].right_branching_entropy
word_score["연합뉴스"].right_branching_entropy
word_score["연합뉴스는"].right_branching_entropy

word_score["연합"].right_accessor_variety
# '연합뉴' 다음에는 항상 '스'만 나온다.
word_score["연합뉴"].right_accessor_variety
word_score["연합뉴스"].right_accessor_variety
word_score["연합뉴스는"].right_accessor_variety

from soynlp.tokenizer import LTokenizer

scores = {word:score.cohesion_forward for word, score in word_score.items()}
l_tokenizer = LTokenizer(scores=scores)

l_tokenizer.tokenize("안전성에 문제있는 스마트폰을 휴대하고 탑승할 경우에 압수한다", flatten=False)

from soynlp.tokenizer import MaxScoreTokenizer

maxscore_tokenizer = MaxScoreTokenizer(scores=scores)
maxscore_tokenizer.tokenize("안전성에문제있는스마트폰을휴대하고탑승할경우에압수한다")