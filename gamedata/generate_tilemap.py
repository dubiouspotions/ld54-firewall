from xml.etree import ElementTree
import sys

document = ElementTree.parse(sys.argv[1])
tilemap = document.getroot()
tileset = tilemap.find("tileset")
firstlayer = tilemap.find("layer")
firstdata = firstlayer.find("data")
for num in firstdata.text.split(","):
    print(int(num)-1, end=",")
