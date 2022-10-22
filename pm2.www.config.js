module.exports = {
  apps: [
    {
      name: "ank",
      script: "./server.js",
      instances: 2,
      exec_mode: "cluster",
      env: {
        NODE_ENV: 'production',
        HOST: '127.0.0.1',
        PORT: 4000,
      },
      cwd: '/app/ank/apps/prod/ank'
    }
  ],
};
