import json
import numpy as np
from itertools import chain
import pandas as pd
import os

rel = "C:\\Users\\fmila\\OneDrive\\Dokumente\\GitHub\\woerldle\\assets\\svg"

list = os.listdir(rel)

for el in list:
    if(not "desktop" in el and not "index" in el and not "State" in el):
        os.rename(rel + "\\" + el + "\\" + el ,  rel + "\\" + el + "\\" + el + ".svg")
