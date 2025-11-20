import 'package:fl_clash/common/proxy.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WebViewWidget extends ConsumerStatefulWidget {
  final String initialUrl;
  final Function(String)? onPageStarted;
  final Function(String)? onPageFinished;
  final Function(String)? onUrlChanged;
  final bool enableProxy;

  const WebViewWidget({
    Key? key,
    required this.initialUrl,
    this.onPageStarted,
    this.onPageFinished,
    this.onUrlChanged,
    this.enableProxy = true,
  }) : super(key: key);

  @override
  ConsumerState<WebViewWidget> createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends ConsumerState<WebViewWidget> {
  late String _currentUrl;
  late String _loadingUrl;
  bool _isLoading = false;
  final TextEditingController _urlController = TextEditingController();
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
    _loadingUrl = widget.initialUrl;
    _urlController.text = widget.initialUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _loadUrl(String url) {
    String formattedUrl = url;
    if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }

    setState(() {
      _loadingUrl = formattedUrl;
    });

    if (_webViewController != null) {
      _webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri(formattedUrl)));
      widget.onUrlChanged?.call(formattedUrl);
    }
  }

  void _goBack() {
    if (_webViewController != null) {
      _webViewController!.goBack();
    }
  }

  void _goForward() {
    if (_webViewController != null) {
      _webViewController!.goForward();
    }
  }

  void _refresh() {
    if (_webViewController != null) {
      _webViewController!.reload();
    }
  }

  // 获取当前代理状态
  bool _isProxyEnabled() {
    final proxyState = ref.read(proxyStateProvider);
    return proxyState.isStart && proxyState.systemProxy;
  }

  // 获取代理端口
  int _getProxyPort() {
    final proxyState = ref.read(proxyStateProvider);
    return proxyState.port;
  }

  @override
  Widget build(BuildContext context) {
    final proxyState = ref.watch(proxyStateProvider);
    final isProxyEnabled = proxyState.isStart && proxyState.systemProxy;
    final proxyPort = proxyState.port;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBack,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _goForward,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refresh,
              ),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _urlController,
                    onSubmitted: _loadUrl,
                    decoration: const InputDecoration(
                      hintText: '输入网址',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.navigate_next),
                onPressed: () => _loadUrl(_urlController.text),
              ),
            ],
          ),
        ),
        Expanded(
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
            onWebViewCreated: (controller) {
              _webViewController = controller;
              commonPrint.log('WebView created for URL: ${widget.initialUrl}');
            },
            onLoadStart: (controller, url) {
              setState(() {
                _loadingUrl = url.toString();
                _isLoading = true;
              });
              widget.onPageStarted?.call(url.toString());
              widget.onUrlChanged?.call(url.toString());
              commonPrint.log('WebView loading started: $url');
            },
            onLoadStop: (controller, url) async {
              setState(() {
                _currentUrl = url.toString();
                _isLoading = false;
              });
              widget.onPageFinished?.call(url.toString());
              
              // 更新地址栏URL
              _urlController.text = url.toString();
              
              // 验证代理设置是否生效
              if (widget.enableProxy && isProxyEnabled) {
                commonPrint.log('WebView loaded with proxy: port=$proxyPort');
              }
            },
            onLoadError: (controller, url, code, message) {
              setState(() {
                _isLoading = false;
              });
              commonPrint.log('WebView error: $message (code: $code, url: $url)', logLevel: LogLevel.error);
              
              // 如果是网络错误且代理启用，提示用户检查代理设置
              if (widget.enableProxy && isProxyEnabled && code == -2) {
                commonPrint.log('Network error detected, proxy may not be working properly', logLevel: LogLevel.warning);
              }
            },
            onProgressChanged: (controller, progress) {
              // 可以添加进度条显示
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url;
              if (url != null) {
                // 允许所有导航，但记录日志
                commonPrint.log('WebView navigating to: $url');
              }
              return NavigationActionPolicy.ALLOW;
            },
            initialOptions: InAppWebViewGroupOptions(
              android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
                // 确保 Android 上使用系统代理
                useShouldInterceptRequest: false,
              ),
              ios: IOSInAppWebViewOptions(
                allowsInlineMediaPlayback: true,
                // iOS 上使用系统代理设置
                allowsAirPlayForMediaPlayback: true,
              ),
              crossPlatform: InAppWebViewOptions(
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                // 启用 JavaScript 以便检测代理状态
                javaScriptEnabled: true,
                // 允许混合内容
                mixedContentMode: MixedContentMode.COMPATIBILITY_MODE,
                // 用户代理设置
                userAgent: 'FlClash-Browser/1.0',
              ),
            ),
          ),
        ),
      ],
    );
  }
}