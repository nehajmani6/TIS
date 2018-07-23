from pymongo import MongoClient 
import json
import subprocess
import os
import pprint
import datetime
import sys

def create(y,m,d):
	return datetime.datetime(y,m,d)

def generate():
	uniq=datetime.datetime.now().strftime("%Y%m%d")
	uniq=int(uniq)
	date=uniq%100
	uniq/=100
	month=uniq%100
	year=uniq/100
	d=create(year,month,date)
	return d

client = MongoClient(username='admin',password='admin123')
db = client.firehol

# subprocess.call("./pull.sh")

folder='temp'
#folder='temp_'+sys.argv[1]
os.chdir(folder)
print "Using "+folder

date=generate()
#date=create(2018,07,int(sys.argv[1]))
print "Date being used is"+str(date)

for ROOT,DIR,FILES in os.walk("."):
	for file in FILES:
		try:
			l=open(file,"r").read().splitlines()
			coll=file.split(".")[0]
			print "===================="+coll+"====================="
			count=0
			c_name=coll

			for i in l:
				db[c_name].insert({"category": coll,"date": date,"ip":i})
				count+=1
			print "Inserted "+str(count)+" for "+c_name
		except Exception as e:
			print e

