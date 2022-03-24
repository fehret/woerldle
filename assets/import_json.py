import json
import numpy as np
from itertools import chain
import pandas as pd
import os

data = json.load(open("C:\\Users\\fmila\\OneDrive\\Dokumente\\GitHub\\woerldle\\assets\\countries.geojson"))

lens = list()
names = list()

for count in data:


    df = pd.DataFrame(chain.from_iterable(list(chain.from_iterable(count["geometry"]["coordinates"]))))

    res = {
        "name"          : count["properties"]["ADMIN"],
        "short"         : count["properties"]["ISO_A2"].lower(),
        "geometry"      : count["geometry"]["coordinates"],
        "top_left"      : [df.iloc[:,0].max(),df.iloc[:,1].min()],
        "top_right"     : [df.iloc[:,0].max(),df.iloc[:,1].max()],
        "bot_left"      : [df.iloc[:,0].min(),df.iloc[:,1].min()],
        "bot_right"     : [df.iloc[:,0].min(),df.iloc[:,1].max()],
        "canvas_latlon_ratio"  : (df.iloc[:,0].max()-df.iloc[:,0].min())/(df.iloc[:,1].max()-df.iloc[:,1].min()),
        "middle"        : df.mean().to_list()
    }

    with open('C:\\Users\\fmila\\OneDrive\\Dokumente\\GitHub\\woerldle\\assets\\countries\\' + count["properties"]["ADMIN"].lower() + '.json', 'w') as f:
        f.write(str(res).replace('\'',"\""))
