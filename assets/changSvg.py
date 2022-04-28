import os
import json

path = "C:\\Users\\fmila\\GitHub\\woerldle\\assets\\borders"

borders = [o for o in os.listdir("C:\\Users\\fmila\\GitHub\\woerldle\\assets\\borders") if "svg" in o]
flags   = [o for o in os.listdir("C:\\Users\\fmila\\GitHub\\woerldle\\assets\\flags")   if "svg" in o]

with open("C:\\Users\\fmila\\GitHub\\woerldle\\assets\\countries.json", "r") as f:
    countries = json.load(f)

with open("C:\\Users\\fmila\\GitHub\\woerldle\\assets\\facts.json", "r") as f:
    facts = json.load(f)

countries.sort(key=lambda x: x["cca2"].lower())

data = []

for country in countries:
    try: 
        facts[country["cca2"].lower()]
        data.append(country)
        data[-1]['facts'] = facts[country["cca2"].lower()]

        for idx, fact in enumerate(data[-1]['facts']):
            if fact is None:
                #print('Hund')
                data[-1]['facts'][idx] = 'NA'
            if fact == 'null':
                print('null')
                data[-1]['facts'][idx] = 'NA'

    except:
        data.append(country)
        data[-1]['facts'] = facts['fr']
        print(F"Das land {country['name']['common']}")


'''
for border in borders:
    if not border in flags:
        print(border)


for idx in range(len(countries)):

    if countries[idx]["cca2"].lower() != borders[idx][:2]:
        print(countries[idx]["name"]["common"])
        print( "country: " + countries[idx]["cca2"].lower() + "  border: " + borders[idx] + "  flag: " + flags[idx])
        print( "country: " + countries[idx+1]["cca2"].lower() + "  border: " + borders[idx+1] + "  flag: " + flags[idx+1])        
        print("d")

for border in borders:
    if("svg" in border):
        with open(path + "\\" + border, "r") as f:
            data = f.read()
        
        data = data.replace(</svg>


<svg  
 width="1024.000000px" height="1024.000000px" viewBox="0 0 1024.000000 1024.000000"
 >, "")
        #print(data)

'''
with open("C:\\Users\\fmila\\GitHub\\woerldle\\assets\\combined.json", "w") as f:
    f.write(json.dumps(data,indent=4))
    

