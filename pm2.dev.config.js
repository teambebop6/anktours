module.exports = {
  apps: [
    {
      name: "ank_dev",
      script: "./server.js",
      instances: 1,
      exec_mode: "cluster",
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
        DB_NAME: 'ank_dev',
        IMAGE_TRIP_FOLDER: '/var/lib/ank_dev/images/trip',
        IMAGE_UPLOAD_FOLDER: '/var/lib/ank_dev/images/galeries',
      },
      cwd: '/usr/local/share/website/dev.ank-tours.ch/ank_dev'
    }
  ],
};
