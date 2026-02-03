import '../../../../../index/index_main.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  bool isLoading = false;
  String result = "";
  final notificationManager = NotificationManager();

  final String testTopic = 'clinic_updates';

  // Example tokens for testing multi-device send
  final List<String> testTokens = [
    "fID0M4SHkESDgI4TOs2ebb:APA91bEao0bS2nT3kCIRwqHTtCVljQB3GH1QeibYtG2_dD6h4ifQxAmVOGCv1xp1XGxMg50lgacux-Q03nns1q511WSM6CFjmMgzb1cNJ1Ppse0QQAmBr9k",
    "fID0M4SHkESDgI4TOs2ebb:APA91bEao0bS2nT3kCIRwqHTtCVljQB3GH1QeibYtG2_dD6h4ifQxAmVOGCv1xp1XGxMg50lgacux-Q03nns1q511WSM6CFjmMgzb1cNJ1Ppse0QQAmBr9k",
    // Add more FCM tokens for testing
  ];

  @override
  void initState() {
    super.initState();
    notificationManager.init();
  }

  // ---------------------------------------------------------------------------
  // 🔹 Single Device Send
  // ---------------------------------------------------------------------------
  Future<void> _sendToDevice() async {
    setState(() => isLoading = true);
    final res = await notificationManager.sendToDevice(
      title: titleController.text.trim(),
      body: bodyController.text.trim(),
    );
    setState(() {
      result = res;
      isLoading = false;
    });
  }

  // ---------------------------------------------------------------------------
  // 🔹 Subscribe ➜ Send (should receive message)
  // ---------------------------------------------------------------------------
  Future<void> _subscribeAndSend() async {
    setState(() {
      isLoading = true;
      result = "⏳ Subscribing to topic $testTopic...";
    });

    await notificationManager.subscribeToTopic(testTopic);

    setState(() {
      result = "✅ Subscribed to $testTopic. Sending notification...";
    });

    final sendResult = await notificationManager.sendToTopic(
      topic: testTopic,
      title: titleController.text.trim(),
      body: bodyController.text.trim(),
    );

    setState(() {
      result = "✅ Subscribed and message sent:\n$sendResult";
      isLoading = false;
    });
  }

  // ---------------------------------------------------------------------------
  // 🔹 Unsubscribe ➜ Send (should NOT receive message)
  // ---------------------------------------------------------------------------
  Future<void> _unsubscribeAndSend() async {
    setState(() {
      isLoading = true;
      result = "⏳ Unsubscribing from topic $testTopic...";
    });

    await notificationManager.unsubscribeFromTopic(testTopic);

    setState(() {
      result =
      "✅ Unsubscribed from $testTopic. Sending notification (you should NOT receive it)...";
    });

    final sendResult = await notificationManager.sendToTopic(
      topic: testTopic,
      title: titleController.text.trim(),
      body: bodyController.text.trim(),
    );

    setState(() {
      result =
      "$sendResult\n⚠️ Device is unsubscribed — should not receive this.";
      isLoading = false;
    });
  }

  // ---------------------------------------------------------------------------
  // 🔹 Send to Multiple Devices
  // ---------------------------------------------------------------------------
  Future<void> _sendToMultipleDevices() async {
    setState(() {
      isLoading = true;
      result = "⏳ Sending notification to ${testTokens.length} devices...";
    });

    final sendResult = await notificationManager.sendToMultipleDevices(
      tokens: testTokens,
      title: titleController.text.trim(),
      body: bodyController.text.trim(),
    );

    setState(() {
      result = "✅ Multi-device send complete:\n$sendResult";
      isLoading = false;
    });
  }

  // ---------------------------------------------------------------------------
  // 🔹 UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test FCM Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(labelText: 'Body'),
              ),
              const SizedBox(height: 30),

              // -----------------------------------------------------------------
              // 🔹 Buttons
              // -----------------------------------------------------------------
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _subscribeAndSend,
                      child: const Text('Subscribe ➜ Send'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _unsubscribeAndSend,
                      child: const Text('Unsubscribe ➜ Send'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _sendToDevice,
                      child: const Text('Send to My Device'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _sendToMultipleDevices,
                      child: const Text('Send to Multiple Devices'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              if (isLoading)
                const CircularProgressIndicator()
              else
                Text(
                  result,
                  style: TextStyle(
                    color: result.contains('✅')
                        ? Colors.green
                        : Colors.redAccent,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
