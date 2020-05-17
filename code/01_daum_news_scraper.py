from bs4 import BeautifulSoup
from urllib.request import urlopen
import urllib.parse
import requests
from selenium import webdriver
from tqdm import notebook
import datetime
from datetime import timedelta

import os
import time
import random
import re
import pickle
import csv

def url_bydate(KEYWORD, DATE1, DATE2):
    first = (
        "https://search.daum.net/search?w=news&sort=recency&q={0}"
        "&cluster=n&DA=STC&dc=STC&pg=1&r=1&p=1&rc=1&at=more&sd={1}&ed={2}&period=u".format(
            urllib.parse.quote_plus(KEYWORD.encode("cp949")), DATE1, DATE2
        )
    )
    # html = urlopen(first)
    # soup = BeautifulSoup(html, 'lxml')
    user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.47 Safari/537.36'
    headers = {'User-Agent': user_agent}

    soup = BeautifulSoup(requests.get(first, headers = headers).text, "lxml")
    if soup.find("span", class_="f_nb date") == None:  # if there is no news list
        return []
    else:  # if there news list on the page
        pagenum = int(
            re.sub(
                "건",
                "",
                re.findall("[0-9]{1,6}건", soup.find("span", class_="txt_info").text)[0],
            )
        )
        totalpage = int(int(pagenum) / 10 + 1)
        i = 1
        url_list = []
        while i <= totalpage:
            pageurl = re.sub("&p=[0-9]", "&p=" + str(i), first)
            soup = BeautifulSoup(requests.get(pageurl).text, "lxml")
            url = [j.get("href") for j in soup.find_all("a", class_="f_nb")]
            url_list += url
            i += 1
        return url_list

keyword = '난민'

date1 = datetime.date(2016, 1, 1)
date2 = datetime.date(2020, 2, 1)
url_list = []

while date1 < date2:
    print(date1)
    iso = re.sub("-", "", date1.isoformat())
    url_list += url_bydate(keyword, iso + '000000', iso + '235959')
    date1 += timedelta(days=+1)

with open('data_raw/url/daum/url_list_daum.csv', 'w', encoding='utf8') as f:
    for url in url_list:
        f.write(url+'\n')

with open('data_raw/url/daum/url_list_daum.csv', 'r', encoding='utf8') as f:
    url_list = [re.sub('\n', '', i) for i in f.readlines()]


# 기사의 내용을 조금 걸러서 들여와보자
def articlepre(article):
    split = re.split("@", article)  # 기자의 메일주소를 기점으로 짤라내고
    if len(split) == 1:
        article = split[0]
    else:
        article = "".join(split[0:-1])
    split = re.split("▶", article)  # 이런 방식으로 뒤의 것들을 잘라낸다.
    if len(split) == 1:
        article = split[0]
    else:
        article = "".join(split[0:-1])
    split = re.split("©", article)
    if len(split) == 1:
        article = split[0]
    else:
        article = "".join(split[0:-1])
    split = re.split("모바일 경향", article)
    if len(split) == 1:
        article = split[0]
    else:
        article = "".join(split[0:-1])
    article = re.sub(
        "flash 오류를 우회하기 위한 함수 추가|function _flash_removeCallback|모바일 경향|"
        "공식 SNS 계정|[\{\}\[\]\/,;:|\)*`^\-_+<>@\#$%&\\\=\('\"]",
        " ",
        article,
    )
    article = re.sub("[a-zA-Z]|\n|\t|\r|▲|【|】|▶|©", "", article)

    return article


def extractarticle(url):
    user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.47 Safari/537.36'
    headers = {'User-Agent': user_agent}
    soup = BeautifulSoup(requests.get(url).text, 'lxml')
    try:
        pubtime = re.sub("\.", "-", re.findall("[0-9]{4}.[0-9]{2}.[0-9]{2}", soup.find_all('span', class_='txt_info')[-1].text)[0])
        press = soup.find('meta', {"name" : "article:media_name"}).get('content')
        title = soup.find('h3', class_='tit_view').text
        article = soup.find('div', class_='news_view').text
    except:
        print(f"{url} is not extracted")

    return url, pubtime, press, title, article

result = []

for i, url in enumerate(url_list):
    if i%100 == 0:
        print(f'{round(i/len(url_list)*100, 2)}% Done')
    result.append(list(extractarticle(url)))

url = [i[0] for i in result]
pubtime = [i[1] for i in result]
press = [i[2] for i in result]
title = [i[3] for i in result]
article = [i[4] for i in result]

import pandas as pd

# df = DataFrame(result).transpose()
df = pd.DataFrame({'url':url, 'pubtime':pubtime, 'press':press, 'title':title, 'article':article})
article = [articlepre(i) for i in list(df['article'])]
df['article'] = article
title = [articlepre(i) for i in list(df['title'])]
df['title'] = title

df.head()
df.to_csv('data_raw/article/daum_news_article.csv')
