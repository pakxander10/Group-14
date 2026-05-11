# Ascend iOS (SwiftUI, MVVM)

## Folder layout
```
Ascend/
├── App/
│   └── AscendApp.swift              # @main entry point
├── Models/
│   ├── LearnerProfile.swift
│   ├── MentorProfile.swift
│   ├── ThreadPost.swift             # ThreadPost + ThreadReply
│   └── QuestionnaireAnswers.swift   # Request DTOs
├── ViewModels/
│   ├── ProfileViewModel.swift
│   ├── ConfidenceViewModel.swift
│   ├── QuestionnaireViewModel.swift
│   └── MentorThreadViewModel.swift
├── Views/
│   ├── MainView.swift               # TabView host
│   ├── ProfileView.swift
│   ├── ConfidenceDashboardView.swift
│   ├── QuestionnaireView.swift
│   └── MentorThreadView.swift
└── Networking/
    └── NetworkManager.swift
```

## Setting up the Xcode project (5 min)
1. **File → New → Project → iOS App**. Product name: `Ascend`. Interface: SwiftUI. Language: Swift. Storage: None.
2. **Delete** the default `AscendApp.swift` and `ContentView.swift` Xcode generated.
3. **Drag the `Ascend/` folder** from Finder into the Xcode project navigator. Check **Copy items if needed** and **Create groups**.
4. Build (⌘B). If you get duplicate-symbol errors, you didn't delete step 2.

## ATS — allow http://127.0.0.1
Add to `Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsLocalNetworking</key>
  <true/>
</dict>
```
For a physical device, replace `http://127.0.0.1:8000` in `NetworkManager.swift`
with your Mac's LAN IP (e.g. `http://192.168.1.42:8000`).
