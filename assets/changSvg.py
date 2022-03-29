import os
import re
from sys import flags
import json

borders = [o for o in os.listdir("C:\\Users\\fmila\\GitHub\\woerldle\\assets\\borders") if "svg" in o]
flags   = [o for o in os.listdir("C:\\Users\\fmila\\GitHub\\woerldle\\assets\\flags")   if "svg" in o]

with open("C:\\Users\\fmila\\GitHub\\woerldle\\assets\\countries.json", "r") as f:
    countries = json.load(f)

countries.sort(key=lambda x: x["cca2"].lower())

for border in borders:
    if not border in flags:
        print(border)


'''
for idx in range(len(countries)):

    if countries[idx]["cca2"].lower() != borders[idx][:2]:
        print(countries[idx]["name"]["common"])
        print( "country: " + countries[idx]["cca2"].lower() + "  border: " + borders[idx] + "  flag: " + flags[idx])
        print( "country: " + countries[idx+1]["cca2"].lower() + "  border: " + borders[idx+1] + "  flag: " + flags[idx+1])        
        print("d")
if("svg" in file):
        with open(path + "\\" + file, "r") as f:
            data = f.read()
        
        with open(path + "\\" + file, "w") as f:
            data = data.replace("pt\"", "px\"")
            replaced = re.sub("(preserveAspectRatio|xmlns|version)=\"[^\"]*\"|<!DOCTYPE[^\<]*>|<\?xml[^\<]*>", "", data)
            f.write(replaced)
    '''
    

