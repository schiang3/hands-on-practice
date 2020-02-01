# -*- coding: utf-8 -*-
"""
Created on Fri Jun 14 00:21:17 2019

@author: Shuya C
"""
import urllib, time, json, sqlite3
from sqlite3 import OperationalError
import os
conn = sqlite3.connect('takehomefinal.db')
c = conn.cursor()
os.chdir('C:/Users/Shuya C/Desktop/depaul/DSC 450')
#a
userTable = '''CREATE TABLE User(
               id NUMBER(20),
               name VARCHAR(40),
               screen_name VARCHAR(40),
               description VARCHAR(200),
               friends_count NUMBER,
               PRIMARY KEY (ID));'''
geoTable = '''CREATE TABLE Geo (
               id  INTEGER PRIMARY KEY,
               geoType VARCHAR(12),
               longitude VARCHAR(60) ,
               latitude VARCHAR(60));'''
tweetTable = '''CREATE TABLE Tweets (
                 id          NUMBER(20),
                 Created_At  DATE,
                 Text        CHAR(140),
                 Source VARCHAR(200) DEFAULT NULL,
                 In_Reply_to_User_ID NUMBER(20),
                 In_Reply_to_Screen_Name VARCHAR(60),
                 In_Reply_to_Status_ID NUMBER(20),
                 Retweet_Count NUMBER(10),
                 Contributors  VARCHAR(200),
                 user_id  NUMBER(20),
                 geo_id VARCHAR(20),
                 CONSTRAINT Tweets_PK  PRIMARY KEY (id),
                 CONSTRAINT Tweets_FK1 FOREIGN KEY (user_id)
                     REFERENCES User(id),
                      CONSTRAINT Tweets_FK2 FOREIGN KEY (geo_id)
                     REFERENCES Geo(id));'''
c.execute('DROP TABLE IF EXISTS Tweets');
c.execute('DROP TABLE IF EXISTS User');
c.execute('DROP TABLE IF EXISTS Geo');
c.execute(userTable)
c.execute(geoTable)
c.execute(tweetTable)
#b
wFD = urllib.request.urlopen("http://rasinsrv07.cstcis.cti.depaul.edu/CSC455/OneDayOfTweets.txt")
df= open("Take_Home_F.txt", "w", encoding="utf8")
loadCounter = 0
start = time.time()
for i in range(1000000):
    ln = wFD.readline()
    df.write(ln.decode())
    loadCounter+=1
stop = time.time()
print ("Difference is ", (stop-start), 'seconds')
print('total load ',loadCounter)
#c
fdErr = open('takeh_error.txt', 'w', errors = 'replace')
start2 = time.time()
for i in range(1000000):
    line = wFD.readline()
    try:  
        tweetDict = json.loads(line) # This is the dictionary for tweet info
    except ValueError:  # Handle the error of JSON parsing
        fdErr.write(line.decode() + '\n')        
    else:
        newRowGeo=[]
        geoDict= tweetDict['geo']
        #geoKeys=['type','coordinates']
        #for key in geoKeys: # For each dictionary key we want
        if geoDict== None:
            newRowGeo.append(i)
            newRowGeo.append(None) 
            newRowGeo.append(None)
            newRowGeo.append(None)# proper NULL
        else:
            newRowGeo.append(i)
            newRowGeo.append(geoDict['type']) 
            newRowGeo.append(geoDict['coordinates'][0]) 
            newRowGeo.append(geoDict['coordinates'][1])# use value as-is
        #c.executemany ('''INSERT OR IGNORE INTO Geo(geoType,longitude,latitude) VALUES(?,?,?) ''', newRowGeo)
        c.executemany ('''INSERT OR IGNORE INTO Geo VALUES(?,?,?,?) ''', (newRowGeo,))
        newRowUser = [] # hold individual values of to-be-inserted row for user table
        userKeys = ['id', 'name', 'screen_name', 'description', 'friends_count']
        userDict = tweetDict['user'] 
        for key in userKeys: # For each dictionary key we want
            if userDict[key] == 'null' or userDict[key] == '':
                newRowUser.append(None)   # proper NULL
            else:
                newRowUser.append(userDict[key]) # use value as-is
        c.executemany ('INSERT OR IGNORE INTO User VALUES(?,?,?,?,?)', (newRowUser,))
        newRowTweet = [] # hold individual values of to-be-inserted row
        tweetKeys = ['id_str','created_at','text','source','in_reply_to_user_id', 
                     'in_reply_to_screen_name', 'in_reply_to_status_id', 'retweet_count', 'contributors']
        for key in tweetKeys: # For each dictionary key we want
            if tweetDict[key] == 'null' or tweetDict[key] == '':
                newRowTweet.append(None)   # proper NULL
            else:
                newRowTweet.append(tweetDict[key]) # use value as-is
        userDict = tweetDict['user'] # This the the dictionary for user information
        newRowTweet.append(userDict['id']) # User id/ foreign key
        newRowTweet.append(i)
        c.executemany ('INSERT OR IGNORE INTO Tweets VALUES(?,?,?,?,?,?,?,?,?,?,?)', (newRowTweet,))
