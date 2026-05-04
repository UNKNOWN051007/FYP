import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/chat_message.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String? _coachScenario;

  static const _tabs = [
    _TabInfo('rights', 'Labour Rights', Icons.shield_outlined, AppColors.purple),
    _TabInfo('coach', 'Negotiation', Icons.bolt_rounded, AppColors.teal),
    _TabInfo('contract', 'Contract', Icons.description_outlined, AppColors.amber),
  ];

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    await context.read<AppProvider>().sendMessage(text);
    _scrollToBottom();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final module = provider.chatModule;
    final tab = _tabs.firstWhere((t) => t.key == module, orElse: () => _tabs[0]);

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.purple.withOpacity(0.15),
                    ),
                    child: const Icon(Icons.smart_toy_outlined,
                        color: AppColors.purple, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Labour Rights Chatbot',
                          style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w700,
                              fontSize: 17)),
                      Text('Ask anything about Malaysian employment law',
                          style: TextStyle(
                              color: AppColors.muted, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Tab bar
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: _tabs.map((t) {
                    final isActive = module == t.key;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          context.read<AppProvider>().switchChatModule(t.key);
                          setState(() => _coachScenario = null);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isActive
                                ? t.color.withOpacity(0.2)
                                : Colors.transparent,
                          ),
                          child: Column(
                            children: [
                              Icon(t.icon,
                                  size: 16,
                                  color: isActive ? t.color : AppColors.dimmed),
                              const SizedBox(height: 3),
                              Text(t.label,
                                  style: TextStyle(
                                      color:
                                          isActive ? t.color : AppColors.muted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),

        // Suggested topics (rights tab)
        if (module == 'rights' && provider.messages.length <= 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Suggested Topics',
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: const [
                    'What is my EPF entitlement?',
                    'Is my notice period legal?',
                    'Overtime pay rights',
                    'Maternity leave policy',
                  ]
                      .map((t) => _TopicChip(
                            label: t,
                            onTap: () {
                              _inputCtrl.text = t;
                              _send();
                            },
                          ))
                      .toList(),
                ),
              ],
            ),
          ),

        // Negotiation coach scenario selector
        if (module == 'coach' && _coachScenario == null)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
              child: Column(
                children: [
                  AppCard(
                    color: const Color(0xFF0E2020),
                    borderColor: AppColors.teal.withOpacity(0.2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🤝',
                            style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(provider.messages.first.content,
                            style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                                height: 1.6)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...[
                    _ScenarioCard(
                      emoji: '⬇️',
                      title: 'The Lowball Offer',
                      desc: 'Practice responding to a below-market offer with confidence and data.',
                      color: AppColors.teal,
                      onTap: () {
                        setState(() => _coachScenario = 'lowball');
                        context.read<AppProvider>().sendMessage(
                            'Start the lowball offer scenario. You are the HR and I am the candidate.');
                        _scrollToBottom();
                      },
                    ),
                    const SizedBox(height: 10),
                    _ScenarioCard(
                      emoji: '📈',
                      title: 'Asking for a Raise',
                      desc: 'Practice requesting a raise from your current employer.',
                      color: AppColors.accent,
                      onTap: () {
                        setState(() => _coachScenario = 'raise');
                        context.read<AppProvider>().sendMessage(
                            'Start the asking for a raise scenario. You are my current manager.');
                        _scrollToBottom();
                      },
                    ),
                  ],
                ],
              ),
            ),
          )
        else ...[
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
              itemCount: provider.messages.length + (provider.chatLoading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == provider.messages.length) {
                  return const _TypingIndicator();
                }
                return _MessageBubble(message: provider.messages[i]);
              },
            ),
          ),
          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    style: const TextStyle(color: AppColors.text, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: module == 'contract'
                          ? 'Paste contract clause...'
                          : 'Ask a question...',
                      hintStyle:
                          const TextStyle(color: AppColors.muted),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: module == 'coach'
                            ? [AppColors.teal, const Color(0xFF0EA5E9)]
                            : module == 'contract'
                                ? [AppColors.amber, const Color(0xFFF97316)]
                                : [AppColors.purple, const Color(0xFF6366F1)],
                      ),
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TabInfo {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  const _TabInfo(this.key, this.label, this.icon, this.color);
}

class _TopicChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TopicChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppColors.purple.withOpacity(0.3), width: 1),
          ),
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.purple, fontSize: 11, fontWeight: FontWeight.w500)),
        ),
      );
}

class _ScenarioCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String desc;
  final Color color;
  final VoidCallback onTap;

  const _ScenarioCard({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AppCard(
          borderColor: color.withOpacity(0.2),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: color.withOpacity(0.15),
                ),
                child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(desc,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12, height: 1.4)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.dimmed, size: 20),
            ],
          ),
        ),
      );
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isBot = message.isBot;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBot) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.purple.withOpacity(0.2),
              ),
              child:
                  const Center(child: Text('🤖', style: TextStyle(fontSize: 14))),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: isBot
                    ? null
                    : const LinearGradient(
                        colors: [AppColors.accent, Color(0xFF6366F1)]),
                color: isBot ? AppColors.card : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isBot ? 4 : 16),
                  bottomRight: Radius.circular(isBot ? 16 : 4),
                ),
                border: isBot
                    ? Border.all(color: AppColors.border, width: 1)
                    : null,
              ),
              child: Text(
                message.content,
                style: const TextStyle(
                    color: AppColors.text, fontSize: 13, height: 1.6),
              ),
            ),
          ),
          if (!isBot) const SizedBox(width: 10),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.purple.withOpacity(0.2),
            ),
            child:
                const Center(child: Text('🤖', style: TextStyle(fontSize: 14))),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text('Thinking…',
                style: TextStyle(color: AppColors.muted, fontSize: 13)),
          ),
        ],
      );
}
