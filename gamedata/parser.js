const fs = require('fs');

const getValuesAsArray = (fileName) => {
  try {
    const data = fs.readFileSync(__dirname + '/' + fileName, 'utf8');
    const dataRegEx = /<data encoding="csv">([\s\S]*?)<\/data>/;
    const dataMatch = data.match(dataRegEx);
    const csvContent = dataMatch[1].trim();
    const values= csvContent.split(',').map(Number);
    
    const heightRegEx = /height="([\s\S]*?)"/;
    const heightMatch = data.match(heightRegEx);

    const widthRegEx = /width="([\s\S]*?)"/;
    const widthMatch = data.match(widthRegEx);

    return {values, weight: Number(widthMatch[1]), height: Number(heightMatch[1])}
  } catch (err) {
    console.error(err);
  }
}

const fileName = (process.argv[2] && process.argv[2].includes('tmx')) ? process.argv[2] : 'level1.tmx'
const {values, weight, height} = getValuesAsArray(fileName)

const correctNumbers = values.map((value) => value - 1);
fs.writeFileSync(__dirname + '/tilemap', correctNumbers.join(','));