stop2 = time.time()
print ("Difference is ", (stop2-start2), 'seconds')
c.execute('''select count(*) from Geo;''').fetchall()
c.execute('''select count(*)from Tweets;''').fetchall()
c.execute('''select count(*)from User;''').fetchall()
c.execute('''select*from User;''').fetchall()
c.execute('''select*from Tweets;''').fetchall()
c.execute('''select*from Geo;''').fetchall()
#d
fdErr = open('takeh_error.txt', 'w', errors = 'replace')
t_file = open("Take_Home_F.txt", encoding="utf8")
start3 = time.time()
for i in range(1000000):        
    if i % 100 == 0: # Print a message every 100th tweet read
        print ("Processed " + str(i) + " tweets")
    line = t_file.readline()
    try:  
        tweetDict = json.loads(line) 
    except ValueError:  # Handle the error of JSON parsing
        fdErr.write(line+'\n')      
    else:
        newRGeo=[]
        geoDict= tweetDict['geo']
        if geoDict== None:
            newRGeo.append(i)
            newRGeo.append(None) 
            newRGeo.append(None)
            newRGeo.append(None)
        else:
            newRGeo.append(i)
            newRGeo.append(geoDict['type']) 
            newRGeo.append(geoDict['coordinates'][0]) 
            newRGeo.append(geoDict['coordinates'][1])
        c.executemany ('''INSERT OR IGNORE INTO Geo VALUES(?,?,?,?) ''', (newRGeo,))
        newRUser = []
        userKeys = ['id', 'name', 'screen_name', 'description', 'friends_count']
        userDict = tweetDict['user'] 
        for key in userKeys: # For each dictionary key we want
            if userDict[key] == 'null' or userDict[key] == '':
                newRUser.append(None)
            else:
                newRUser.append(userDict[key]) # use value as-is
        c.executemany ('INSERT OR IGNORE INTO User VALUES(?,?,?,?,?)', (newRUser,))
        newRowTweet = [] # hold individual values of to-be-inserted row
        tweetKeys = ['id_str','created_at','text','source','in_reply_to_user_id', 
                     'in_reply_to_screen_name', 'in_reply_to_status_id', 'retweet_count', 'contributors']
        for key in tweetKeys: # For each dictionary key we want
            if tweetDict[key] == 'null' or tweetDict[key] == '':
                newRowTweet.append(None)   # proper NULL
            else:
                newRowTweet.append(tweetDict[key]) # use value as-is
        newRowTweet.append(userDict['id']) # User id/ foreign key
        newRowTweet.append(i)
        c.executemany ('INSERT OR IGNORE INTO Tweets VALUES(?,?,?,?,?,?,?,?,?,?,?)', (newRowTweet,))
