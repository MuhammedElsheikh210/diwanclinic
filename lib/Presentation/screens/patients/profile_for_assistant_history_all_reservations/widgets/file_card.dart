import '../../../../../index/index_main.dart';

class FileAssistantCard extends StatelessWidget {
  final FilesModel file;
  final List<FilesModel?> allFiles;
  final int index;

  const FileAssistantCard({
    required this.file,
    required this.allFiles,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final urls = allFiles
            .where((f) => f?.url != null && f!.url!.isNotEmpty)
            .map((f) => f!.url!)
            .toList();
        final initialIndex = urls.indexOf(file.url ?? "");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageViewerScreen(
              imageUrls: urls,
              initialIndex: initialIndex >= 0 ? initialIndex : 0,
              title: file.type ?? "ملف طبي",
            ),
          ),
        );
      },
      child: Container(
        width: 200.w,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderNeutralPrimary),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: file.url != null && file.url!.isNotEmpty
                    ? Image.network(file.url!, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.insert_drive_file, size: 40),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                file.type ?? "ملف",
                style: context.typography.smRegular,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
