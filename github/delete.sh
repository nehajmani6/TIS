from pymongo import MongoClient 
import json
import datetime

client = MongoClient(username='admin',password='admin123')
db = client.firehol
coll_list=db.list_collection_names()

for i in coll_list:
	db[i].remove({"date": create(2018,07,06)})
