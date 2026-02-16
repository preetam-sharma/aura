# Fixing "Path with Spaces" Issue on Windows

## Problem
The error `'C:\Users\Preeti' is not recognized` occurs because your username contains a space ("Preeti Jangra"), and some build tools don't properly quote paths.

## Solutions (Try in Order)

### Solution 1: Set Flutter Path Environment Variable (Recommended)
Add Flutter to your PATH without spaces:

1. Create a symlink or junction:
```powershell
# Run PowerShell as Administrator
New-Item -ItemType Junction -Path "C:\flutter-sdk" -Target "C:\Users\Preeti Jangra\develop\flutter"
```

2. Update PATH:
   - Search "Environment Variables" in Windows
   - Edit System PATH
   - Replace `C:\Users\Preeti Jangra\develop\flutter\bin` with `C:\flutter-sdk\bin`
   - Restart terminal

### Solution 2: Use Short Path Names
```powershell
# Run this to find short path
dir /x "C:\Users"
# Look for something like PREETI~1

# Then set environment variable
$env:FLUTTER_ROOT = "C:\Users\PREETI~1\develop\flutter"
```

### Solution 3: Move Flutter SDK
Move Flutter to a path without spaces:
```powershell
# Move to C:\
Move-Item "C:\Users\Preeti Jangra\develop\flutter" "C:\flutter"

# Update PATH to C:\flutter\bin
```

### Solution 4: Quote the Path in Gradle (Temporary Fix)
Edit `android/gradle.properties` and add:
```properties
org.gradle.jvmargs=-Xmx4608m -XX:+HeapDumpOnOutOfMemoryError "-Dfile.encoding=UTF-8"
```

## After Applying Solution

1. Close all terminals
2. Open new terminal
3. Verify Flutter:
```bash
flutter doctor -v
```

4. Clean and rebuild:
```bash
cd d:\AntiGravity\aura
flutter clean
flutter pub get
flutter run
```

## Current Status
✅ **Code compiled successfully** - 0 errors (33 deprecation warnings)  
❌ **Build system path issue** - needs one of the above solutions

The app code is correct; this is purely a Windows path configuration issue.