stop3 = time.time()
print ("Difference is ", (stop3-start3), 'seconds')
c.execute('''select count(*) from Geo;''').fetchall()
c.execute('''select count(*)from Tweets;''').fetchall()
c.execute('''select count(*)from User;''').fetchall()
#e
tweetBatch = []
userBatch = []
geoBatch=[]
loadC=0
startt = time.time()
for i in range(1000000):        
    line = t_file.readline()
    try:  
        tweetDict = json.loads(line) 
        loadC = loadC + 1
    except ValueError:  # Handle the error of JSON parsing
        fdErr.write(line+'\n')      
    else:
        newRGeo=[]
        geoDict= tweetDict['geo']
        if geoDict== None:
            newRGeo.append(i)
            newRGeo.append(None) 
            newRGeo.append(None)
            newRGeo.append(None)
        else:
            newRGeo.append(i)
            newRGeo.append(geoDict['type']) 
            newRGeo.append(geoDict['coordinates'][0]) 
            newRGeo.append(geoDict['coordinates'][1])
        if loadCounter <1000:
            geoBatch.append(newRGeo)
        else:
            c.executemany ('''INSERT OR IGNORE INTO Geo VALUES(?,?,?,?) ''', geoBatch)
            geoBatch=[]
        newRUser = []
        userKeys = ['id', 'name', 'screen_name', 'description', 'friends_count']
        userDict = tweetDict['user'] 
        for key in userKeys: # For each dictionary key we want
            if userDict[key] == 'null' or userDict[key] == '':
                newRUser.append(None)
            else:
                newRUser.append(userDict[key]) # use value as-is
        if loadCounter <1000:
            userBatch.append(newRowUser)
        else:
            c.executemany ('INSERT OR IGNORE INTO User VALUES(?,?,?,?,?)', userBatch)
            userBatch = [] # Reset the list of batched users
        newRowTweet = [] # hold individual values of to-be-inserted row
        tweetKeys = ['id_str','created_at','text','source','in_reply_to_user_id', 
                     'in_reply_to_screen_name', 'in_reply_to_status_id', 'retweet_count', 'contributors']
        for key in tweetKeys: # For each dictionary key we want
            if tweetDict[key] == 'null' or tweetDict[key] == '':
                newRowTweet.append(None)   # proper NULL
            else:
                newRowTweet.append(tweetDict[key]) # use value as-is
        newRowTweet.append(userDict['id']) # User id/ foreign key
        newRowTweet.append(i)
        if loadCounter < 1000: 
            tweetBatch.append(newRowTweet)
        else:
            c.executemany ('INSERT OR IGNORE INTO Tweets VALUES(?,?,?,?,?,?,?,?,?,?,?)', tweetBatch)
            tweetBatch = [] # Reset the list of batched tweets
            loadC = 0
stopt = time.time()
print ("Difference is ", (stopt-startt), 'seconds')
#2ai
start4 = time.time()
c.execute('''select id from Tweets where id like '%55%' or '%88%';''').fetchall()
stop4 = time.time()
print ("Difference is ", (stop4-start4), 'seconds')
#2aii
start5 = time.time()
c.execute(''' SELECT count (DISTINCT In_Reply_to_User_ID) from Tweets;''').fetchall()
stop5 = time.time()
print ("Difference is ", (stop5-start5), 'seconds')
#2aiii
start6 = time.time()
c.execute('''select distinct text, avg(length(text))  FROM tweets;''').fetchall()
c.execute('''select distinct text, length(text)  FROM tweets
 where length(text)= (select max(length(text)) from tweets) 
 or length(text)= (select min(length(text)) from tweets);''').fetchall()
stop6 = time.time()
print ("Difference is ", (stop6-start6), 'seconds')
#2iv
start7 = time.time()
c.execute('''select avg(Geo.longitude), avg(Geo.latitude),name from User
          inner join Tweets on  Tweets.user_id= User.id
          inner join Geo on Tweets.geo_id= geo.id group by name;''').fetchall()
stop7 = time.time()
print ("Difference is ", (stop7-start7), 'seconds')
#2v.
start8 = time.time()
c.execute('''
SELECT SUM(CASE WHEN  longitude is NULL THEN 1 ELSE 0 END) AS unknown,
       Count(latitude) AS known,
       (1.0* Count(latitude)/Count(*)) 
from geo ''').fetchall()
stop8 = time.time()
print ("Time is ", (stop8-start8), 'seconds')
#2avi
start9 = time.time()
for i in range(10):
    c.execute('''select avg(Geo.longitude), avg(Geo.latitude),name from User
          inner join Tweets on  Tweets.user_id= User.id
          inner join Geo on Tweets.geo_id= geo.id group by name''')
stop9= time.time()
print ("Time is ", (stop9-start9), 'seconds')
start10 = time.time()
for i in range(100):
    c.execute('''select avg(Geo.longitude), avg(Geo.latitude),name from User
          inner join Tweets on  Tweets.user_id= User.id
          inner join Geo on Tweets.geo_id= geo.id group by name''')
stop10= time.time()
print ("Time is ", (stop10-start10), 'seconds')
#2b

#2bii
count=0
reply=set()
t_file = open("Take_Home_F.txt", encoding="utf8")
startt = time.time()
for i in range(1000000):        
    line = t_file.readline()
    try:  
        tweetDict = json.loads(line) 
              
    except ValueError: 
        fdErr.write(line+'\n')   
    else:
        inreply_id = tweetDict['in_reply_to_user_id']  
        if inreply_id !=None:
            reply.add(inreply_id)
            count+=1
