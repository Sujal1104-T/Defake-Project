# Step-by-Step Render.com Deployment Guide

## ✅ Prerequisites Ready!
Your backend is configured and ready to deploy.

---

## 🚀 Deploy to Render.com (15 Minutes)

### Step 1: Create Render Account (2 minutes)

1. Go to [render.com](https://render.com)
2. Click "Get Started for Free"
3. Sign up with GitHub (easiest!) or email
4. **NO credit card required!** ✅

### Step 2: Push Backend to GitHub (5 minutes)

**Option A: If you already have GitHub repo**
```bash
cd c:\Users\sujal\OneDrive\Desktop\Defake\backend

# Add files
git add .
git commit -m "Prepare backend for Render deployment"
git push
```

**Option B: Create new repo**
```bash
cd c:\Users\sujal\OneDrive\Desktop\Defake\backend

# Initialize git
git init
git add .
git commit -m "TruthGuard backend for Render"

# Create repo on GitHub.com, then:
git remote add origin https://github.com/YOUR_USERNAME/truthguard-backend.git
git branch -M main
git push -u origin main
```

### Step 3: Deploy on Render (5 minutes)

1. **In Render dashboard**, click "New +" → "Web Service"

2. **Connect repository**:
   - Click "Connect account" (GitHub)
   - Find your `truthguard-backend` repo
   - Click "Connect"

3. **Configure service**:
   ```
   Name: truthguard-api
   Region: Choose closest to you (e.g., Singapore)
   Branch: main
   Root Directory: (leave blank or specify "backend" if in subdirectory)
   Runtime: Python 3
   Build Command: pip install -r requirements.txt
   Start Command: uvicorn main:app --host 0.0.0.0 --port $PORT
   ```

4. **Select plan**:
   - Choose "Free" plan ✅
   - 750 hours/month FREE
   - Perfect for college projects!

5. **Click "Create Web Service"**

6. **Wait 3-5 minutes** for deployment...
   - Watch the build logs
   - Should see "Build successful"
   - Then "Deploy live"

7. **Get your URL**:
   - Will be something like: `https://truthguard-api.onrender.com`
   - **Copy this URL!**

### Step 4: Update Flutter App (3 minutes)

1. Open `lib/services/api_service.dart`

2. Find this line:
   ```dart
   static const String baseUrl = 'http://localhost:8000';
   ```

3. Replace with your Render URL:
   ```dart
   static const String baseUrl = 'https://truthguard-api.onrender.com';
   ```

4. Save the file

### Step 5: Test API (1 minute)

Open browser and test:
```
https://truthguard-api.onrender.com/docs
```

You should see FastAPI Swagger documentation! ✅

---

## 🎯 After Deployment

### Rebuild Your App:

**For Web:**
```bash
flutter build web
firebase deploy
```

**For Android APK:**
```bash
flutter build apk --release
```

**For Testing:**
```bash
flutter run -d chrome
```

Now your app works **anywhere in the world!** 🌍

---

## ⚠️ Important Notes

### Free Tier Limitations:
- **Sleeps after 15 min of inactivity**
- **First request takes 30-60 seconds to wake up**
- **750 hours/month** (plenty for college project!)

### Before Demo:
1. Open your API URL 2 minutes before
2. This "wakes up" the server
3. Then it's fast for your demo!

### To Keep It Awake (Optional):
Use a free service like "UptimeRobot" to ping your API every 10 minutes

---

## 🆘 Troubleshooting

### "Build failed"
- Check build logs in Render dashboard
- Usually missing dependencies
- Make sure requirements.txt is updated

### "Application failed to respond"
- Check Start Command is correct
- Should be: `uvicorn main:app --host 0.0.0.0 --port $PORT`
- Check logs for Python errors

### CORS errors in Flutter
- Should work automatically
- CORS is already configured in main.py

---

## ✅ Success Checklist

- [ ] Render account created
- [ ] Backend pushed to GitHub
- [ ] Service deployed on Render
- [ ] Got deployment URL
- [ ] Updated api_service.dart
- [ ] Tested API /docs endpoint
- [ ] Rebuilt Flutter app
- [ ] Tested video upload feature

---

**Once deployed, your app works on:**
- ✅ Any phone (APK)
- ✅ Any computer (web)
- ✅ Any network (internet)
- ✅ Anywhere in the world!

**Ready to deploy? Let me know if you need help with any step!**
