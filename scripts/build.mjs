import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
mkdirSync('dist',{recursive:true});
writeFileSync('dist/index.html',readFileSync('index.html'));
console.log('SUT IQ200 static build complete → dist/');
