localEnc = require('../anktours-secret/development');
devEnc = require('../anktours-secret/development');
prodEnc = require('../anktours-secret/production');


config = {
  USE_IMAGE_MAGICK: true,
  IMAGE_UPLOAD_FOLDER: process.env.IMAGE_UPLOAD_FOLDER || '/var/lib/ank_dev/images/galeries',
  IMAGE_TRIP_FOLDER: process.env.IMAGE_TRIP_FOLDER || '/var/lib/ank_dev/images/trip',
};

local = {
  DEBUG_LOG: true,
  DEBUG_WARN: true,
  DEBUG_ERROR: true,
  DEBUG_CLIENT: true,
};

development = {
  DEBUG_LOG: true,
  DEBUG_WARN: true,
  DEBUG_ERROR: true,
  DEBUG_CLIENT: true,
};

production = {
  DEBUG_LOG: false,
  DEBUG_WARN: false,
  DEBUG_ERROR: false,
  DEBUG_CLIENT: false,
};

module.exports = (env) ->
  switch env

    when "local"
      Object.assign(config, local)
      if localEnc
        assign(config, localEnc)

    when "development"
      Object.assign(config, development)
      if devEnc
        Object.assign(config, devEnc)

    when "production"
      Object.assign(config, production)
      if prodEnc
        Object.assign(config, prodEnc)

    else
      console.error("Environment #{env} not found.");

  console.log(config)
  return config