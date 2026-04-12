import 'dart:io';
import '../../../../index/index_main.dart';

class ChatView extends StatefulWidget{
  final String receiverId;
  final String receiverName;
  const ChatView({super.key,required this.receiverId,required this.receiverName});
  @override
  State<ChatView> createState()=>_ChatViewState();
}

class _ChatViewState extends State<ChatView>{
  final controller=Get.put(ChatViewModel());
  final messageController=TextEditingController();
  final scrollController=ScrollController();
  final ImagePicker _picker=ImagePicker();

  BaseUser? get user=>Get.find<UserSession>().user?.user;

  String _resolveUid(){
    final u=user;
    if(u==null)throw Exception("❌ No user");
    if(u is DoctorUser)return u.uid!;
    if(u is AssistantUser)return u.doctorKey!;
    return u.uid!;
  }

  @override
  void initState(){
    super.initState();
    final uid=_resolveUid();
    controller.listenMessages(uid,widget.receiverId);
  }

  void _sendMessage(){
    final text=messageController.text.trim();
    if(text.isEmpty)return;
    final uid=_resolveUid();
    controller.sendMessage(
      text,
      uid,
      widget.receiverId,
      senderName:user?.name,
      receiverName:widget.receiverName,
    );
    messageController.clear();
    _scrollToBottom();
  }

  Future<void> _pickAndUploadImages()async{
    final picked=await _picker.pickMultiImage(imageQuality:75);
    if(picked.isEmpty)return;
    final uid=_resolveUid();
    for(var file in picked){
      final ref=FirebaseStorage.instance.ref().child("chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg");
      await ref.putFile(File(file.path));
      final url=await ref.getDownloadURL();
      controller.sendMessage(
        url,
        uid,
        widget.receiverId,
        isImage:true,
        senderName:user?.name,
        receiverName:widget.receiverName,
      );
    }
    _scrollToBottom();
  }

  void _scrollToBottom(){
    Future.delayed(const Duration(milliseconds:300),(){
      if(scrollController.hasClients){
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap:()=>FocusScope.of(context).unfocus(),
      child:GetBuilder<ChatViewModel>(
        init:controller,
        builder:(vm){
          final uid=_resolveUid();
          return Scaffold(
            backgroundColor:AppColors.white,
            appBar:AppBar(
              backgroundColor:AppColors.primary,
              title:Row(
                children:[
                  const CircleAvatar(
                    backgroundColor:Colors.white,
                    child:Icon(Icons.person,color:Colors.grey),
                  ),
                  const SizedBox(width:12),
                  Text(
                    widget.receiverName,
                    style:context.typography.lgBold.copyWith(color:AppColors.white),
                  ),
                ],
              ),
            ),
            body:Column(
              children:[
                Expanded(
                  child:ListView.builder(
                    controller:scrollController,
                    padding:EdgeInsets.all(12.w),
                    itemCount:vm.messages.length,
                    itemBuilder:(_,i){
                      final msg=vm.messages[i];
                      final isMe=msg.senderId==uid;
                      return Align(
                        alignment:isMe?Alignment.centerRight:Alignment.centerLeft,
                        child:Container(
                          constraints:BoxConstraints(maxWidth:MediaQuery.of(context).size.width*0.75),
                          padding:const EdgeInsets.all(10),
                          margin:const EdgeInsets.symmetric(vertical:6),
                          decoration:BoxDecoration(
                            color:isMe?AppColors.primary:AppColors.grayLight,
                            borderRadius:BorderRadius.only(
                              topLeft:const Radius.circular(18),
                              topRight:const Radius.circular(18),
                              bottomLeft:isMe?const Radius.circular(18):Radius.zero,
                              bottomRight:isMe?Radius.zero:const Radius.circular(18),
                            ),
                            boxShadow:[
                              BoxShadow(
                                color:Colors.black.withOpacity(0.05),
                                blurRadius:5,
                                offset:const Offset(0,3),
                              ),
                            ],
                          ),
                          child:msg.isImage==true
                              ?ClipRRect(
                            borderRadius:BorderRadius.circular(12),
                            child:Image.network(msg.text,fit:BoxFit.cover),
                          )
                              :Text(
                            msg.text,
                            style:context.typography.smRegular.copyWith(
                              color:isMe?Colors.white:Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  child:Container(
                    padding:const EdgeInsets.symmetric(horizontal:12,vertical:8),
                    decoration:BoxDecoration(
                      color:AppColors.white,
                      boxShadow:[
                        BoxShadow(
                          color:Colors.black.withOpacity(0.05),
                          blurRadius:8,
                          offset:const Offset(0,-2),
                        ),
                      ],
                    ),
                    child:Row(
                      children:[
                        IconButton(
                          icon:const Icon(Icons.photo_library,color:Colors.grey),
                          onPressed:_pickAndUploadImages,
                        ),
                        Expanded(
                          child:Container(
                            decoration:BoxDecoration(
                              color:AppColors.grayLight.withOpacity(0.3),
                              borderRadius:BorderRadius.circular(25),
                            ),
                            child:TextField(
                              controller:messageController,
                              minLines:1,
                              maxLines:5,
                              decoration:const InputDecoration(
                                contentPadding:EdgeInsets.symmetric(horizontal:16,vertical:12),
                                hintText:"اكتب رسالة...",
                                border:InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width:8),
                        GestureDetector(
                          onTap:_sendMessage,
                          child:const CircleAvatar(
                            backgroundColor:AppColors.primary,
                            radius:24,
                            child:Icon(Icons.send_rounded,color:Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}