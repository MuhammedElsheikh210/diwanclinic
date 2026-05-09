import '../../../../../index/index_main.dart';

class FileCard extends StatelessWidget {
  final FilesModel file;
  final List<FilesModel?> allFiles;
  final int index;

  const FileCard({
    super.key,
    required this.file,
    required this.allFiles,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final imageUrls =
            allFiles
                .where((f) => f?.url != null && f!.url!.isNotEmpty)
                .map((f) => f!.url!)
                .toList();

        final initialIndex = imageUrls.indexOf(file.url ?? "");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ImageViewerScreen(
                  imageUrls: imageUrls,
                  initialIndex: initialIndex >= 0 ? initialIndex : 0,
                  title: file.type ?? "ملف طبي",
                ),
          ),
        );
      },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.white,
          border: Border.all(color: AppColors.borderNeutralPrimary, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child:
                    file.url != null && file.url!.isNotEmpty
                        ? Image.network(
                          file.url!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                        : Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.insert_drive_file,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                file.type ?? "ملف",
                style: context.typography.mdMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
