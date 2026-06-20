import 'dart:io';
import 'package:diwanclinic/Presentation/parentControllers/chat_service.dart';
import 'package:diwanclinic/Presentation/screens/assistant_chat/assistant_chat_detail_vm.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../../index/index_main.dart';

/// Shared chat screen for both patient and assistant.
/// [isAssistantSide] = true  → current user is the assistant
/// [isAssistantSide] = false → current user is the patient
/// [isReadOnly] = true       → doctor view: read-only, no input bar, no notifications
class AssistantChatDetailView extends StatefulWidget {
  final String assistantId; // = doctorKey
  final String assistantName;
  final String patientId;
  final String patientName;
  final bool isAssistantSide;
  final String? receiverFcmToken;
  final bool isReadOnly;

  const AssistantChatDetailView({
    super.key,
    required this.assistantId,
    required this.assistantName,
    required this.patientId,
    required this.patientName,
    required this.isAssistantSide,
    this.receiverFcmToken,
    this.isReadOnly = false,
  });

  @override
  State<AssistantChatDetailView> createState() =>
      _AssistantChatDetailViewState();
}

// ── Group consecutive image messages from same sender ──
class _MsgGroup {
  final bool isMe;
  final List<ChatMessage> msgs;
  bool get isImages => msgs.every((m) => m.isImage);
  _MsgGroup(this.isMe, this.msgs);
}

class _AssistantChatDetailViewState extends State<AssistantChatDetailView> {
  late final AssistantChatDetailVm _vm;
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();

  int _uploadingCount = 0;

  String get _currentUserId =>
      widget.isAssistantSide ? widget.assistantId : widget.patientId;

  String get _currentUserName =>
      widget.isAssistantSide ? widget.assistantName : widget.patientName;

  String get _receiverId =>
      widget.isAssistantSide ? widget.patientId : widget.assistantId;

  String get _receiverName =>
      widget.isAssistantSide ? widget.patientName : widget.assistantName;

  String get _appBarTitle =>
      widget.isAssistantSide ? widget.patientName : widget.assistantName;

  String? get _senderFcmToken =>
      Get.find<UserSession>().user?.fcmToken;

  @override
  void initState() {
    super.initState();
    _vm = Get.put(AssistantChatDetailVm(), tag: widget.assistantId + widget.patientId);
    _vm.listenMessages(widget.patientId, widget.assistantId);

    final chatId = ChatService().assistantChatId(widget.patientId, widget.assistantId);
    if (widget.isAssistantSide) {
      _vm.markAssistantRead(widget.assistantId, chatId);
    } else {
      _vm.markPatientRead(widget.patientId, chatId);
    }
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<_MsgGroup> _buildGroups(List<ChatMessage> messages) {
    final groups = <_MsgGroup>[];
    for (final msg in messages) {
      final isMe = msg.senderId == _currentUserId;
      if (msg.isImage &&
          groups.isNotEmpty &&
          groups.last.isImages &&
          groups.last.isMe == isMe) {
        groups.last.msgs.add(msg);
      } else {
        groups.add(_MsgGroup(isMe, [msg]));
      }
    }
    return groups;
  }

  void _sendText() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();
    _vm.sendMessage(
      text: text,
      senderId: _currentUserId,
      receiverId: _receiverId,
      assistantId: widget.assistantId,
      assistantName: widget.assistantName,
      senderName: _currentUserName,
      receiverName: _receiverName,
      senderFcmToken: _senderFcmToken,
      receiverFcmToken: widget.receiverFcmToken,
    );
    _scrollToBottom();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;

    for (final file in picked) {
      setState(() => _uploadingCount++);
      _scrollToBottom();

      try {
        final compressed = await _compressImage(file.path);
        final imageFile = compressed ?? File(file.path);

        final ref = FirebaseStorage.instance.ref().child(
              "assistant_chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg",
            );
        await ref.putFile(imageFile);
        final url = await ref.getDownloadURL();

        await _vm.sendMessage(
          text: url,
          senderId: _currentUserId,
          receiverId: _receiverId,
          assistantId: widget.assistantId,
          assistantName: widget.assistantName,
          isImage: true,
          senderName: _currentUserName,
          receiverName: _receiverName,
          senderFcmToken: _senderFcmToken,
          receiverFcmToken: widget.receiverFcmToken,
        );
      } finally {
        setState(() => _uploadingCount--);
      }

      _scrollToBottom();
    }
  }

