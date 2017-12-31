localEnc = require('../anktours-secret/local');
devEnc = require('../anktours-secret/development');
prodEnc = require('../anktours-secret/production');
assign = require('object.assign');


config = {
  USE_IMAGE_MAGICK: true,
  GALLERIES_FOLDER: process.env.GALLERIES_FOLDER || 'galeries',
  TRIP_FOLDER: process.env.TRIP_FOLDER || 'trip',
  NEWS_FOLDER: process.env.NEWS_FOLDER || 'news',
};

local = {
  DEBUG_LOG: true,
  DEBUG_WARN: true,
  DEBUG_ERROR: true,
  DEBUG_CLIENT: true,
  IMAGE_UPLOAD_FOLDER: process.env.IMAGE_UPLOAD_FOLDER || '/var/lib/ank_dev/images/upload/',
};

development = {
  DEBUG_LOG: true,
  DEBUG_WARN: true,
  DEBUG_ERROR: true,
  DEBUG_CLIENT: true,
  IMAGE_UPLOAD_FOLDER: process.env.IMAGE_UPLOAD_FOLDER || '/var/lib/ank_dev/images/upload/',
};

production = {
  DEBUG_LOG: false,
  DEBUG_WARN: false,
  DEBUG_ERROR: false,
  DEBUG_CLIENT: false,
  IMAGE_UPLOAD_FOLDER: process.env.IMAGE_UPLOAD_FOLDER || '/var/lib/ank/images/upload/',
};

module.exports = (env) ->
  switch env

    when "local"
      assign(config, local)
      if localEnc
        assign(config, localEnc)

    when "development"
      assign(config, development)
      if devEnc
        assign(config, devEnc)

    when "production"
      assign(config, production)
      if prodEnc
        assign(config, prodEnc)

    else
      console.error("Environment #{env} not found.");

  console.log(config)
  return config
