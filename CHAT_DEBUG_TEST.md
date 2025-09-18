# Chat Debug Test

## Test Scenario

To debug the chat functionality, follow these steps:

### Step 1: User A starts a chat
1. User A opens an ad details page
2. User A clicks "Започни чат" button
3. Check debug console for:
   - `🔍 ChatService: Generated chat ID: [chatId] for ad: [adId], participants: [userIds]`
   - `🔍 ChatService: Created new chat [chatId] with stream controller`

### Step 2: User A sends a message
1. User A types a message and sends it
2. Check debug console for:
   - `🔍 ChatBloc: Current user ID: [userId]`
   - `🔍 ChatBloc: Sending message from user [userId] to chat [chatId]`
   - `🔍 ChatService: Message sent, notifying listeners`
   - `🔍 ChatService: Notifying chat [chatId] with [X] messages`
   - `🔍 ChatBloc: Received chat update with [X] messages`

### Step 3: User B accesses the same chat
1. User B opens the chat list or goes to the same ad
2. User B clicks to open the chat
3. Check debug console for:
   - `🔍 ChatService: Generated chat ID: [chatId] for ad: [adId], participants: [userIds]`
   - `🔍 ChatService: Stream controller already exists for chat [chatId]` OR
   - `🔍 ChatService: Creating stream controller for existing chat [chatId]`
   - `🔍 ChatService: Getting chat [chatId], found: true`
   - `🔍 ChatService: Chat has [X] messages`

### Step 4: User A sends another message
1. User A sends another message
2. Check if User B receives the update:
   - `🔍 ChatBloc: Received chat update with [X] messages` (for User B)

## Expected Issues to Look For

1. **Different Chat IDs**: If User A and User B get different chat IDs, the issue is in user ID generation
2. **Missing Stream Controller**: If User B can't access the stream, the issue is in stream controller creation
3. **No Stream Updates**: If User B doesn't receive stream updates, the issue is in the stream subscription

## Key Debug Points

- Chat ID generation should be the same for both users
- Stream controller should exist for existing chats
- Both users should receive stream updates when messages are sent
- User IDs should be consistent between chat creation and message sending
