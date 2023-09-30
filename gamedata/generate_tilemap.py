from xml.etree import ElementTree

document = ElementTree.parse('level1.tmx')
tilemap = document.getroot().find("map")
tileset = tilemap.find("tileset")
firstlayer = tilemap.find("layer")
firstdata = firstlayer.find("data")
print(firstdata)