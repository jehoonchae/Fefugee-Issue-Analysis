from bs4 import BeautifulSoup
from urllib.request import urlopen
import requests
from selenium import webdriver
from tqdm import notebook

import os
import time
import random
import re
import pickle
import csv

os.chdir('/Users/jhchae/Dropbox/Pycharm/IC2S2-2020')
os.getcwd()

def get_articles(html):
    results = []
    soup = BeautifulSoup(html, 'lxml')
    lis = soup.find_all('li', attrs={'id':re.compile(r'sp_nws')})
    for li in lis:
        title='NA'
        naver_url = 'NA'
        pub = 'NA'
        date = 'NA'
        title = li.find('a', attrs={'class':re.compile(r'_sp_each_title')}).get('title').strip()
        if li.find('a', attrs={'class':re.compile(r'_sp_each_url')}).text:
            naver_url = li.find('a', attrs={'class':re.compile(r'_sp_each_url')}).get('href').strip()
        pub = li.find('span', attrs={'class':'_sp_each_source'}).text.strip()
        date = li.find('span', attrs={'class':'bar'}).next_sibling.strip()
        results.append([title, naver_url, pub,date])
        # print(title, naver_url, pub, date)
    return results

# Get the name of press served by Naver
def naver_served_news():
    html_press = 'https://news.naver.com/main/officeList.nhn'
    soup = BeautifulSoup(urlopen(html_press), 'lxml')
    press_categories = soup.findAll('ul', class_='group_list')
    press_categories = press_categories[:4]

    press_list = []
    for press_category in press_categories:
        for press in press_category.findAll('li'):
            # print(press.find('a').text)
            press_list.append(re.sub(r'\n', '', press.find('a').text))

    return press_list

# Headless mode 사용하기
# options = webdriver.ChromeOptions()
# options.add_argument('headless')
# options.add_argument('window-size=1920x1080')
# options.add_argument('window-size=1440x900')
# options.add_argument("disable-gpu")
# 혹은 options.add_argument("--disable-gpu")

# for i in range(0, 1600, 400):
#     print(i)
# for i in range(1600, 3200, 400):
#     print(i)
# for i in range(3200, 4800, 400):
#     print(i)
# for i in range(4800, 6400, 400):
#     print(i)

keyword = '난민'
start_date = '2016.01.01'
end_date = '2020.02.01'
pickle_path = 'raw_data/url.pickle'
chrome_path = r'/Users/jhchae/Dropbox/Pycharm/chromedriver_mac64/chromedriver'

def naver_url_scraper_selenium(keyword, start_date, end_date, chrome_path, pickle_path):

    with open(pickle_path, 'wb') as p:

        total_results = []
        date_list = [start_date]

        for _ in notebook.tqdm(range(17), desc='1st loop'):

            #driver = webdriver.Chrome(executable_path=r'C:\Users\Sang\Downloads\chromedriver_win32_1\chromedriver.exe')
            driver = webdriver.Chrome(executable_path=chrome_path)
            url = 'https://www.naver.com/'
            driver.get(url)
            sleep_time = random.random()*3
            time.sleep(sleep_time)
            url1 = 'https://search.naver.com/search.naver?query=q&where=news&ie=utf8&sm=nws_hty'
            driver.get(url1)

            # 검색옵션 누르기
            element0 = driver.find_element_by_id('_search_option_btn')
            element0.click()

            # 언론사 색션 누르기
            element = driver.find_element_by_xpath('/html/body/div[3]/div[1]/div[3]/div/ul/li[5]/a')
            element.click()
            time.sleep(0.5)

            #언론사 클릭하기
            html = driver.page_source
            soup = BeautifulSoup(html, 'lxml')
            soup.find('label', title=press).get('for')
            for press in naver_news_list:
                selector = '#' + soup.find('label', title=press).get('for')
                element = driver.find_element_by_css_selector(selector)
                element.click()
                time.sleep(0.1)

            # 확인 버튼 누르기
            element2 = driver.find_element_by_xpath('/html/body/div[3]/div[1]/div[3]/div/ul/li[5]/div/div[2]/div[3]/button[1]')
            element2.click()
            time.sleep(1)

            html = driver.page_source
            soup = BeautifulSoup(html, 'lxml')
            re.findall("[0-9]{4}.[0-9]{2}.[0-9]{2}", soup.findAll('dd', class_='txt_inline')[-1].text)[0]

            # re.sub("\.", "-", re.findall("[0-9]{4}.[0-9]{2}.[0-9]{2}", soup.findAll('dd', class_='txt_inline')[-1].text)[0])
            # re.sub("\.", "-", re.findall("[0-9]{4}.[0-9]{2}.[0-9]{2}", soup.find('span', {'class': 't11'}).text)[0])
            # 쿼리 단어와 검색 기간 검색
            q = keyword
            startDate = date_list[-1]
            endDate = end_date

            # 한번에 가져올 수 있는 기사의 수는 4,000개가 max
            # pickle_name = q+'_'+startDate+'_'+endDate+'.p'
            for j, page in notebook.tqdm(enumerate(range(400)), desc='2nd loop'):
                sleep_time = random.random()*5
                time.sleep(sleep_time)
                start = page*10 + 1
                url = 'https://search.naver.com/search.naver?&where=news&query='+q+\
                      '&sm=tab_pge&sort=2&photo=0&field=0&reporter_article=&pd=3&ds='+\
                      startDate+'&de='+endDate+'&mynews=1&refresh_start=0&start='+str(start)
                driver.get(url)
                html1 = driver.page_source
                soup1 = BeautifulSoup(html1, 'lxml')
                date1 = re.findall("[0-9]{4}.[0-9]{2}.[0-9]{2}", soup1.findAll('dd', class_='txt_inline')[-1].text)[0]
                if j == 399:
                    date_list.append(date1)
                if re.search(r'검색결과가 없습니다',html1):
                    break
                results = get_articles(html1)
                print(page, results, len(results))
                total_results.extend(results)

            driver.close()

        pickle.dump(total_results, p)

    return total_results


