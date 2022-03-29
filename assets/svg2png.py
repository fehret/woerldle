from svglib.svglib import svg2rlg
from reportlab.graphics import renderPM
import os

flag_path = "C:\\Users\\fmila\\GitHub\\woerldle\\assets\\borders"
flags     = [o for o in os.listdir(flag_path)   if "svg" in o]

for flag in flags:

    drawing = svg2rlg(flag_path + "\\" + flag)
    renderPM.drawToFile(drawing, flag_path + "\\" + flag.replace("svg","png"), fmt='PNG')