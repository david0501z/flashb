
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';

class BrowserView extends StatefulWidget {
  const BrowserView({Key? key}) : super(key: key);

  @override
  State<BrowserView> createState() => _BrowserViewState();
}

class _BrowserViewState extends State<BrowserView> {
  final List<String> _tabs = ['https://www.google.com'];
  int _currentTabIndex = 0;
  String _currentUrl = 'https://www.google.com';

  @override
  void initState() {
    super.initState();
  }

  void _showTabMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.2,
              maxChildSize: 0.8,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '标签页',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setModalState(() {
                                _tabs.add('https://www.google.com');
                                _currentTabIndex = _tabs.length - 1;
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: _tabs.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                title: Text(_tabs[index]),
                                trailing: index != 0 
                                    ? IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          setModalState(() {
                                            if (_tabs.length > 1) {
                                              _tabs.removeAt(index);
                                              if (_currentTabIndex >= _tabs.length) {
                                                _currentTabIndex = _tabs.length - 1;
                                              }
                                              _currentUrl = _tabs[_currentTabIndex];
                                            }
                                          });
                                        },
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _currentTabIndex = index;
                                    _currentUrl = _tabs[index];
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('历史记录'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showHistory();
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('下载记录'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showDownloads();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '历史记录',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: const [
                        ListTile(
                          title: Text('https://www.google.com'),
                          subtitle: Text('2025-11-14 19:00'),
                        ),
                        ListTile(
                          title: Text('https://www.github.com'),
                          subtitle: Text('2025-11-14 18:30'),
                        ),
                        ListTile(
                          title: Text('https://www.flutter.dev'),
                          subtitle: Text('2025-11-14 17:45'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDownloads() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '下载记录',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: const [
                        ListTile(
                          title: Text('flutter_sdk.zip'),
                          subtitle: Text('已完成'),
                        ),
                        ListTile(
                          title: Text('image.png'),
                          subtitle: Text('已完成'),
                        ),
                        ListTile(
                          title: Text('document.pdf'),
                          subtitle: Text('下载中...'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('内置浏览器'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tab),
                onPressed: _showTabMenu,
              ),
              if (_tabs.length > 1)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _tabs.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _showMenu,
          ),
        ],
      ),
      body: WebViewWidget(
        initialUrl: _currentUrl,
        onUrlChanged: (url) {
          setState(() {
            _currentUrl = url;
            _tabs[_currentTabIndex] = url;
          });
        },
        enableProxy: true, // 与FlClash的代理功能集成
      ),
    );
  }
}
