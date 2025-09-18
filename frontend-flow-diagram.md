# DriveBuy Frontend Communication Flow

```mermaid
---
config:
      theme: redux
---
flowchart TD
    Start(["User Opens DriveBuy App"])
    
    %% App Initialization
    Start --> LoadApp["Load App"]
    LoadApp --> LoadDropdowns["Load Dropdown Data"]
    LoadDropdowns --> BackendAPI4["GET /brands, /models, /colors<br/>Backend API<br/>(No Auth Required)"]
    LoadDropdowns --> BackendAPI5["GET /locations/*<br/>Backend API<br/>(No Auth Required)"]
    BackendAPI4 --> MainApp["Main App Screen<br/>(Home Screen)"]
    BackendAPI5 --> MainApp
    
    %% Main App Features
    MainApp --> Browse["Browse Cars<br/>(No Auth Required)"]
    MainApp --> CreateAd["Create Ad"]
    MainApp --> ChatList["View Chats"]
    MainApp --> AIAssist["AI Assistant"]
    MainApp --> SaveAdAction["Save Ad"]
    
    %% Authentication Check for Protected Features
    CreateAd --> AuthCheckCreate{"User Authenticated?"}
    ChatList --> AuthCheckChat{"User Authenticated?"}
    AIAssist --> AuthCheckAI{"User Authenticated?"}
    SaveAdAction --> AuthCheckSave{"User Authenticated?"}
    
    AuthCheckCreate -->|No| LoginPrompt["Show Login/Register"]
    AuthCheckChat -->|No| LoginPrompt
    AuthCheckAI -->|No| LoginPrompt
    AuthCheckSave -->|No| LoginPrompt
    
    LoginPrompt --> FirebaseAuth["Firebase Authentication"]
    FirebaseAuth --> JWTToken["Get JWT Token"]
    JWTToken --> AuthSuccess["Authentication Success"]
    
    AuthCheckCreate -->|Yes| CreateAdFlow["Proceed to Create Ad"]
    AuthCheckChat -->|Yes| LoadChats["Load Chat List"]
    AuthCheckAI -->|Yes| AIChat["Start AI Conversation"]
    AuthCheckSave -->|Yes| SaveAd["Save Favorite Ad"]
    
    %% Browse Cars Flow
    Browse --> BackendAPI1["GET /ads/with-user-info<br/>Backend API<br/>(Optional JWT Token)"]
    BackendAPI1 --> DisplayCars["Display Car Listings"]
    DisplayCars --> SaveAdFromBrowse["Try to Save Ad"]
    SaveAdFromBrowse --> AuthCheckSave
    
    SaveAd --> BackendAPI2["POST/DELETE /ads/saved<br/>Backend API<br/>+JWT Token"]
    
    %% Search & Filter Flow
    Browse --> SearchFilter["Apply Search Filters"]
    SearchFilter --> BackendAPI3["GET /ads/search<br/>Backend API<br/>(Optional JWT Token + Filters)"]
    BackendAPI3 --> FilteredResults["Display Filtered Results"]
    FilteredResults --> SaveAdFromSearch["Try to Save Ad"]
    SaveAdFromSearch --> AuthCheckSave
    
    %% Create Ad Flow
    CreateAdFlow --> ImagePicker["Select Images"]
    ImagePicker --> ImageCompress["Compress Images<br/>(80% quality, 1280x720)"]
    ImageCompress --> FillAdForm["Fill Ad Details Form"]
    FillAdForm --> BackendAPI6["POST /ads<br/>Backend API<br/>+JWT Token + MultiPart"]
    BackendAPI6 --> AdCreated["Ad Created Successfully"]
    
    %% Authentication Success Flow
    AuthSuccess --> ReturnToFeature["Return to Requested Feature"]
    ReturnToFeature --> CreateAdFlow
    ReturnToFeature --> LoadChats
    ReturnToFeature --> AIChat
    ReturnToFeature --> SaveAd
    ReturnToFeature --> LoadAdData
    
    %% Edit Ad Flow
    DisplayCars --> EditAd["Edit Existing Ad"]
    EditAd --> AuthCheckEdit{"User Authenticated?"}
    AuthCheckEdit -->|No| LoginPrompt
    AuthCheckEdit -->|Yes| LoadAdData["Load Current Ad Data"]
    LoadAdData --> BackendAPI7["GET /ads/{id}<br/>Backend API<br/>+JWT Token"]
    BackendAPI7 --> UpdateAdForm["Update Ad Form"]
    UpdateAdForm --> BackendAPI8["PUT /ads/{id}<br/>Backend API<br/>+JWT Token"]
    
    %% Chat System Flow
    LoadChats --> BackendAPI9["GET /chats/*<br/>Backend API<br/>+JWT Token"]
    BackendAPI9 --> DisplayChats["Display Chat List"]
    DisplayChats --> OpenChat["Open Individual Chat"]
    
    %% WebSocket Chat Flow
    OpenChat --> WebSocketConnect["Connect to WebSocket<br/>wss://drivebuy.onrender.com/ws/websocket<br/>+JWT Token"]
    WebSocketConnect --> WebSocketSuccess{"WebSocket Connected?"}
    WebSocketSuccess -->|Yes| RealtimeChat["Real-time Chat Active"]
    WebSocketSuccess -->|No| HTTPFallback["HTTP Fallback<br/>POST /chats/messages<br/>Backend API"]
    
    RealtimeChat --> SendMessage["Send Message"]
    SendMessage --> WebSocketSend["Send via WebSocket<br/>STOMP Protocol"]
    WebSocketSend --> OptimisticUpdate["Optimistic UI Update"]
    WebSocketSend --> MessageDelivered["Message Delivered"]
    MessageDelivered --> ReadStatus["Update Read Status"]
    
    %% Notifications
    MessageDelivered --> AppBackground{"App in Background?"}
    AppBackground -->|Yes| LocalNotification["Show Local Notification"]
    AppBackground -->|No| UIUpdate["Update Chat UI"]
    
    %% AI Assistant Flow
    AIChat --> UserQuery["User Asks Car Question<br/>(in Bulgarian)"]
    UserQuery --> GeminiAPI["Google Gemini AI API<br/>Model: gemini-2.5-flash-lite<br/>+System Prompt"]
    GeminiAPI --> GeminiSuccess{"AI Response Success?"}
    GeminiSuccess -->|Yes| AIResponse["AI Recommendation Response"]
    GeminiSuccess -->|No| RetryMechanism["Exponential Backoff Retry"]
    RetryMechanism --> FallbackResponse["Rule-based Fallback Response"]
    
    AIResponse --> StructuredFilter["Generate CarSearchFilter JSON"]
    StructuredFilter --> ApplyAIFilter["Apply AI Generated Filter"]
    ApplyAIFilter --> BackendAPI3
    
    %% User Management Flow
    MainApp --> UserProfile["User Profile"]
    UserProfile --> BackendAPI10["GET/PUT /users/*<br/>Backend API<br/>+JWT Token"]
    
    %% Token Refresh Flow
    BackendAPI1 --> TokenValid{"JWT Token Valid?"}
    BackendAPI2 --> TokenValid
    BackendAPI3 --> TokenValid
    BackendAPI4 --> TokenValid
    BackendAPI5 --> TokenValid
    BackendAPI6 --> TokenValid
    BackendAPI7 --> TokenValid
    BackendAPI8 --> TokenValid
    BackendAPI9 --> TokenValid
    BackendAPI10 --> TokenValid
    
    TokenValid -->|No| RefreshToken["Refresh Firebase Token"]
    RefreshToken --> FirebaseAuth
    TokenValid -->|Yes| APISuccess["API Call Success"]
    
    %% Error Handling
    GeminiAPI --> AIError{"AI API Error?"}
    AIError -->|Yes| RetryMechanism
    WebSocketConnect --> WSError{"WebSocket Error?"}
    WSError -->|Yes| HTTPFallback
    
    %% App State Management
    APISuccess --> BlocUpdate["Update BLoC State"]
    BlocUpdate --> UIRefresh["Refresh UI"]
    
    %% Connection Recovery
    WebSocketConnect --> AppResume["App Resume"]
    AppResume --> ReconnectWS["Auto Reconnect WebSocket"]
    ReconnectWS --> WebSocketConnect
    
    %% External Services Styling
    classDef firebaseService fill:#ff6b35,stroke:#333,stroke-width:2px,color:#fff
    classDef backendService fill:#4285f4,stroke:#333,stroke-width:2px,color:#fff
    classDef geminiService fill:#34a853,stroke:#333,stroke-width:2px,color:#fff
    classDef websocketService fill:#ea4335,stroke:#333,stroke-width:2px,color:#fff
    
    class FirebaseAuth,JWTToken,RefreshToken firebaseService
    class BackendAPI1,BackendAPI2,BackendAPI3,BackendAPI4,BackendAPI5,BackendAPI6,BackendAPI7,BackendAPI8,BackendAPI9,BackendAPI10,HTTPFallback backendService
    class GeminiAPI geminiService
    class WebSocketConnect,WebSocketSend,ReconnectWS websocketService
```

