import '../../../index/index_main.dart';

class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.grayLight,
        ),
        padding: const EdgeInsets.all(0),
        margin: const EdgeInsets.all(0),
      ),
    );
  }
}
