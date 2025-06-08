@echo off
echo 🔧 Fixing CORS issue for https://portfolio-c1274.web.app...

REM Set the project
echo 📋 Setting Firebase project...
gcloud config set project portfolio-c1274

REM Apply CORS configuration
echo 🌐 Applying CORS configuration...
gsutil cors set cors.json gs://portfolio-c1274.appspot.com

REM Make bucket publicly readable
echo 🔓 Making bucket publicly readable...
gsutil iam ch allUsers:objectViewer gs://portfolio-c1274.appspot.com

REM Verify CORS configuration
echo ✅ Verifying CORS configuration...
gsutil cors get gs://portfolio-c1274.appspot.com

echo 🎉 CORS configuration complete!
echo.
echo 📝 Next steps:
echo 1. Wait 5-10 minutes for changes to propagate
echo 2. Clear your browser cache
echo 3. Test your deployed app
echo.
echo If issues persist, try the permissive CORS config:
echo gsutil cors set cors-permissive.json gs://portfolio-c1274.appspot.com

pause
