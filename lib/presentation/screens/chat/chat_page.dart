import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/chat.dart';
import '../../../domain/models/message.dart';
import '../../../domain/models/chat_user.dart';
import 'bloc/individual_chat_bloc.dart';
import 'bloc/individual_chat_event.dart';
import 'bloc/individual_chat_state.dart';

class ChatPage extends StatelessWidget {
  final int chatId;
  final int adId;
  final String adTitle;
  final ChatUser otherUser;
  final String? currentUserId;

  const ChatPage({
    super.key,
    required this.chatId,
    required this.adId,
    required this.adTitle,
    required this.otherUser,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return ChatView(
      chatId: chatId,
      adId: adId,
      adTitle: adTitle,
      otherUser: otherUser,
      currentUserId: currentUserId,
    );
  }
}

class ChatView extends StatefulWidget {
  final int chatId;
  final int adId;
  final String adTitle;
  final ChatUser otherUser;
  final String? currentUserId;

  const ChatView({
    super.key,
    required this.chatId,
    required this.adId,
    required this.adTitle,
    required this.otherUser,
    this.currentUserId,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Trigger chat loading and mark as read using the app-level IndividualChatBloc
    context.read<IndividualChatBloc>().add(IndividualChatLoad(widget.chatId));
    context.read<IndividualChatBloc>().add(IndividualChatMarkAsRead(widget.chatId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Individual chat bloc doesn't need to restore list state
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.otherUser.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.adTitle,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              context.read<IndividualChatBloc>().add(IndividualChatNavigateToAdDetails(widget.adId));
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: BlocConsumer<IndividualChatBloc, IndividualChatState>(
          listener: (context, state) {
            if (state is IndividualChatLoaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            }
          },
          builder: (context, state) {
            if (state is IndividualChatLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is IndividualChatError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<IndividualChatBloc>().add(IndividualChatLoad(widget.chatId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is IndividualChatLoaded) {
              final chat = state.chat;
              print('🔍 ChatPage: Building UI with ${chat.messages.length} messages');
              return Column(
                children: [
                  // Messages list
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: chat.messages.length,
                      itemBuilder: (context, index) {
                        final message = chat.messages[index];
                        return _buildMessageBubble(message, chat);
                      },
                    ),
                  ),
                  // Message input
                  _buildMessageInput(context, chat),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message, Chat chat) {
    // Determine if the current user is the sender
    final isCurrentUser = widget.currentUserId != null && message.senderId == widget.currentUserId;
    print('🔍 ChatPage: Building message bubble - sender: ${message.senderId}, current user: ${widget.currentUserId}, isCurrentUser: $isCurrentUser');
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                chat.seller.name.isNotEmpty ? chat.seller.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white70 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Text(
                chat.buyer.name.isNotEmpty ? chat.buyer.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, Chat chat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Напишете съобщение...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            onPressed: () {
              final content = _messageController.text.trim();
              if (content.isNotEmpty) {
                context.read<IndividualChatBloc>().add(
                      IndividualChatSendMessage(
                        chatId: widget.chatId,
                        content: content,
                      ),
                    );
                _messageController.clear();
              }
            },
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inHours > 0) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return 'сега';
    }
  }
}