import pandas as pd

df = pd.DataFrame(total_results, columns=['title', 'url', 'publisher', 'date'])
df = df.drop_duplicates()
df['publisher'] = df['publisher'].str.replace('언론사 선정', '')
csv_path = 'raw_data/url.csv'
df = pd.read_csv(csv_path)

url_list = list(df['url'])

# with open('data/url/url_list.pickle', 'rb') as p:
#     data = pickle.load(p)


# pre-processing the text of the data
def articlepre(article):
    split=re.split("@",article)
    if len(split)==1:
        article=split[0]
    else: article="".join(split[0:-1])
    split = re.split("▶", article)
    if len(split) == 1:
        article = split[0]
    else:
        article = "".join(split[0:-1])
    split=re.split("©",article)
    if len(split)==1:
        article=split[0]
    else: article="".join(split[0:-1])
    split=re.split("모바일 경향",article)
    if len(split)==1:
        article=split[0]
    else: article="".join(split[0:-1])
    article=re.sub("flash 오류를 우회하기 위한 함수 추가|function _flash_removeCallback|모바일 경향|"
                   "공식 SNS 계정|[\{\}\[\]\/,;:|\)*`^\-_+<>@\#$%&\\\=\(\'\"]"," ",article)
    article=re.sub('[a-zA-Z]|\n|\t|\r|▲|【|】|▶|©', '', article)

    return article

def naver_news_extractor(url_list, file_path):
    with open(file_path, 'w', encoding='utf8', newline="") as f:

        writer = csv.writer(f)
        writer.writerow(['url', 'date', 'press', 'title', 'article'])

        url_data = []
        date_list = []
        press_list = []
        title_list = []
        article_list = []

        for url in notebook.tqdm(url_list):
            # soup = BeautifulSoup(requests.get(url).text, 'lxml')
            soup = BeautifulSoup(urlopen(url), 'lxml')
            try:
                if soup.find('span', class_='t11')==None and soup.find('span', class_="author")==None:
                    date = re.sub("\.", "-", re.findall("[0-9]{4}.[0-9]{2}.[0-9]{2}", soup.find('div', class_="info").text)[0])
                    press = soup.find('span', id='pressLogo').find('img')['alt']
                    title = articlepre(soup.find("h4", class_="title").text)
                    article = articlepre(soup.find('div', id="newsEndContents").text)
                elif soup.find('span', class_='t11')==None:
                    date = re.sub("\.", "-", re.findall("[0-9]{4}.[0-9]{2}.[0-9]{2}", soup.find('span', class_="author").text)[0])
                    press = soup.find('div', class_="press_logo").find('img')['alt']
                    title = articlepre(soup.find("h2", class_="end_tit").text)
                    article = articlepre(soup.find('div', id="articeBody").text)
                else:
                    date = re.sub("\.", "-", re.findall("[0-9]{4}.[0-9]{2}.[0-9]{2}", soup.find('span', class_="t11").text)[0])
                    press = soup.find('div', class_="article_header").find('img')['title']
                    title = articlepre(soup.find("h3", id="articleTitle").text)
                    article = articlepre(soup.find('div', class_="_article_body_contents").text)

                url_data.append(url)
                date_list.append(date)
                press_list.append(press)
                title_list.append(title)
                article_list.append(article)

                writer.writerow([url, date, press, title, article])

            except AttributeError as e:
                print('pass')


with open('data/url/url_list.csv', 'w', encoding='utf8') as f:
    for url in url_list:
        soup = BeautifulSoup(urlopen(url), 'lxml')
        try:
            title = articlepre(soup.find('meta', property="og:title").get('content'))
            article = articlepre(soup.find('div', {'id': 'articleBodyContents'}).text).split('조선')[0]
            article = re.sub('동영상 뉴스|앵커', '', article).strip()
            date = re.sub("\.", "-", re.findall("[0-9]{4}.[0-9]{2}.[0-9]{2}",
                                                   soup.find('span', {'class': 't11'}).text)[0])
            press = soup.find("meta", property="me2:category1").get('content')
            f.write(date + ',' + press + ',' + title + ',' + article + '\n')
        except AttributeError as e:
            print("pass!!!!!")




file_path = 'data/article/article.csv'

naver_news_list = naver_served_news()

news_article = pd.read_csv('data/article/article.csv')
news_comment = pd.read_csv('data/comment/comment.csv')
merged_df = pd.merge(news_article, news_comment)
merged_df.to_csv('data/merged.csv', index = False)
