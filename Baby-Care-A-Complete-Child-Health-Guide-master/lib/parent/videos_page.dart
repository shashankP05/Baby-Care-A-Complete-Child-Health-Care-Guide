import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  final List<String> _videoUrls = [
    'https://youtube.com/shorts/4zOMBg9e21E',
    'https://youtube.com/shorts/oOY8hQkIh0w',
    'https://youtube.com/shorts/0bF1qi_mPnQ',
    'https://youtube.com/shorts/nSqPqWL2LTs',
    'https://youtube.com/shorts/_E0mq1HLBmY',
    'https://youtube.com/shorts/amTmnnqQf_E',
    'https://youtube.com/shorts/ibpP7w5MY_o',
    'https://youtube.com/shorts/1mEvlDd505E',
    'https://youtube.com/shorts/mnhGlNfZU6w',
    'https://youtube.com/shorts/o0TEnh-FNfc',
    'https://youtube.com/shorts/A6srv-FdrpE',
    'https://youtube.com/shorts/tW7w0m6_-pU',
    'https://youtube.com/shorts/RSCQiwhLKiM',
    'https://youtube.com/shorts/mhWT3txnHWg',
    'https://youtube.com/shorts/WXdUZcfpb_c',
    'https://youtube.com/shorts/H93lU-czGvw',
    'https://youtube.com/shorts/481ibTLfE_E',
    'https://youtube.com/shorts/wvnIiBs_4GQ',
    'https://youtube.com/shorts/t4j8JWKGjVY',
    'https://youtube.com/shorts/_8M40cDeihg',
    'https://youtube.com/shorts/3qN75NmsAUE',
    'https://youtube.com/shorts/7B8TbOr2yjk',
    'https://youtube.com/shorts/uJSxrHWPnB4',
    'https://youtube.com/shorts/YY0zCkzkDEc',
    'https://youtu.be/gV9386Jv21c',
    'https://youtu.be/dhpCdqOtuj0',
    'https://youtu.be/slKV2AiUOFk',
    'https://youtu.be/l6XGE-Xuq3M',
    'https://youtu.be/4TpW-Qfjd-0',
    'https://youtu.be/FnRpNOYkCjw',
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _videoUrls.length,
          itemBuilder: (context, index) {
            return VideoItem(videoUrl: _videoUrls[index]);
          },
        ),
      ),
    );
  }
}

class VideoItem extends StatefulWidget {
  final String videoUrl;

  const VideoItem({
    super.key,
    required this.videoUrl,
  });

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> with AutomaticKeepAliveClientMixin {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _hideUnnecessaryElements();
            _unmuteVideo();
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.videoUrl));
  }

  void _unmuteVideo() {
    _controller.runJavaScript('''
      // Function to unmute video
      function unmuteVideo() {
        const video = document.querySelector('video');
        if (video) {
          video.muted = false;
          video.play();
        }
      }
      
      // Try to unmute immediately
      unmuteVideo();
      
      // Also try after a short delay to ensure video element is fully loaded
      setTimeout(unmuteVideo, 1000);
      
      // Add event listener for when video becomes available
      document.addEventListener('DOMNodeInserted', function(event) {
        if (event.target.nodeName === 'VIDEO') {
          unmuteVideo();
        }
      });
    ''');
  }

  void _hideUnnecessaryElements() {
    _controller.runJavaScript('''
      // Remove all YouTube branding and UI elements
      document.querySelector('ytd-miniplayer')?.remove();
      document.querySelector('ytd-masthead')?.remove();
      document.querySelector('ytd-guide-renderer')?.remove();
      document.querySelector('.ytp-chrome-top')?.remove();
      document.querySelector('.ytp-chrome-bottom')?.remove();
      document.querySelector('.ytp-watermark')?.remove();
      document.querySelector('.ytp-show-cards-title')?.remove();
      
      // Adjust video player styles
      document.body.style.backgroundColor = 'black';
      document.documentElement.style.backgroundColor = 'black';
      
      // Make video fill the screen
      const video = document.querySelector('video');
      if (video) {
        video.style.objectFit = 'cover';
        video.style.width = '100vw';
        video.style.height = '100vh';
        video.muted = false;  // Ensure video is unmuted
      }
      
      // Remove any remaining UI elements
      const elements = document.querySelectorAll('[id*="guide"], [id*="masthead"], [id*="banner"], [class*="ytp-"], [class*="ytd-"]');
      elements.forEach(el => el.remove());
    ''');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}