## Service Communication Summary

### 🔥 Firebase Services
- **Authentication**: Email/password login, JWT token management
- **Token Refresh**: Automatic token renewal for API calls

### 🔵 Backend API (Spring Boot)
- **Base URL**: `https://drivebuy.onrender.com`
- **Authentication**: Firebase JWT tokens in Authorization headers (required for protected features)
- **Public Endpoints**: `/ads/*` (browsing), `/brands`, `/models`, `/colors`, `/locations/*`
- **Protected Endpoints**: `/ads/*` (create/edit), `/users/*`, `/chats/*`, `/ads/saved`

### 🟢 Google Gemini AI
- **Model**: `gemini-2.5-flash-lite`
- **Purpose**: AI-powered car recommendations in Bulgarian
- **Output**: Structured CarSearchFilter JSON

### 🔴 WebSocket/STOMP
- **URL**: `wss://drivebuy.onrender.com/ws/websocket`
- **Purpose**: Real-time chat with automatic reconnection
- **Fallback**: HTTP API calls if WebSocket fails

### Key Features
- **Graceful Degradation**: Services continue working if some APIs fail
- **Optimistic Updates**: Immediate UI feedback before server confirmation
- **Automatic Reconnection**: WebSocket reconnects on app resume
- **Image Compression**: 80% quality, 1280x720 max resolution
- **Multi-language Support**: AI assistant works in Bulgarian
