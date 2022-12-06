'use strict';

module.exports.checker = async (event, context) => {
  const time = new Date();
  console.log(`CHECKER: Your function "${context.functionName}" ran at ${time}`);
};
