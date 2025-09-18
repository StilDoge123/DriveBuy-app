import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../app/bloc/auth_cubit.dart';
import 'bloc/chat_list_bloc.dart';
import 'bloc/chat_list_event.dart';
import 'bloc/chat_list_state.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    // Trigger chat list loading
    context.read<ChatListBloc>().add(const ChatListLoad());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state;
    final userId = user?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view chats'),
        ),
      );
    }

    return BlocBuilder<ChatListBloc, ChatListState>(
      builder: (context, state) {
        if (state is ChatListLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Чатове'),
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Зареждане на чатове...'),
                ],
              ),
            ),
          );
        }

        if (state is ChatListError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Чатове'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ChatListBloc>().add(const ChatListLoad());
                    },
                    child: const Text('Опитайте отново'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is ChatListLoaded) {
          final userChats = state.chats;
          final isRefreshing = state.isRefreshing;
          
          print('🔍 ChatListPage: User ID: $userId');
          print('🔍 ChatListPage: Found ${userChats.length} chats for user');
          for (final chat in userChats) {
            print('🔍 ChatListPage: Chat ${chat.id} - buyer: ${chat.buyer.id}, seller: ${chat.seller.id}');
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Чатове'),
              actions: [
                if (isRefreshing)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<ChatListBloc>().add(const ChatListRefresh());
                    },
                  ),
              ],
            ),
            body: SafeArea(
              bottom: true,
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<ChatListBloc>().add(const ChatListRefresh());
                  // Wait a short moment for the refresh to complete
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: Stack(
                  children: [
                    userChats.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 200),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Нямате активни чатове',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Започнете разговор с продавач',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: userChats.length,
                        itemBuilder: (context, index) {
                          final chat = userChats[index];
                          final otherUser = chat.getOtherUser(userId);
                          final unreadCount = chat.getUnreadCount(userId);
                          final lastMessage = chat.messages.isNotEmpty
                              ? chat.messages.last
                              : null;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text(
                                otherUser.name.isNotEmpty ? otherUser.name[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              otherUser.name,
                              style: TextStyle(
                                fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chat.adTitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (lastMessage != null)
                                  Text(
                                    lastMessage.content,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (lastMessage != null)
                                  Text(
                                    _formatTime(lastMessage.timestamp),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                if (unreadCount > 0)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () {
                              // Mark messages as read when entering chat
                              // Note: This will be handled by the individual chat bloc
                              
                              context.push('/chat/${chat.id}', extra: {
                                'adId': chat.adId,
                                'adTitle': chat.adTitle,
                                'otherUser': otherUser,
                                'currentUserId': userId,
                              });
                            },
                          );
                        },
                      ),
                    if (isRefreshing && userChats.isNotEmpty)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 4,
                          child: const LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        return const Scaffold(
          body: Center(
            child: Text('Unknown state'),
          ),
        );
      },
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
