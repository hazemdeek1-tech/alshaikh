# Sheikh WhatsApp Bot v8.0 Pro & Knowledge Bank (بنك المعرفة)

An all-in-one WhatsApp study assistant, 4,769+ PDF library vault bot, AI student companion, and group moderation suite built with **Baileys v7**, **Gemini AI**, **PyMuPDF**, and **PM2** for 24/7 cloud operation.

## Included Files
- `sheikh_whatsapp_bot_v8.js` — Main WhatsApp bot engine (v8.0 Pro)
- `package.json` — Node.js dependencies (`@whiskeysockets/baileys`, `pdf-parse`, `pino`)
- `Sheikh_WhatsApp_Bot_Colab_v8.ipynb` — 1-click Google Colab launcher
- `deploy_24_7_cloud.sh` & `ecosystem.config.js` — 24/7 Ubuntu/Oracle Cloud installer (`rclone` + `PM2`)
- `Smart_Library_Renamer_Colab.ipynb` — AI PDF content inspector & auto-renamer
- `Telegram_PDF_Archiver_Colab_TURBO.ipynb` & `telegram_pdf_archiver.py` — High-speed Telegram PDF archiver & deduplicator

## Quick Start (24/7 Cloud Server)
```bash
cp .env.example .env
# Fill in your keys in .env (never commit .env!)
bash deploy_24_7_cloud.sh
```
