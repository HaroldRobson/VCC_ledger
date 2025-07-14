const rateModule = require("./index.node");

const id = 27;
const rating = rateModule.rate(id); // DO NOT MOVE THIS FUNCTION CALL FROM THIS DIRECTORY OR IT WILL BREAK BECAUSE I HARDCODED THE FILEPATH
console.log(rating);
