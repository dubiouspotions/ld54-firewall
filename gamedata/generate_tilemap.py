from xml.etree import ElementTree

document = ElementTree.parse('level1.tmx')
tilemap = document.getroot()
tileset = tilemap.find("tileset")
firstlayer = tilemap.find("layer")
firstdata = firstlayer.find("data")
for num in firstdata.text.split(","):
    print(int(num)-1, end=",")
