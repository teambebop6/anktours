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
      cwd: '/usr/local/share/website/www.ank-tours.ch/ank'
    }
  ],
};
