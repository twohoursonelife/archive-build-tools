const execSync = require('child_process').execSync;
const fs = require('fs');

if (!process.argv[2]) {
  console.log(`Run with node ${process.argv[1]} <start_number> <offset?> <end_number?>`);
  return;
}


const sourceNumber = Number(process.argv[2]);
let startNumber = 0;
let offset = 0;
let endNumber = null;
let highestId = 0;
if (process.argv[3]) {
  startNumber = sourceNumber;
  offset = Number(process.argv[3]);
}
if (process.argv[4]) {
  endNumber = Number(process.argv[4]);
}

let spriteIds = [];

console.log('Reading sprite files');
const spriteFileList = execSync('ls sprites').toString().split('\n');

if (!process.argv[3]) {
  for (const file of spriteFileList) {
    if (!file || isNaN(parseInt(file[0]))) {
      continue;
    }
    if (!file.endsWith('.txt')) {
      continue;
    }
    const thisId = Number(file.replace('.txt', ''));
    if (thisId + 1 < sourceNumber) {
      startNumber = Math.max(startNumber, thisId + 1);
    }
  }
  offset = startNumber - sourceNumber;
}

for (const file of spriteFileList) {
  if (!file || isNaN(parseInt(file[0]))) {
    continue;
  }
  if (!file.endsWith('.txt')) {
    continue;
  }
  const thisId = Number(file.replace('.txt', ''));
  if (thisId >= startNumber && (endNumber === null || thisId <= endNumber)) {
    spriteIds.push(thisId);
    highestId = Math.max( highestId, thisId + offset);
  }
}

console.log('Moving sprite files');
for (const id of spriteIds) {
  execSync(`mv sprites/${id}.txt sprites/new_${id + offset}.txt`);
  execSync(`mv sprites/${id}.tga sprites/new_${id + offset}.tga`);
}

for (const id of spriteIds) {
  execSync(`mv sprites/new_${id + offset}.txt sprites/${id + offset}.txt`);
  execSync(`mv sprites/new_${id + offset}.tga sprites/${id + offset}.tga`);
}

if (process.argv[3]) {
  fs.writeFileSync(`sprites/nextSpriteNumber.txt`, highestId + 1);
} else {
  fs.writeFileSync(`sprites/nextSpriteNumber.txt`, sourceNumber);
}

console.log('Reading object files');
const objectFileList = execSync('ls objects').toString().split('\n');

console.log('Updating object files');
for (const file of objectFileList) {
  if (!file || isNaN(parseInt(file[0]))) {
    continue;
  }
  let fileContent = fs.readFileSync(`objects/${file}`).toString();
  const spriteMatch = fileContent.match(/spriteID=(\d+)?\r?\n/g);
  let spriteIds = [];
  let needsReplacing = false;
  for (const match of spriteMatch) {
    const spriteId = Number(match.match(/spriteID=(\d+)?/)[1]);
    if (spriteId >= startNumber && (endNumber === null || spriteId <= endNumber)) {
      needsReplacing = true;
      spriteIds.push(spriteId);
    }
  }
  for (const id of spriteIds) {
    fileContent = fileContent.replace(`spriteID=${id}`, `spriteID=${id + offset}`);
  }
  if (needsReplacing) {
    fs.writeFileSync(`objects/${file}`, fileContent);
  }
}
