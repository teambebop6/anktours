module.exports = {
  /**
   * Application configuration section
   * http://pm2.keymetrics.io/docs/usage/application-declaration/
   */
  apps: [

    // Release
    {
      name: 'anktours_release',
      script: 'server.js',
      env: {
        NODE_ENV: 'production',
        PORT: 4000
      }
    },

    // Dev app
    {
      name: 'anktours_dev',
      script: 'server.js',
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
        DB_NAME: 'ank_dev'
      }
    }
  ],
};
