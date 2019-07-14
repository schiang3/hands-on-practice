'''
Shu-ya Chiang
03/05/2019
'I have not given or received any unauthorized assistance on this assignment'
'''
from urllib.parse import urljoin
from urllib.request import urlopen
from html.parser import HTMLParser
from collections import Counter
class Collector(HTMLParser):
    'collects hyperlink URLs into a list'
    def __init__(self, url):
        'initializes parser, the url, and a list'
        HTMLParser.__init__(self)
        self.url = url
        self.links = []
        self.words=[]
    def handle_starttag(self, tag, attrs):
        'collects hyperlink URLs in their absolute format'
        if tag == 'a':
            for attr in attrs:
                if attr[0] == 'href':
                    # construct absolute URL
                    #print(attr[1])
                    absolute = urljoin(self.url, attr[1])
                    if absolute[:26] == 'https://www.cdm.depaul.edu': # collect HTTP URLs only this host
                        self.links.append(absolute)                    
    def getLinks(self):
        'returns hyperlinks URLs in their absolute format'
        return self.links
    def handle_data(self,data):
        d=(data.split())#data includes words are combining alphabet and numbers 
        for w in d:
            if w.isalpha()==True:#if word is alphabet add into words list
                self.words.append(w)#a list of alphabet words
        
    def getData(self):
        'return words'
        return self.words
        
visited=set()
freq={}#dict
def analyze(url):
    'returns list of http links in url in absolute format'
    global freq
    print('\n\nVisiting', url) 
    content=urlopen(url).read().decode().lower()
    collector=Collector(url)
    collector.feed(content)
    urls = collector.getLinks()
    # compute word frequencies
    wordlst = collector.getData()
    for item in wordlst:
        if (item in freq):
            freq[item]+=1 
        else:
            freq[item]=1
    #print(freq)
    #use collections.Counter.most_common to get top25 common words (sorted,faster)
    # print the top25 common words and thier count in web page
    c=Counter(freq)
    top25=c.most_common(25)
    print('\n{:20} {:5}'.format('word', 'count'))
    for word,count in top25:
        print('{:20} {:5}'.format(word, count))
    
    return urls
def crawl(url):
    'recursive web crawler that calls analyze() on every visited web page'
    global visited
    if len(visited)>500: #control only visited new 500 pages
        return
    visited.add(url)
    links = analyze(url)
    #recusively crawl from every link in links,follow link only if not visited
    for link in links:
        if link not in visited:
            try:
                crawl(link)
            except:
                pass
            
a=crawl('https://www.cdm.depaul.edu')
'''
word                 count
and                  14981
the                  12391
var                  12045
to                   11532
of                    7382
in                    6054
cdm                   5985
web                   5128
if                    5048
csc                   4958
admission             4942
for                   4580
function              3980
a                     3840
this                  3357
campus                3305
at                    3220
is                    3129
or                    2974
graduate              2903
resources             2810
depaul                2704
computing             2684
meeting               2629
loop                  2576
'''





    

