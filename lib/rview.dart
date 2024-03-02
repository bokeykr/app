import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'review.dart';

class RViewPage extends StatefulWidget {
  final String title;
  final String no;
  const RViewPage({super.key, required this.title, required this.no});

  @override
  State<RViewPage> createState() => _RViewPageState();
}

class _RViewPageState extends State<RViewPage> {
  final int _selectedIndex = 1;
  _onItemTapped(ndx) async {
    if (ndx == 0) {
      await Share.share(
          '${widget.title} https://honmall.net/rview.php?no=${widget.no}');
    } else if (ndx == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const ReviewPage()));
    }
  }

  late PlatformWebViewController _controller;
  @override
  void initState() {
    super.initState();
    _controller = PlatformWebViewController(
      const PlatformWebViewControllerCreationParams(),
    )..loadRequest(
        LoadRequestParams(
          uri: Uri.parse('https://honmall.net/rview.php?no=${widget.no}'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PlatformWebViewWidget(
        PlatformWebViewWidgetCreationParams(controller: _controller),
      ).build(context),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.share_rounded),
            label: '공유',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '타로 후기',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
