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
      },
      cwd: '/app/ank/apps/dev/ank'
    }
  ],
};
