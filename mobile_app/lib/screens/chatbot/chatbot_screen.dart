import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import 'package:wagewise/app_localizations.dart';
import '../../providers/app_provider.dart';
import '../../models/chat_message.dart';
import '../../widgets/common_widgets.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});
  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  static const _suggestions = {
    ChatModule.labourRights: [
      'What is my overtime entitlement?',
      'How many days annual leave do I get?',
      'Can my employer extend my probation?',
    ],
    ChatModule.negotiationCoach: [
      'Help me negotiate a RM 4,500 offer',
      'How do I ask for a raise?',
      'Practice: HR gives me a lowball offer',
    ],
    ChatModule.contractAnalysis: [
      'Review this probation clause: 6 months with extension',
      'Is a 3-month notice period legal?',
      'Analyse: no overtime pay clause',
    ],
  };

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    context.read<AppProvider>().sendMessage(text).then((_) => _scrollToBottom());
  }

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

  Color _moduleColor(ChatModule m) {
    switch (m) {
      case ChatModule.labourRights: return AppColors.purple;
      case ChatModule.negotiationCoach: return AppColors.teal;
      case ChatModule.contractAnalysis: return AppColors.amber;
    }
  }


  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final provider = context.watch<AppProvider>();
    final module = provider.chatModule;
    final color = _moduleColor(module);
    final suggestions = _suggestions[module] ?? [];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(l.chatbotHeading),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _TabBtn(
                  label: l.labourRights,
                  icon: Icons.shield_outlined,
                  active: module == ChatModule.labourRights,
                  color: AppColors.purple,
                  onTap: () => context.read<AppProvider>().switchChatModule(ChatModule.labourRights),
                ),
                const SizedBox(width: 8),
                _TabBtn(
                  label: l.negotiation,
                  icon: Icons.mic,
                  active: module == ChatModule.negotiationCoach,
                  color: AppColors.teal,
                  onTap: () => context.read<AppProvider>().switchChatModule(ChatModule.negotiationCoach),
                ),
                const SizedBox(width: 8),
                _TabBtn(
                  label: l.contractReview,
                  icon: Icons.description_outlined,
                  active: module == ChatModule.contractAnalysis,
                  color: AppColors.amber,
                  onTap: () => context.read<AppProvider>().switchChatModule(ChatModule.contractAnalysis),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              children: [
                if (provider.messages.isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Try asking:', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                      const SizedBox(height: 8),
                      ...suggestions.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () { _inputCtrl.text = s; _send(); },
                          child: AppCard(
                            color: color.withValues(alpha: 0.08),
                            padding: const EdgeInsets.all(12),
                            child: Text(s, style: TextStyle(color: color, fontSize: 13)),
                          ),
                        ),
                      )),
                    ],
                  ),
                ...provider.messages.map((msg) => _MessageBubble(message: msg, accentColor: color)),
                if (provider.chatLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.muted)),
                        SizedBox(width: 8),
                        Text('Thinking...', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.card,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    maxLines: null,
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      hintText: l.typeMessage,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: provider.chatLoading ? null : _send,
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.icon, required this.active, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? color : AppColors.dimmed),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? color : AppColors.dimmed, size: 14),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: active ? color : AppColors.dimmed, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Color accentColor;
  const _MessageBubble({required this.message, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8, left: 60),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.gradientBlue),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(message.content, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, right: 60),
        child: AppCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Text('🤖 ', style: TextStyle(fontSize: 14)),
                Expanded(child: SizedBox()),
              ]),
              const SizedBox(height: 4),
              Text(message.content, style: const TextStyle(color: AppColors.text, fontSize: 14, height: 1.5)),
              if (message.sources.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Sources:', style: TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w600)),
                ...message.sources.map((s) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('• ${s.title} – ${s.section}', style: const TextStyle(color: AppColors.dimmed, fontSize: 11)),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

