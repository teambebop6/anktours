module.exports = {
  apps: [
    {
      name: "ank",
      script: "./server.js",
      instances: 2,
      exec_mode: "cluster",
      env: {
        NODE_ENV: 'production',
        PORT: 4000,
      },
      cwd: '/app/ank/apps/prod/ank'
    }
  ],
};
