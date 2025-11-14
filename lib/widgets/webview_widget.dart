
import 'package:fl_clash/common/proxy.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 由于依赖冲突问题，我们创建一个模拟的WebView组件
// 实际项目中可以使用webview_flutter或其他兼容的包
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
      _isLoading = true;
    });

    // 模拟页面加载
    widget.onPageStarted?.call(formattedUrl);
    widget.onUrlChanged?.call(formattedUrl);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _currentUrl = formattedUrl;
          _isLoading = false;
        });
        widget.onPageFinished?.call(formattedUrl);
      }
    });
  }

  void _goBack() {
    // 模拟后退功能
    print('WebView: Go back from $_currentUrl');
  }

  void _goForward() {
    // 模拟前进功能
    print('WebView: Go forward from $_currentUrl');
  }

  void _refresh() {
    setState(() {
      _isLoading = true;
    });

    // 模拟刷新
    widget.onPageStarted?.call(_currentUrl);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        widget.onPageFinished?.call(_currentUrl);
      }
    });
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
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'WebView模拟组件',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  '当前页面: $_currentUrl',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  '代理状态: ${isProxyEnabled ? '已启用' : '已禁用'}',
                  style: const TextStyle(fontSize: 16),
                ),
                if (isProxyEnabled) 
                  Text(
                    '代理端口: $proxyPort',
                    style: const TextStyle(fontSize: 14),
                  ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _loadUrl('https://www.google.com'),
                  child: const Text('加载Google'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _loadUrl('https://www.github.com'),
                  child: const Text('加载GitHub'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
