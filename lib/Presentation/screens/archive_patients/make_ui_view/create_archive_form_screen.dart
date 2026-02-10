// import 'package:diwanclinic/Data/Models/archive_model/archive_field_model.dart';
// import 'package:diwanclinic/Presentation/screens/archive_patients/make_ui_view/create_archive_field_screen.dart';
// import 'package:flutter/material.dart';
//
// class CreateArchiveFormScreen extends StatefulWidget {
//   const CreateArchiveFormScreen({Key? key}) : super(key: key);
//
//   @override
//   State<CreateArchiveFormScreen> createState() =>
//       _CreateArchiveFormScreenState();
// }
//
// class _CreateArchiveFormScreenState
//     extends State<CreateArchiveFormScreen> {
//   final List<ArchiveFieldModel> fields = [];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Create Archive Form'),
//       ),
//
//       floatingActionButton: FloatingActionButton(
//         onPressed: _addField,
//         child: const Icon(Icons.add),
//       ),
//
//       body: fields.isEmpty
//           ? _emptyState()
//           : ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: fields.length,
//         itemBuilder: (context, index) {
//           return _fieldItem(fields[index], index);
//         },
//       ),
//
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ElevatedButton(
//           onPressed: fields.isNotEmpty ? _confirmForm : null,
//           child: const Text('Confirm Form'),
//         ),
//       ),
//     );
//   }
//
//   /// ================= EMPTY =================
//
//   Widget _emptyState() {
//     return const Center(
//       child: Text(
//         'No fields added yet',
//         style: TextStyle(fontSize: 16),
//       ),
//     );
//   }
//
//   /// ================= FIELD ITEM =================
//
//   Widget _fieldItem(ArchiveFieldModel field, int index) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ListTile(
//         title: Text(field.type.name),
//         subtitle: Text(field.type.name),
//         trailing: IconButton(
//           icon: const Icon(Icons.delete, color: Colors.red),
//           onPressed: () {
//             setState(() {
//               fields.removeAt(index);
//             });
//           },
//         ),
//       ),
//     );
//   }
//
//   /// ================= ADD FIELD =================
//
//   Future<void> _addField() async {
//     final field = await Navigator.push<ArchiveFieldModel>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => const CreateArchiveFieldScreen(),
//       ),
//     );
//
//     if (field != null) {
//       setState(() {
//         fields.add(field);
//       });
//     }
//   }
//
//   /// ================= CONFIRM =================
//
//   void _confirmForm() {
//     Navigator.pop(context, fields);
//   }
// }
