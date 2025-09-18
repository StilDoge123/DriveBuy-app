import 'package:drivebuy/presentation/screens/marketplace/bloc/marketplace_bloc.dart';
import 'package:drivebuy/presentation/screens/marketplace/bloc/marketplace_event.dart';
import 'package:drivebuy/domain/models/car_search_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'bloc/ai_assistant_bloc.dart';
import 'bloc/ai_assistant_event.dart';
import 'bloc/ai_assistant_state.dart';

class AiAssistantPage extends StatelessWidget {
  const AiAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AiAssistantView();
  }
}

class AiAssistantView extends StatefulWidget {
  const AiAssistantView({super.key});

  @override
  State<AiAssistantView> createState() => _AiAssistantViewState();
}

class _AiAssistantViewState extends State<AiAssistantView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _handleSubmitted(String text) {
    final state = context.read<AiAssistantBloc>().state;
    
    // Don't send message if still initializing or loading
    if (state.status == AiAssistantStatus.initializing ||
        state.status == AiAssistantStatus.loading) {
      return;
    }
    
    if (text.trim().isNotEmpty) {
      context.read<AiAssistantBloc>().add(SendMessageEvent(text.trim()));
      _textController.clear();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Асистент'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AiAssistantBloc>().add(ResetChatEvent());
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<AiAssistantBloc, AiAssistantState>(
                listener: (context, state) {
                  if (state.status == AiAssistantStatus.success) {
                    _scrollToBottom();
                  }
                  
                  // Show error messages as snackbar for better UX
                  if (state.status == AiAssistantStatus.failure && state.error.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error),
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  // Show loading indicator during initialization
                  if (state.status == AiAssistantStatus.initializing) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Инициализиране на AI асистента...'),
                        ],
                      ),
                    );
                  }
                  
                  final List<ChatMessage> allMessages = [];
                  
                  // Add welcome message if no messages
                  if (state.messages.isEmpty) {
                    allMessages.add(const ChatMessage(
                      text: 'Здравейте! Аз съм вашият AI асистент за автомобили. Ще ви помогна да намерите перфектния автомобил според вашите нужди и предпочитания. Моля, споделете какъв тип автомобил търсите!',
                      isUser: false,
                    ));
                  } else {
                    allMessages.addAll(state.messages);
                  }
                  
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: allMessages.length,
                    itemBuilder: (context, index) {
                      final message = allMessages[index];
                      return _buildMessageBubble(message);
                    },
                  );
                },
              ),
            ),
            if (context.watch<AiAssistantBloc>().state.status ==
                AiAssistantStatus.loading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            _buildMessageInput(context),
            _buildPreferencesDisplay(),
            BlocBuilder<AiAssistantBloc, AiAssistantState>(
              builder: (context, state) {
                if (state.searchFilter != null) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        context
                            .read<MarketplaceBloc>()
                            .add(MarketplaceUpdateFilter(state.searchFilter!));
                        context.pop();
                      },
                      child: const Text('Търсене с този филтър'),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesDisplay() {
    return BlocBuilder<AiAssistantBloc, AiAssistantState>(
      builder: (context, state) {
        if (state.searchFilter == null || state.searchFilter!.isEmpty) {
          return const SizedBox.shrink();
        }

        final filter = state.searchFilter!;
        final criteriaCount = _countFilterCriteria(filter);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.green.withOpacity(0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.search,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Критерии за търсене ($criteriaCount)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _buildSearchFilterChips(filter, context),
              ),
            ],
          ),
        );
      },
    );
  }

  int _countFilterCriteria(CarSearchFilter filter) {
    int count = 0;
    if (filter.make != null) count++;
    if (filter.model != null) count++;
    if (filter.keywordSearch != null && filter.keywordSearch!.isNotEmpty) count++;
    if (filter.color != null) count++;
    if (filter.bodyType != null) count++;
    if (filter.doorCount != null) count++;
    if (filter.steeringPosition != null) count++;
    if (filter.transmissionType != null) count++;
    if (filter.fuelType != null) count++;
    if (filter.cylinderCount != null) count++;
    if (filter.driveType != null) count++;
    if (filter.minPrice != null || filter.maxPrice != null) count++;
    if (filter.yearFrom != null || filter.yearTo != null) count++;
    if (filter.minHp != null || filter.maxHp != null || 
        filter.hpFrom != null || filter.hpTo != null || 
        filter.hp != null) count++;
    if (filter.minDisplacement != null || filter.maxDisplacement != null ||
        filter.displacementFrom != null || filter.displacementTo != null ||
        filter.displacement != null) count++;
    if (filter.minMileage != null || filter.maxMileage != null ||
        filter.mileageFrom != null || filter.mileageTo != null) count++;
    if (filter.minOwnerCount != null || filter.maxOwnerCount != null ||
        filter.ownerCountFrom != null || filter.ownerCountTo != null ||
        filter.ownerCount != null) count++;
    if (filter.region != null) count++;
    if (filter.city != null) count++;
    if (filter.features != null && filter.features!.isNotEmpty) count++;
    if (filter.conditions != null && filter.conditions!.isNotEmpty) count++;
    return count;
  }

  List<Widget> _buildSearchFilterChips(CarSearchFilter filter, BuildContext context) {
    final chips = <Widget>[];

    if (filter.make != null) {
      chips.add(_buildChip('Марка: ${filter.make}', context));
    }
    if (filter.model != null) {
      chips.add(_buildChip('Модел: ${filter.model}', context));
    }
    if (filter.keywordSearch != null && filter.keywordSearch!.isNotEmpty) {
      chips.add(_buildChip('Търсене: ${filter.keywordSearch}', context));
    }
    if (filter.color != null) {
      chips.add(_buildChip('Цвят: ${filter.color}', context));
    }
    if (filter.bodyType != null) {
      chips.add(_buildChip('Тип: ${filter.bodyType}', context));
    }
    if (filter.doorCount != null) {
      chips.add(_buildChip('Врати: ${filter.doorCount}', context));
    }
    if (filter.transmissionType != null) {
      chips.add(_buildChip('Скоростна: ${filter.transmissionType}', context));
    }
    if (filter.fuelType != null) {
      chips.add(_buildChip('Гориво: ${filter.fuelType}', context));
    }
    if (filter.cylinderCount != null) {
      chips.add(_buildChip('Цилиндри: ${filter.cylinderCount}', context));
    }
    if (filter.driveType != null) {
      chips.add(_buildChip('Задвижване: ${filter.driveType}', context));
    }
    if (filter.steeringPosition != null) {
      chips.add(_buildChip('Волан: ${filter.steeringPosition}', context));
    }
    
    // Price range
    if (filter.minPrice != null && filter.maxPrice != null) {
      chips.add(_buildChip('Цена: ${filter.minPrice} - ${filter.maxPrice} лв', context));
    } else if (filter.minPrice != null) {
      chips.add(_buildChip('Цена от: ${filter.minPrice} лв', context));
    } else if (filter.maxPrice != null) {
      chips.add(_buildChip('Цена до: ${filter.maxPrice} лв', context));
    }
    
    // Year range
    if (filter.yearFrom != null && filter.yearTo != null) {
      chips.add(_buildChip('Година: ${filter.yearFrom} - ${filter.yearTo}', context));
    } else if (filter.yearFrom != null) {
      chips.add(_buildChip('Година от: ${filter.yearFrom}', context));
    } else if (filter.yearTo != null) {
      chips.add(_buildChip('Година до: ${filter.yearTo}', context));
    }
    
    // Horsepower range (check all variants)
    final hpFrom = filter.hpFrom ?? filter.minHp;
    final hpTo = filter.hpTo ?? filter.maxHp;
    if (hpFrom != null && hpTo != null) {
      chips.add(_buildChip('Мощност: $hpFrom - $hpTo кс', context));
    } else if (hpFrom != null) {
      chips.add(_buildChip('Мощност от: $hpFrom кс', context));
    } else if (hpTo != null) {
      chips.add(_buildChip('Мощност до: $hpTo кс', context));
    } else if (filter.hp != null) {
      chips.add(_buildChip('Мощност: ${filter.hp} кс', context));
    }
    
    // Displacement range
    final displacementFrom = filter.displacementFrom ?? filter.minDisplacement;
    final displacementTo = filter.displacementTo ?? filter.maxDisplacement;
    if (displacementFrom != null && displacementTo != null) {
      chips.add(_buildChip('Обем: $displacementFrom - $displacementTo л', context));
    } else if (displacementFrom != null) {
      chips.add(_buildChip('Обем от: $displacementFrom л', context));
    } else if (displacementTo != null) {
      chips.add(_buildChip('Обем до: $displacementTo л', context));
    } else if (filter.displacement != null) {
      chips.add(_buildChip('Обем: ${filter.displacement} л', context));
    }
    
    // Mileage range
    final mileageFrom = filter.mileageFrom ?? filter.minMileage;
    final mileageTo = filter.mileageTo ?? filter.maxMileage;
    if (mileageFrom != null && mileageTo != null) {
      chips.add(_buildChip('Пробег: $mileageFrom - $mileageTo км', context));
    } else if (mileageFrom != null) {
      chips.add(_buildChip('Пробег от: $mileageFrom км', context));
    } else if (mileageTo != null) {
      chips.add(_buildChip('Пробег до: $mileageTo км', context));
    }
    
    // Owner count range
    final ownerCountFrom = filter.ownerCountFrom ?? filter.minOwnerCount;
    final ownerCountTo = filter.ownerCountTo ?? filter.maxOwnerCount;
    if (ownerCountFrom != null && ownerCountTo != null) {
      chips.add(_buildChip('Собственици: $ownerCountFrom - $ownerCountTo', context));
    } else if (ownerCountFrom != null) {
      chips.add(_buildChip('Собственици от: $ownerCountFrom', context));
    } else if (ownerCountTo != null) {
      chips.add(_buildChip('Собственици до: $ownerCountTo', context));
    } else if (filter.ownerCount != null) {
      chips.add(_buildChip('Собственици: ${filter.ownerCount}', context));
    }
    
    if (filter.region != null) {
      chips.add(_buildChip('Регион: ${filter.region}', context));
    }
    if (filter.city != null) {
      chips.add(_buildChip('Град: ${filter.city}', context));
    }
    if (filter.features != null && filter.features!.isNotEmpty) {
      chips.add(_buildChip('Екстри: ${filter.features!.join(", ")}', context));
    }
    if (filter.conditions != null && filter.conditions!.isNotEmpty) {
      chips.add(_buildChip('Състояние: ${filter.conditions!.join(", ")}', context));
    }

    return chips;
  }

  Widget _buildChip(String label, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isCurrentUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.assistant,
                color: Colors.white,
                size: 16,
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
              child: Text(
                message.text,
                style: TextStyle(
                  color: isCurrentUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: const Text(
                'Вие',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return BlocBuilder<AiAssistantBloc, AiAssistantState>(
      builder: (context, state) {
        final isDisabled = state.status == AiAssistantStatus.initializing ||
                          state.status == AiAssistantStatus.loading;
        
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
                  controller: _textController,
                  onSubmitted: isDisabled ? null : _handleSubmitted,
                  enabled: !isDisabled,
                  decoration: InputDecoration(
                    hintText: isDisabled 
                        ? (state.status == AiAssistantStatus.initializing 
                            ? 'Инициализиране...' 
                            : 'Изчаква отговор...')
                        : 'Напишете съобщение...',
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
                onPressed: isDisabled ? null : () => _handleSubmitted(_textController.text),
                backgroundColor: isDisabled ? Colors.grey : null,
                child: const Icon(Icons.send),
              ),
            ],
          ),
        );
      },
    );
  }
} 