print(len(reply))
print(count)
stoptt = time.time()
print ("It takes ", (stoptt-startt), 'seconds')
print('There are ' , len(reply) , 'unique values.')
#3a.
user_f=open("user_gen_insert.txt", "w", encoding="utf8")
startt1 = time.time()
utblRows=c.execute('''select * from User;''').fetchall()
for i in range(len(utblRows)):
    r=[utblRows[i]]
    user_f.write("INSERT INTO User VALUES {};\n" .format(tuple([chr(ord('a')+i)]+r)))
stoptt1 = time.time()
print ("It takes ", (stoptt1-startt1), 'seconds')
user_f.close()
#3b
fdErr = open('takeh_error.txt', 'w', errors = 'replace')
user_fp = open("user_gen_insertp.txt", "w", encoding="utf8")
t_file = open("Take_Home_F.txt", encoding="utf8")
start3b = time.time()
for i in range(1000000):        
    line = t_file.readline()
    try:  
        tweetDict = json.loads(line) 
    except ValueError:  # Handle the error of JSON parsing
        fdErr.write(line+'\n')   
    else:
        newRUser = []
        userKeys = ['id', 'name', 'screen_name', 'description', 'friends_count']
        userDict = tweetDict['user'] 
        for key in userKeys: # For each dictionary key we want
            if userDict[key] == 'null' or userDict[key] == '':
                newRUser.append(None)
            else:
                newRUser.append(userDict[key]) # use value as-is
        user_fp.write("INSERT INTO User VALUES {};\n" .format(tuple([chr(ord('a')+i)]+newRUser)))
stop3b = time.time()
print ("It takes ", (stop3b-start3b), 'seconds')
fdErr.close()
t_file.close()
user_fp.close()
#4a
#CDM (41.878668, -87.625555). 
c.execute('''ALTER TABLE Geo ADD column relative_distance VARCHAR(60);''');
#testing code
c.execute(''' INSERT INTO Geo (relative_distance) 
select (round((((longitude-41.878668)*2 +(latitude-87.625555)*2 )*0.5 ),4)) 
 from Geo  ;''')

#solution
a=c.execute(''' select id, geoType,round(longitude,4),round(latitude,4),
 round((((longitude-41.878668)*2 +(latitude-87.625555)*2 )*0.5 ),4) AS relative_distance 
 from Geo ;''')
fg = open('Geo_table.txt', 'w', encoding="utf8")
for row in a:
  fg.write(str(row[0]) + '|' + str(row[1]) + '|' + str(row[2])+ '|' + str(row[3])
          + '|'+ str(row[4])  +'\n')

#4b
c.execute('''ALTER TABLE Tweets 
          ADD column Username VARCHAR(40) ; ''');
c.execute('''ALTER TABLE Tweets          
          ADD column userscreen_name VARCHAR(40) ;''');

c.execute('''
INSERT INTO Tweets (Username, userscreen_name)
SELECT 
     User.name, User.screen_name
FROM 
     User, tweets where user.id = Tweets.user_id ; ''')
c.execute(''' select Username, userscreen_name from Tweets where Username is not null ''').fetchall()
bd=c.execute(''' select * from Tweets''')
fb = open('Tweets_tab.txt', 'w', encoding="utf8")
for row in bd:
  fb.write(str(row[0]) + '|' + str(row[1]) + '|' + str(row[2])+ '|' + str(row[3])
          + '|'+ str(row[4]) + '|' + str(row[5]) + '|' + str(row[6])+ '|' + str(row[7]) 
          + '|'+ str(row[8]) + '|' + str(row[9]) + '|' + str(row[10])+ '|' + str(row[11])
          + '|'+ str(row[12]) +'\n')


#4c
data = c.execute(''' select user.id,name,screen_name,description ,friends_count, 
  count(tweets.user_id) AS Active from User, Tweets where user.id = Tweets.user_id 
group by user.id ''')
f = open('user_table_active.txt', 'w', encoding="utf8")
print (f, "id|name|screen_name|description |friends_count  ")
for row in data:
  f.write(str(row[0]) + '|' + str(row[1]) + '|' + str(row[2])+ '|' + str(row[3])
  + '|'+ str(row[4])+'|' + str(row[5]) +'\n')