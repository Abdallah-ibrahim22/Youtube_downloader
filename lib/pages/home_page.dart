import 'package:downloading_app/pages/Youtube_view_page.dart';
import 'package:downloading_app/pages/downloading_page.dart';
import 'package:downloading_app/pages/show_folder_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  List<Widget> views = const [
    DownloadingPage(),
    YouTubeVideoSearch(),
    FolderViewer(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[300],
      body: PageStorage(
        bucket: PageStorageBucket(), 
        child: IndexedStack(
          index: selectedIndex,
          children: views,
        )),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[800],
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.download), label: 'Download'),
          BottomNavigationBarItem(
              icon: Icon(Icons.ondemand_video_sharp), label: 'Youtube'),
          BottomNavigationBarItem(
              icon: Icon(Icons.folder), label: 'Saved items'),
        ],
        selectedItemColor: Colors.white,
        currentIndex: selectedIndex,
        onTap: (value) => setState(() {
          selectedIndex = value;
        }),
      ),
    );
  }
}
