import '../../../../../index/index_main.dart';

class ArchivePatientView extends StatelessWidget {
  const ArchivePatientView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ArchivePatientViewModel>(
      init: ArchivePatientViewModel(),
      builder: (controller) {
        if (controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text("أرشيف المرضى")),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Get.to(() => const CreateArchivePatientView());
            },
            child: const Icon(Icons.add),
          ),

          body: controller.archives == null || controller.archives!.isEmpty
              ? const Center(child: Text("لا يوجد أرشيف بعد"))
              : ListView.builder(
                  itemCount: controller.archives!.length,
                  itemBuilder: (context, index) {
                    final archive = controller.archives![index];
                    return ListTile(
                      title: Text("مريض: ${archive.patientId}"),
                      subtitle: Text("تم الإنشاء: ${archive.createdAt}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          /// Edit
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Get.to(
                                () =>
                                    CreateArchivePatientView(archive: archive),
                              );
                            },
                          ),

                          /// Delete
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              controller.deleteArchive(archive.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
