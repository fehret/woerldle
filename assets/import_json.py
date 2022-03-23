import json
import numpy as np

data = json.load(open("C:\\Users\\fmila\\OneDrive\\Dokumente\\GitHub\\woerldle\\assets\\countries.geojson"))

lens = list()
names = list()

for count in data:
    lens.append(len(json.dumps(count["geometry"]["coordinates"])))
    names.append(count["properties"]["ADMIN"])
    with open('C:\\Users\\fmila\\OneDrive\\Dokumente\\GitHub\\woerldle\\assets\\countries\\' + count["properties"]["ADMIN"].lower() + '.geojson', 'w') as f:
        f.write(str(count).replace('\'',"\""))

print(names[np.array(lens).argmax(axis=0)])