  Future<File?> _compressImage(String path) async {
    try {
      final dir = await getTemporaryDirectory();
      final target =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_c.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        path,
        target,
        quality: 60,
        minWidth: 1024,
        minHeight: 1024,
      );
      return result != null ? File(result.path) : null;
    } catch (_) {
      return null;
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: GetBuilder<AssistantChatDetailVm>(
        tag: widget.assistantId + widget.patientId,
        builder: (vm) {
          final groups = _buildGroups(vm.messages);

          return Scaffold(
            backgroundColor: const Color(0xFFECE5DD),
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      widget.isAssistantSide
                          ? Icons.person_rounded
                          : Icons.support_agent_rounded,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _appBarTitle,
                          style: context.typography.lgBold
                              .copyWith(color: AppColors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.isReadOnly
                              ? "عرض فقط"
                              : widget.isAssistantSide
                                  ? "مريض"
                                  : "المساعدة",
                          style: context.typography.smRegular.copyWith(
                            color: Colors.white70,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: groups.isEmpty && _uploadingCount == 0
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 60.sp,
                                color: AppColors.grayMedium,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                "ابدأ المحادثة...",
                                style: context.typography.mdRegular
                                    .copyWith(color: AppColors.grayMedium),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 10.h),
                          itemCount: groups.length + _uploadingCount,
                          itemBuilder: (_, i) {
                            if (i >= groups.length) {
                              return _UploadingBubble();
                            }
                            final group = groups[i];
                            if (group.isImages && group.msgs.length > 1) {
                              return _ImageGridBubble(
                                  urls: group.msgs.map((m) => m.text).toList(),
                                  isMe: group.isMe);
                            }
                            final msg = group.msgs.first;
                            return _MessageBubble(msg: msg, isMe: group.isMe);
                          },
                        ),
                ),
                if (!widget.isReadOnly)
                  _InputBar(
                    controller: _msgController,
                    onSend: _sendText,
                    onPickImages: _pickImages,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────
// Uploading placeholder bubble
// ─────────────────────────────────────────
class _UploadingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 180.w,
        height: 140.h,
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.15),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2.5),
              SizedBox(height: 8.h),
              Text("جاري الرفع...",
                  style: context.typography.smRegular
                      .copyWith(color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Single message bubble (text or 1 image)
// ─────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  final bool isMe;

  const _MessageBubble({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    if (msg.isImage) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 5,
                  offset: const Offset(0, 3))
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: _ImageTile(
              url: msg.text, width: 200.w, height: 160.h, allRadius: 18),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                msg.text,
                style: context.typography.smRegular.copyWith(
                  color: isMe ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _formatTime(msg.timestamp),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isMe ? Colors.white60 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int ts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour < 12 ? "ص" : "م";
    return "$h:$m $amPm";
  }
}

// ─────────────────────────────────────────
// Image Grid Bubble — WhatsApp-style
// ─────────────────────────────────────────
class _ImageGridBubble extends StatelessWidget {
  final List<String> urls;
  final bool isMe;
  static const double _gap = 2;
  static const int _maxVisible = 4;

  const _ImageGridBubble({required this.urls, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final gridW = 240.w;
    final cellSide = (gridW - _gap) / 2;
    final visible = urls.take(_maxVisible).toList();
    final extra = urls.length - _maxVisible;

    br(double tl, double tr, double bl, double bk) => BorderRadius.only(
          topLeft: Radius.circular(tl),
          topRight: Radius.circular(tr),
          bottomLeft: Radius.circular(bl),
          bottomRight: Radius.circular(bk),
        );

    final blCorner = isMe ? 18.0 : 0.0;
    final brCorner = isMe ? 0.0 : 18.0;

    Widget grid;

    if (visible.length == 2) {
      grid = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ImageTile(
              url: visible[0],
              width: cellSide,
              height: cellSide,
              borderRadius: br(18, 0, blCorner, 0)),
          const SizedBox(width: _gap),
          _ImageTile(
              url: visible[1],
              width: cellSide,
              height: cellSide,
              borderRadius: br(0, 18, 0, brCorner)),
        ],
      );
    } else if (visible.length == 3) {
      grid = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ImageTile(
                  url: visible[0],
                  width: cellSide,
                  height: cellSide,
                  borderRadius: br(18, 0, 0, 0)),
              const SizedBox(width: _gap),
              _ImageTile(
                  url: visible[1],
                  width: cellSide,
                  height: cellSide,
                  borderRadius: br(0, 18, 0, 0)),
            ],
          ),
          const SizedBox(height: _gap),
          _ImageTile(
              url: visible[2],
              width: gridW,
              height: cellSide,
              borderRadius: br(0, 0, blCorner, brCorner)),
        ],
      );
    } else {
      grid = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ImageTile(
                  url: visible[0],
                  width: cellSide,
                  height: cellSide,
                  borderRadius: br(18, 0, 0, 0)),
              const SizedBox(width: _gap),
              _ImageTile(
                  url: visible[1],
                  width: cellSide,
                  height: cellSide,
                  borderRadius: br(0, 18, 0, 0)),
            ],
          ),
          const SizedBox(height: _gap),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ImageTile(
                  url: visible[2],
                  width: cellSide,
                  height: cellSide,
                  borderRadius: br(0, 0, blCorner, 0)),
              const SizedBox(width: _gap),
              Stack(
                children: [
                  _ImageTile(
                      url: visible[3],
                      width: cellSide,
                      height: cellSide,
                      borderRadius: br(0, 0, 0, brCorner)),
                  if (extra > 0)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () =>
                            Get.to(() => ImageViewerScreen(imageUrls: urls)),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.only(bottomRight: Radius.circular(brCorner)),
                          child: Container(
                            color: Colors.black54,
                            child: Center(
                              child: Text(
                                "+$extra",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => Get.to(() => ImageViewerScreen(imageUrls: urls)),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 5,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: grid,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Reusable network image tile
// ─────────────────────────────────────────
class _ImageTile extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final double allRadius;

  const _ImageTile({
    required this.url,
    required this.width,
    required this.height,
    this.borderRadius,
    this.allRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(allRadius);

    return GestureDetector(
      onTap: () => Get.to(() => ImageViewerScreen(imageUrls: [url])),
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: width,
          height: height,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              final pct = progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null;
              return Container(
                color: Colors.grey.shade200,
                child: Center(
                  child: CircularProgressIndicator(
                      value: pct, color: AppColors.primary, strokeWidth: 2.5),
                ),
              );
            },
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image_rounded,
                  color: Colors.grey, size: 40),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Input Bar
// ─────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPickImages;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.onPickImages,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFECE5DD),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -1))
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file_rounded, color: Colors.grey),
              onPressed: onPickImages,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4)
                  ],
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    hintText: "اكتب رسالة...",
                    hintStyle: TextStyle(
                        color: Colors.grey.shade400, fontSize: 14.sp),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
