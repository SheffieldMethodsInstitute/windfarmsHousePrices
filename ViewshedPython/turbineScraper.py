from bs4 import BeautifulSoup
import requests
import pandas as pd
import numpy as np
import time

allDataz = []

#53 pages to get through. I should probably slow things down a little bit just in case...
for i in range(1,54):
	print('Getting page ' + str(i))

	#http://stackoverflow.com/questions/25067580/passing-web-data-into-beautiful-soup-empty-list
	r = requests.get(
		'http://www.renewableuk.com/en/renewable-energy/wind-energy/uk-wind-energy-database/index.cfm/page/' 
		+ str(i) + '/')

	time.sleep(3)

	#soup = BeautifulSoup(r.read().decode('utf-8', 'ignore'))

	s = BeautifulSoup(r.content, 'lxml')

	#s = BeautifulSoup(s.decode('utf-8','ignore'))
	#s = s.text.encode('utf-8')
	#s = s.prettify()

	#print(s.title)

	#Page structures everything in rows.
	#Heading rows in own div
	#Content rows all in an ordered list

	#http://stackoverflow.com/questions/25614702/get-contents-of-div-by-id-with-beautifulsoup
	#Only need headings once
	if(i == 1):
		headings = s.findAll('div', { "class":"layer-heading layer-clearfix"})

	type(headings[0])
	#Just the one result set
	hnames = headings[0].findAll(text=True)

	names = map(str,hnames) 

	#Strip out empty cells
	names = [name for name in names if name!=' ']

	# for n in names:
	# 	print(n)

	#Get content rows from ordered list
	rows = s.findAll('ol', {'class':'result-listing'})
	#print(type(rows))
	#print(type(rows[0]))

	#get whole ordered list contents
	ol = rows[0].findAll(text=True)

	ol = list(map(str,ol))

	#remove empty tags again
	ol = [i for i in ol if i!=' ']

	#Remove line returns
	ol = [line.strip('\r\n') for line in ol]

	#For looking at it and working out what to strip out etc 
	# for t in ol:
	# 	#Cos the page lied about some of the characters being utf-8
	# 	try:
	# 		print(t)
	# 		#print(len(t))
	# 	except UnicodeEncodeError:
	# 		print('harrumph' + str(t.encode('utf-8')))
	# 		#print( t.encode('utf-8') )

	#Now we have a list of rows
	allDataz += ol


#http://stackoverflow.com/questions/312443/how-do-you-split-a-list-into-evenly-sized-chunks-in-python
#Break the 1D list into separate rows so it can go straight into dataframe creation
dataIntoRows = [allDataz[i:i+10] for i in range(0, len(allDataz), 10)]

# print(type(test))

# for t in test:
# 	print(t)

# df = pd.DataFrame(np.random.randn(10, 10), columns=names)
df = pd.DataFrame(dataIntoRows, columns=names)

df.to_csv("Data/RenewablesUKTurbines.csv", index=False)

