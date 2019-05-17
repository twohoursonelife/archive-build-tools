const execSync = require('child_process').execSync;
const fs = require('fs');

if (!process.argv[2]) {
  console.log(`Run with node ${process.argv[1]} <start_number> <offset?>`);
  return;
}


const sourceNumber = Number(process.argv[2]);
let startNumber = 0;
let offset = 0;
let highestId = 0;
if (process.argv[3]) {
  startNumber = sourceNumber;
  offset = Number(process.argv[3]);
}

let soundIds = [];

console.log('Reading sound files');
const soundFileList = execSync('ls ../sounds').toString().split('\n');

if (!process.argv[3]) {
  for (const file of soundFileList) {
    if (!file || isNaN(parseInt(file[0]))) {
      continue;
    }
    if (!file.endsWith('.aiff')) {
      continue;
    }
    const thisId = Number(file.replace('.aiff', ''));
    if (thisId + 1 < sourceNumber) {
      startNumber = Math.max(startNumber, thisId + 1);
    }
  }
  offset = startNumber - sourceNumber;
}

for (const file of soundFileList) {
  if (!file || isNaN(parseInt(file[0]))) {
    continue;
  }
  if (!file.endsWith('.aiff')) {
    continue;
  }
  const thisId = Number(file.replace('.aiff', ''));
  if (thisId >= startNumber) {
    soundIds.push(thisId);
    highestId = Math.max( highestId, thisId + offset);
  }
}

console.log('Moving sound files');
for (const id of soundIds) {
  execSync(`mv ../sounds/${id}.aiff ../sounds/new_${id + offset}.aiff`);
}

for (const id of soundIds) {
  execSync(`mv ../sounds/new_${id + offset}.aiff ../sounds/${id + offset}.aiff`);
}

if (process.argv[3]) {
  fs.writeFileSync(`../sounds/nextSoundNumber.txt`, highestId + 1);
} else {
  fs.writeFileSync(`../sounds/nextSoundNumber.txt`, sourceNumber);
}

console.log('Reading object files');
const objectFileList = execSync('ls ../objects').toString().split('\n');

console.log('Updating object files');
for (const file of objectFileList) {
  if (!file || isNaN(parseInt(file[0]))) {
    continue;
  }
  let fileContent = fs.readFileSync(`../objects/${file}`).toString();
  const soundMatch = fileContent.match(/([-]?\d+):/g);
  if (!soundMatch) {
    continue;
  }
  let soundIds = [];
  let needsReplacing = false;
  for (const match of soundMatch) {
    const soundId = Number(match.replace(':', ''));
    if (soundId >= startNumber) {
      needsReplacing = true;
      soundIds.push(soundId);
    }
  }
  for (const id of soundIds) {
    fileContent = fileContent.replace(`${id}:`, `${id + offset}:`);
  }
  if (needsReplacing) {
    fs.writeFileSync(`../objects/${file}`, fileContent);
  }
}
