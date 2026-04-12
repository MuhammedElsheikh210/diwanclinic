import 'package:intl/intl.dart';
import '../../../../index/index_main.dart';

class OpenclosereservationViewModel extends GetxController{
  List<LegacyQueueModel?>? list;
  final LegacyQueueService service=LegacyQueueService();
  List<GenericListModel>? shiftDropdownItems;
  GenericListModel? selectedShift;
  List<LocalUser?>? centerDoctors;
  LocalUser? selectedDoctor;
  bool isLoadingDoctors=false;
  bool _shiftInitialized=false;
  DateTime selectedDate=DateTime.now();

  BaseUser? get _user=>Get.find<UserSession>().user?.user;

  bool get isCenterMode=>_user is AssistantUser && (_user as AssistantUser).clinicKey!=null;

  String get formattedDate=>DateFormat('dd-MM-yyyy').format(selectedDate);

  bool get isSelectedDayClosed{
    if(list==null||list!.isEmpty)return false;
    return list!.first?.isClosed==true;
  }

  @override
  void onInit(){
    super.onInit();
    if(isCenterMode){
      loadDoctorsOfCenter();
    }else{
      getData();
    }
  }

  Future<void> loadDoctorsOfCenter()async{
    final user=_user;
    final centerKey=(user is AssistantUser)?user.clinicKey:null;
    if(centerKey==null)return;

    isLoadingDoctors=true;
    update();

    AuthenticationService().getClientsData(
      query:SQLiteQueryParams(
        where:"medicalCenterKey = ? AND userType = ?",
        whereArgs:[centerKey,"doctor"],
      ),
      voidCallBack:(data)async{
        centerDoctors=data;
        if(data.isNotEmpty){
          selectedDoctor=data.first;
          getData();
        }
        isLoadingDoctors=false;
        update();
      },
    );
  }

  Future<void> getShiftList({String? clinic_key})async{
    final user=_user;

    final clinicKey=clinic_key??(user is AssistantUser?user.clinicKey:null);
    final doctorKey=isCenterMode
        ?selectedDoctor?.uid
        :(user is AssistantUser?user.doctorKey:user?.uid);

    if(clinicKey==null||doctorKey==null)return;

    ShiftService().getShiftsData(
      data:FirebaseFilter(orderBy:"clinicKey",equalTo:clinicKey),
      doctorKey:doctorKey,
      query:SQLiteQueryParams(
        is_filtered:true,
        where:"clinicKey = ?",
        whereArgs:[clinicKey],
      ),
      voidCallBack:(data)async{
        if(data!=null&&data.isNotEmpty){
          shiftDropdownItems=ShiftModelAdapterUtil.convertShiftListToGeneric(data);
          if(shiftDropdownItems!.length==1){
            selectedShift=shiftDropdownItems!.first;
            _shiftInitialized=true;
          }
        }else{
          shiftDropdownItems=[];
        }
        update();
      },
    );
  }

  void getData(){
    final user=_user;

    final clinicKey=(user is AssistantUser)?user.clinicKey:null;

    service.getOpenCloseDaysByDateData(
      date:"",
      firebaseFilter:isCenterMode
          ?FirebaseFilter()
          :FirebaseFilter(orderBy:"clinic_key",equalTo:clinicKey),
      doctorUid:selectedDoctor?.uid??(user is AssistantUser?user.doctorKey:user?.uid),
      voidCallBack:(data){
        list=data;
        update();
      },
    );
  }

  void onDateChanged(DateTime date){
    selectedDate=date;
    update();
  }

  void toggleDayStatus(LegacyQueueModel model,{required bool isClosed}){
    final user=_user;

    final doctorUid=isCenterMode
        ?selectedDoctor?.uid
        :(user is AssistantUser?user.doctorKey:user?.uid);

    final updated=model.copyWith(isClosed:isClosed);

    service.updateLegacyQueueData(
      model:updated,
      doctorUid:doctorUid,
      voidCallBack:(status){
        if(status==ResponseStatus.success){
          Loader.dismiss();
          getData();
        }
      },
    );
  }

  void deleteItem(LegacyQueueModel model){
    final user=_user;

    final doctorUid=isCenterMode
        ?selectedDoctor?.uid
        :(user is AssistantUser?user.doctorKey:user?.uid);

    service.deleteLegacyQueueData(
      doctorUid:doctorUid,
      date:"",
      key:model.key??"",
      isOpenClosed:true,
      voidCallBack:(status){
        Loader.dismiss();
        if(status==ResponseStatus.success){
          getData();
        }
      },
    );
  }
}