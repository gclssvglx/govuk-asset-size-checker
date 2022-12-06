'use strict';

const axios = require('axios');
require('dotenv').config();

module.exports.checker = async (event, context) => {
  // process.env.NODE_TLS_REJECT_UNAUTHORIZED;

  axios.get(process.env.RESTDB_GET_URL, {
      headers: {
        "Content-Type": "application/json",
        "x-apikey": process.env.RESTDB_API_KEY
      }
    })
    .then(response => {
      if (response.data.message) {
        console.log(`Got ${Object.entries(response.data.message).length}`);
      }
    })
    .catch(error => {
      console.log(error);
    }
  );

  const time = new Date();
  console.log(`CHECKER: Your function "${context.functionName}" ran at ${time}`);
};
