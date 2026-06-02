import 'dart:io';
import 'package:diwanclinic/Presentation/parentControllers/chat_service.dart';
import 'package:diwanclinic/Presentation/screens/pharmacy_chat/pharmacy_chat_detail_vm.dart';
import '../../../index/index_main.dart';

/// Shared chat screen used by both patient and pharmacist.
/// [isPharmacySide] = true  → current user is the pharmacist
/// [isPharmacySide] = false → current user is the patient
class PharmacyChatDetailView extends StatefulWidget {
  final String pharmacyId;
  final String pharmacyName;
  final String patientId;
  final String patientName;
  final bool isPharmacySide;

  /// FCM token of the OTHER party — stored in thread so Cloud Function
  /// can notify them even before they send their first message.
  final String? receiverFcmToken;

  const PharmacyChatDetailView({
    super.key,
    required this.pharmacyId,
    required this.pharmacyName,
    required this.patientId,
    required this.patientName,
    required this.isPharmacySide,
    this.receiverFcmToken,
  });

  @override
  State<PharmacyChatDetailView> createState() =>
      _PharmacyChatDetailViewState();
}

// ─── Message group helper ────────────────────────────────────────
// Consecutive image messages from the same sender are merged into
// one group and displayed as a grid bubble.
class _MsgGroup {
  final bool isMe;
  final List<ChatMessage> msgs;
  bool get isImages => msgs.every((m) => m.isImage);
  _MsgGroup(this.isMe, this.msgs);
}

class _PharmacyChatDetailViewState extends State<PharmacyChatDetailView> {
  late final PharmacyChatDetailVm _vm;
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();

  int _uploadingCount = 0;

  String get _currentUserId =>
      widget.isPharmacySide ? widget.pharmacyId : widget.patientId;

  String get _currentUserName =>
      widget.isPharmacySide ? widget.pharmacyName : widget.patientName;

  String get _receiverId =>
      widget.isPharmacySide ? widget.patientId : widget.pharmacyId;

  String get _receiverName =>
      widget.isPharmacySide ? widget.patientName : widget.pharmacyName;

  String get _appBarTitle =>
      widget.isPharmacySide ? widget.patientName : widget.pharmacyName;

  String? get _senderFcmToken =>
      Get.find<UserSession>().user?.fcmToken;

  @override
  void initState() {
    super.initState();
    _vm = Get.put(PharmacyChatDetailVm(), tag: widget.pharmacyId);
    _vm.listenMessages(widget.patientId, widget.pharmacyId);

    final chatId =
        ChatService().pharmacyChatId(widget.patientId, widget.pharmacyId);
    if (widget.isPharmacySide) {
      _vm.markPharmacyRead(widget.pharmacyId, chatId);
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

  // ── Group consecutive image messages from same sender ──────────
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
      pharmacyId: widget.pharmacyId,
      pharmacyName: widget.pharmacyName,
      senderName: _currentUserName,
      receiverName: _receiverName,
      senderFcmToken: _senderFcmToken,
      receiverFcmToken: widget.receiverFcmToken,
    );
    _scrollToBottom();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(
      imageQuality: 60,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (picked.isEmpty) return;

    for (final file in picked) {
      setState(() => _uploadingCount++);
      _scrollToBottom();

      try {
        final ref = FirebaseStorage.instance.ref().child(
              "pharmacy_chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg",
            );
        await ref.putFile(File(file.path));
        final url = await ref.getDownloadURL();

        await _vm.sendMessage(
          text: url,
          senderId: _currentUserId,
          receiverId: _receiverId,
          pharmacyId: widget.pharmacyId,
          pharmacyName: widget.pharmacyName,
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
      child: GetBuilder<PharmacyChatDetailVm>(
        tag: widget.pharmacyId,
        builder: (vm) {
          final groups = _buildGroups(vm.messages);

          return Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              backgroundColor: AppColors.primary,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      widget.isPharmacySide
                          ? Icons.person
                          : Icons.local_pharmacy_rounded,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      _appBarTitle,
                      style: context.typography.lgBold
                          .copyWith(color: AppColors.white),
                      overflow: TextOverflow.ellipsis,
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
                              horizontal: 12.w, vertical: 8.h),
                          itemCount: groups.length + _uploadingCount,
                          itemBuilder: (_, i) {
                            if (i >= groups.length) {
                              return _UploadingBubble();
                            }
                            final group = groups[i];
                            if (group.isImages && group.msgs.length > 1) {
                              return _ImageGridBubble(
                                  urls: group.msgs
                                      .map((m) => m.text)
                                      .toList(),
                                  isMe: group.isMe);
                            }
                            final msg = group.msgs.first;
                            return _MessageBubble(
                                msg: msg, isMe: group.isMe);
                          },
                        ),
                ),
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
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
              SizedBox(height: 8.h),
              Text(
                "جاري الرفع...",
                style: context.typography.smRegular
                    .copyWith(color: AppColors.primary),
              ),
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
                color: Colors.black.withOpacity(0.06),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: _ImageTile(
            url: msg.text,
            width: 200.w,
            height: 160.h,
            allRadius: 18,
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.grayLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Text(
            msg.text,
            style: context.typography.smRegular.copyWith(
              color: isMe ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Image Grid Bubble — WhatsApp-style
//   2 images  → side by side
//   3 images  → 2 top + 1 full-width bottom
//   4+ images → 2×2 grid, last cell shows "+N"
// ─────────────────────────────────────────
class _ImageGridBubble extends StatelessWidget {
  final List<String> urls;
  final bool isMe;
  static const double _gap = 2;
  static const int _maxVisible = 4;

  const _ImageGridBubble({required this.urls, required this.isMe});

  @override
  Widget build(BuildContext context) {
    // All cells derived from a fixed grid width (scaled to device)
    final gridW = 240.w;
    final cellSide = (gridW - _gap) / 2;

    final visible = urls.take(_maxVisible).toList();
    final extra = urls.length - _maxVisible;

    // corner helpers
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
      // 4+ → 2×2
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
              // Last cell — may have "+N" overlay
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
                        onTap: () => Get.to(
                            () => ImageViewerScreen(imageUrls: urls)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(brCorner)),
                          child: Container(
                            color: Colors.black54,
                            child: Center(
                              child: Text(
                                "+$extra",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
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
                color: Colors.black.withOpacity(0.06),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          // Force LTR so Row children always appear left→right,
          // preventing RTL from swapping corners and image order.
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
  final double allRadius; // shortcut: all corners same value

  const _ImageTile({
    required this.url,
    required this.width,
    required this.height,
    this.borderRadius,
    this.allRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ??
        BorderRadius.circular(allRadius);

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
                    value: pct,
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.photo_library_rounded,
                  color: Colors.grey),
              onPressed: onPickImages,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.grayLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    hintText: "اكتب رسالة...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSend,
              child: const CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 24,
                child: Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
