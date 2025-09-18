# Chat Implementation

This document describes the chat functionality implemented in the DriveBuy Flutter app.

## Features

### In-Memory Chat System
- **No Backend Required**: All chat data is stored in memory on the device
- **14-Day Expiration**: Messages are automatically cleaned up after 14 days
- **Real-time Updates**: Chat messages update in real-time using streams
- **User-to-User Communication**: Buyers can chat with sellers about specific ads

### Caching System
- **Profile Information**: Cached for 1 hour
- **Saved Ads**: Cached for 30 minutes
- **User Listings**: Cached for 15 minutes
- **Ad Details**: Cached for 2 hours
- **Marketplace Ads**: Cached for 10 minutes

## Architecture

### Models
- `ChatUser`: Represents a user in a chat (buyer/seller)
- `Message`: Individual chat message with timestamp and read status
- `Chat`: Container for messages between two users about a specific ad

### Services
- `ChatService`: Manages in-memory chat storage and real-time updates
- `CacheService`: Handles caching of API responses to reduce network requests

### UI Components
- `ChatListPage`: Shows all user chats with unread message counts
- `ChatPage`: Individual chat interface with message history and input
- Chat button on ad details page to start conversations

## Usage

### Starting a Chat
1. User views an ad details page
2. Clicks "Започни чат" (Start Chat) button
3. System creates or retrieves existing chat between buyer and seller
4. User is navigated to chat interface

### Viewing Chats
1. User clicks chat icon in marketplace app bar
2. System shows list of all active chats
3. Unread message counts are displayed
4. User can tap any chat to open conversation

### Sending Messages
1. User types message in chat input field
2. Message is sent immediately and stored in memory
3. Other user receives real-time update
4. Messages persist for 14 days

## Technical Details

### Memory Management
- Automatic cleanup of expired chats (14 days)
- Periodic cleanup runs every hour
- Stream controllers properly disposed to prevent memory leaks

### Caching Strategy
- Different cache durations for different data types
- Automatic invalidation of expired cache entries
- Manual cache invalidation when data is updated

### Navigation
- Chat routes integrated with GoRouter
- Proper parameter passing for chat context
- Back navigation maintains app state

## Security Considerations

- No persistent storage of sensitive chat data
- Messages automatically expire after 14 days
- User authentication required for chat access
- No chat history stored on server

## Future Enhancements

- Image sharing in chats
- Push notifications for new messages
- Message search functionality
- Chat export capabilities
- Offline message queuing
