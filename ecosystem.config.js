module.exports = {
  apps: [
    {
      name: "sheikh-bot-v8",
      script: "./sheikh_whatsapp_bot_v8.js",
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: "650M",
      restart_delay: 5000,
      exp_backoff_restart_delay: 2000,
      env: {
        NODE_ENV: "production"
      }
    }
  ]
};
