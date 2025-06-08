#!/bin/bash

# One-command CORS fix for portfolio-c1274.web.app
echo "🚀 Quick CORS fix for https://portfolio-c1274.web.app"

# Set project and apply all fixes in one go
gcloud config set project portfolio-c1274 && \
gsutil cors set cors.json gs://portfolio-c1274.appspot.com && \
gsutil iam ch allUsers:objectViewer gs://portfolio-c1274.appspot.com && \
echo "✅ CORS fix applied! Wait 5-10 minutes and clear browser cache."
