import '../../../../../Global/Utils/pdf_reader.dart';
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
        final urls = allFiles
            .where((f) => f?.url != null && f!.url!.isNotEmpty)
            .map((f) => f!.url!)
            .toList();
        final initialIndex = urls.indexOf(file.url ?? "");

        if (file.type?.contains("PDF") != true) {
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
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GenericPdfViewer(
               pdfUrl: urls[initialIndex],
              ),
            ),
          );
        }
      },
      child: Container(
        width: 160.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderNeutralPrimary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ الصورة أو أيقونة الملف
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: file.url != null && file.url!.isNotEmpty
                    ? Image.network(
                        file.url!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 40),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.insert_drive_file, size: 40),
                      ),
              ),
            ),

            // ✅ النص تحت
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                file.type ?? "ملف",
                style: context.typography.smRegular,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
