from bs4 import BeautifulSoup
import urllib.request
import unicodecsv as csv

errors = []
row = {'id_player_fifa':0, 'position':''}
with open("../data/player_positions.csv", "wb") as csvfile:
	fieldnames = ['id_player_fifa', 'position'] 
	writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
	writer.writeheader()

	with open("../data/ids.txt", "r") as ids_file:
		ids = ids_file.readlines()
		for i in ids:#ids
			with open("../data/html/" + i.strip(), encoding='utf8') as fp:
				soup = BeautifulSoup(fp)
				try:
					position = soup.findAll('ul', attrs={ "class" : "pl"})[1].find_all('span')[1].text
					row['id_player_fifa'] = int(i)
					row['position'] = position
					writer.writerow(row)
				except Exception as e:
					errors.append(i)
					pass
#print ids that wasn't possible to extract position
print(errors)
				