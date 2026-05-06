import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/chat_model.dart';
import '../../../providers/workspace_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';
import '../../../core/translation/translation_extensions.dart';
import '../widgets/voice_message_bar.dart';

/// Chat screen for real-time project communication with supervisor.
///
/// Provides a messaging interface for doers to communicate with their
/// project supervisor, ask questions, and receive feedback.
///
/// ## Navigation
/// - Entry: From [ProjectDetailScreen] or [WorkspaceScreen] via chat button
/// - Project Info: Opens project details (icon button)
/// - Back: Returns to previous screen
///
/// ## Features
/// - Real-time message list with sender differentiation
/// - Date dividers between messages on different days
/// - Message bubbles with sender name and timestamp
/// - Read status indicators for sent messages
/// - System message support for notifications
/// - Attachment button (TODO: implement file sharing)
/// - Message input with send button
/// - Auto-scroll to latest message
///
/// ## Message Types
/// - text: Regular text messages
/// - system: System notifications (centered, gray style)
///
/// ## Visual Design
/// - Doer messages: Teal gradient, right-aligned
/// - Supervisor messages: White glass background, left-aligned with avatar
/// - System messages: Centered with info icon
///
/// ## State Variables
/// - [_messageController]: Text input controller
/// - [_scrollController]: List scroll controller for auto-scroll
///
/// ## State Management
/// Uses [WorkspaceProvider] for messages and send action.
///
/// See also:
/// - [WorkspaceProvider] for chat state
/// - [ChatMessageModel] for message model
/// - [_ChatBubble] for message rendering
/// - [MessageType] for message type enum
class ChatScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ChatScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final ValueNotifier<int> _recordingSeconds = ValueNotifier<int>(0);
  Timer? _recordingTimer;
  bool _isRecording = false;
  bool _isSendingVoice = false;

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _recordingSeconds.dispose();
    _audioRecorder.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isSendingVoice) return;

    if (_isRecording) {
      _recordingTimer?.cancel();
      String? filePath;
      try {
        filePath = await _audioRecorder.stop();
      } catch (_) {
        filePath = null;
      }

      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _isSendingVoice = true;
      });

      if (filePath != null && filePath.isNotEmpty) {
        final sent = await ref
            .read(workspaceProvider(widget.projectId))
            .sendVoiceMessage(filePath);
        if (mounted && !sent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send voice note')),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save recording')),
        );
      }

      if (filePath != null && filePath.isNotEmpty) {
        unawaited(() async {
          try {
            await File(filePath!).delete();
          } catch (_) {}
        }());
      }
      if (mounted) {
        setState(() {
          _isSendingVoice = false;
        });
      }
      return;
    }

    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) return;

    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: filePath,
    );

    if (!mounted) return;
    setState(() {
      _isRecording = true;
      _recordingSeconds.value = 0;
    });
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _recordingSeconds.value += 1;
    });
  }

  String _formatRecordingTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final workspaceNotifier = ref.watch(workspaceProvider(widget.projectId));
    final workspaceState = workspaceNotifier.state;
    final project = workspaceState.project;
    final messages = workspaceState.messages;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshGradientBackground(
        position: MeshPosition.bottomRight,
        opacity: 0.3,
        child: Column(
          children: [
            // Header
            _buildHeader(context, project),

            // Messages list
            Expanded(
              child: messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: AppSpacing.paddingMd,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final showDate = index == 0 ||
                            !_isSameDay(
                              messages[index - 1].sentAt,
                              message.sentAt,
                            );

                        return RepaintBoundary(
                          child: Column(
                            children: [
                              if (showDate)
                                _buildDateDivider(message.sentAt),
                              _ChatBubble(message: message),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Message input
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, project) {
    return GlassContainer(
      blur: 20,
      opacity: 0.9,
      borderRadius: BorderRadius.zero,
      borderColor: AppColors.border.withValues(alpha: 0.2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              color: AppColors.textPrimary,
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(
                Icons.support_agent,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Chat'.tr(context),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (project != null)
                    Text(
                      project.supervisorName ?? 'Supervisor',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // Show project info
              },
              icon: const Icon(Icons.info_outline),
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GlassContainer(
            blur: 15,
            opacity: 0.6,
            borderRadius: BorderRadius.circular(40),
            padding: AppSpacing.paddingLg,
            enableHoverEffect: false,
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No messages yet'.tr(context),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start a conversation with your supervisor'.tr(context),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDivider(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.border.withValues(alpha: 0.5))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: GlassContainer(
              blur: 8,
              opacity: 0.7,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              borderRadius: BorderRadius.circular(12),
              enableHoverEffect: false,
              child: Text(
                _formatDateLabel(date),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          Expanded(child: Divider(color: AppColors.border.withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return GlassContainer(
      blur: 20,
      opacity: 0.9,
      borderRadius: BorderRadius.zero,
      borderColor: AppColors.border.withValues(alpha: 0.2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Message input
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...'.tr(context),
                    hintStyle: TextStyle(
                      color: AppColors.textTertiary.withValues(alpha: 0.6),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                  ),
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button with gradient
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.accent,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _isSendingVoice ? null : _sendMessage,
                icon: const Icon(Icons.send, size: 18),
                color: Colors.white,
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: _isRecording ? Colors.red : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.3),
                ),
              ),
              child: IconButton(
                onPressed: _isSendingVoice ? null : _toggleRecording,
                icon: Icon(
                  _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  size: 22,
                  color: _isRecording ? Colors.white : AppColors.primary,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    ref
        .read(workspaceProvider(widget.projectId))
        .sendMessage(text);

    _messageController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}

/// Chat message bubble widget with sender-based styling.
///
/// Renders individual messages with appropriate alignment, colors,
/// and metadata based on sender type. Supports text and system messages.
///
/// ## Doer Messages (right-aligned)
/// - Teal gradient background
/// - White text
/// - Read status indicator (double check)
///
/// ## Supervisor Messages (left-aligned)
/// - White glass background with avatar
/// - Sender name header
/// - Gray timestamp
///
/// ## System Messages (centered)
/// - Glass background
/// - Info icon
/// - Muted styling
class _ChatBubble extends StatelessWidget {
  final ChatMessageModel message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isFromDoer = message.isFromDoer;
    final isSystem = message.type == MessageType.system;

    if (isSystem) {
      return _buildSystemMessage();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment:
            isFromDoer ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromDoer) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.accent.withValues(alpha: 0.1),
              child: Text(
                message.senderName.isNotEmpty
                    ? message.senderName[0].toUpperCase()
                    : 'S',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.74,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                // Doer: teal gradient, Receiver: white glass
                gradient: isFromDoer
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.primaryLight,
                        ],
                      )
                    : null,
                color: isFromDoer ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isFromDoer ? 16 : 4),
                  bottomRight: Radius.circular(isFromDoer ? 4 : 16),
                ),
                border: isFromDoer
                    ? null
                    : Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                boxShadow: [
                  BoxShadow(
                    color: isFromDoer
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isFromDoer)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.senderName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  if (!_voiceOnlyCaption(message) &&
                      message.content.trim().isNotEmpty)
                    Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: isFromDoer ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  if (message.hasFile) ...[
                    if (!_voiceOnlyCaption(message) &&
                        message.content.trim().isNotEmpty)
                      const SizedBox(height: 8),
                    if (_isAudioMessage(message))
                      Align(
                        alignment: Alignment.center,
                        child: VoiceMessageBar(
                          roomId: message.chatRoomId,
                          messageId: _voiceClipId(message),
                          audioUrl: message.fileUrl!,
                          playIconColor:
                              isFromDoer ? Colors.white : AppColors.primary,
                          progressBackgroundColor: isFromDoer
                              ? Colors.white.withValues(alpha: 0.35)
                              : AppColors.surface,
                          progressForegroundColor:
                              isFromDoer ? Colors.white : AppColors.primary,
                          timeLabelColor: isFromDoer
                              ? Colors.white.withValues(alpha: 0.95)
                              : AppColors.textSecondary,
                          pillBackgroundColor: isFromDoer
                              ? Colors.white.withValues(alpha: 0.18)
                              : AppColors.surface,
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isFromDoer
                              ? Colors.white.withValues(alpha: 0.2)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.attach_file,
                              size: 18,
                              color: isFromDoer ? Colors.white : AppColors.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              (message.fileName ?? 'Attachment').toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: isFromDoer ? Colors.white : AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.sentAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: isFromDoer
                              ? Colors.white.withValues(alpha: 0.75)
                              : AppColors.textTertiary,
                        ),
                      ),
                      if (isFromDoer) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.done_all,
                          size: 14,
                          color: Color(0xFF9FD7FF),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Center(
        child: GlassContainer(
          blur: 8,
          opacity: 0.7,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          borderRadius: BorderRadius.circular(12),
          enableHoverEffect: false,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  message.content,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  bool _isAudioMessage(ChatMessageModel msg) {
    final type = (msg.fileType ?? '').toLowerCase();
    final url = (msg.fileUrl ?? '').toLowerCase();
    final name = (msg.fileName ?? '').toLowerCase();
    final isVoiceByName = name.startsWith('voice_note_') ||
        name.contains('voice') ||
        name.contains('audio');
    final isAudioByExtension = url.endsWith('.m4a') ||
        url.endsWith('.mp3') ||
        url.endsWith('.wav') ||
        url.endsWith('.aac') ||
        url.endsWith('.ogg') ||
        url.endsWith('.webm') ||
        url.endsWith('.mp4');
    final looksLikeVoiceUpload =
        type == 'application/octet-stream' && (isVoiceByName || isAudioByExtension);
    return type.startsWith('audio/') ||
        isAudioByExtension ||
        looksLikeVoiceUpload ||
        msg.messageType.value == 'audio' ||
        msg.messageType.value == 'voice' ||
        isVoiceByName ||
        msg.content.toLowerCase().contains('voice');
  }

  bool _voiceOnlyCaption(ChatMessageModel msg) {
    if (!_isAudioMessage(msg)) return false;
    final t = msg.content.trim().toLowerCase();
    return t.isEmpty || t == 'voice note';
  }

  /// Build a stable unique key for voice playback rows.
  /// Some API payloads can carry empty/duplicate message IDs.
  String _voiceClipId(ChatMessageModel msg) {
    final rawId = msg.id.trim();
    if (rawId.isNotEmpty) return rawId;
    return '${msg.chatRoomId}:${msg.fileUrl ?? ''}:${msg.sentAt.microsecondsSinceEpoch}';
  }
}