# Add gsutil to Windows PATH

## 🎯 Quick Fix for Future Use

To add gsutil to your PATH so you can use it directly:

### Method 1: PowerShell (Temporary - Current Session Only)
```powershell
$env:PATH += ";C:\Users\$env:USERNAME\AppData\Local\Google\Cloud SDK\google-cloud-sdk\bin"
```

### Method 2: System Environment Variables (Permanent)

1. **Open System Properties**:
   - Press `Win + R`
   - Type `sysdm.cpl`
   - Press Enter

2. **Environment Variables**:
   - Click "Environment Variables" button
   - In "User variables" section, find "Path"
   - Click "Edit"

3. **Add gsutil Path**:
   - Click "New"
   - Add: `C:\Users\[YourUsername]\AppData\Local\Google\Cloud SDK\google-cloud-sdk\bin`
   - Replace `[YourUsername]` with your actual username
   - Click "OK" on all dialogs

4. **Restart Command Prompt/PowerShell**:
   - Close and reopen your terminal
   - Test with: `gsutil version`

### Method 3: Command Line (Permanent)
```cmd
setx PATH "%PATH%;C:\Users\%USERNAME%\AppData\Local\Google\Cloud SDK\google-cloud-sdk\bin"
```

After adding to PATH, you can use gsutil directly:
```bash
gsutil cors get gs://portfolio-c1274.appspot.com
gsutil ls gs://portfolio-c1274.appspot.com
```
