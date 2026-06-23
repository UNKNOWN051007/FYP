import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
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

  // Picked file state
  Uint8List? _fileBytes;
  String? _fileName;

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

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'txt', 'md', 'csv'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    if (picked.bytes == null) return;
    setState(() {
      _fileBytes = picked.bytes;
      _fileName = picked.name;
    });
  }

  void _clearFile() => setState(() { _fileBytes = null; _fileName = null; });

  void _send() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty && _fileBytes == null) return;
    final query = text.isEmpty ? _fileName ?? 'Analyse this file' : text;
    _inputCtrl.clear();
    final bytes = _fileBytes;
    final name = _fileName;
    _clearFile();
    context.read<AppProvider>()
        .sendMessage(query, fileBytes: bytes, fileName: name)
        .then((_) => _scrollToBottom());
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

  Color _moduleColor(ChatModule m, WageColors c) {
    switch (m) {
      case ChatModule.labourRights: return c.purple;
      case ChatModule.negotiationCoach: return c.teal;
      case ChatModule.contractAnalysis: return c.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final c = context.wc;
    final provider = context.watch<AppProvider>();
    final module = provider.chatModule;
    final color = _moduleColor(module, c);
    final suggestions = _suggestions[module] ?? [];

    return Scaffold(
      backgroundColor: c.bg,
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
                  color: c.purple,
                  onTap: () => context.read<AppProvider>().switchChatModule(ChatModule.labourRights),
                ),
                const SizedBox(width: 8),
                _TabBtn(
                  label: l.negotiation,
                  icon: Icons.mic,
                  active: module == ChatModule.negotiationCoach,
                  color: c.teal,
                  onTap: () => context.read<AppProvider>().switchChatModule(ChatModule.negotiationCoach),
                ),
                const SizedBox(width: 8),
                _TabBtn(
                  label: l.contractReview,
                  icon: Icons.description_outlined,
                  active: module == ChatModule.contractAnalysis,
                  color: c.amber,
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
                      Text('Try asking:', style: TextStyle(color: c.muted, fontSize: 13)),
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
                ...provider.messages.map((msg) => _MessageBubble(message: msg, accentColor: color, colors: c)),
                if (provider.chatLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: c.muted)),
                        const SizedBox(width: 8),
                        Text('Thinking...', style: TextStyle(color: c.muted, fontSize: 13)),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── File preview chip ────────────────────────────────
          if (_fileName != null)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              color: c.card,
              child: Row(
                children: [
                  Icon(_fileIcon(_fileName!), size: 16, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _fileName!,
                      style: TextStyle(color: color, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: _clearFile,
                    child: Icon(Icons.close, size: 16, color: c.muted),
                  ),
                ],
              ),
            ),

          // ── Input row ────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.card,
              border: Border(top: BorderSide(color: c.border)),
            ),
            child: Row(
              children: [
                // Attach button
                GestureDetector(
                  onTap: provider.chatLoading ? null : _pickFile,
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: c.bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: c.border),
                    ),
                    child: Icon(
                      Icons.attach_file,
                      size: 18,
                      color: _fileBytes != null ? color : c.muted,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    maxLines: null,
                    style: TextStyle(color: c.text),
                    decoration: InputDecoration(
                      hintText: _fileBytes != null
                          ? 'Add a message or send file as-is...'
                          : l.typeMessage,
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

IconData _fileIcon(String name) {
  final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
  if (ext == 'pdf') return Icons.picture_as_pdf;
  if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext)) return Icons.image_outlined;
  return Icons.insert_drive_file_outlined;
}

class _TabBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.icon, required this.active, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.wc;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? color : c.dimmed),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? color : c.dimmed, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: active ? color : c.dimmed, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Color accentColor;
  final WageColors colors;
  const _MessageBubble({required this.message, required this.accentColor, required this.colors});

  @override
  Widget build(BuildContext context) {
    final c = colors;
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8, left: 60),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: c.gradientPrimary),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.attachmentName != null) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_fileIcon(message.attachmentName!), size: 13, color: Colors.white70),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        message.attachmentName!,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              Text(message.content, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
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
              Text(message.content, style: TextStyle(color: c.text, fontSize: 14, height: 1.5)),
              if (message.sources.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Sources:', style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w600)),
                ...message.sources.map((s) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('• ${s.title} – ${s.section}', style: TextStyle(color: c.dimmed, fontSize: 11)),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
