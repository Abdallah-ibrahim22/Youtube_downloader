import 'dart:io';

import 'package:downloading_app/pages/show_audio_video_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FolderViewer extends StatefulWidget {
  const FolderViewer({super.key});

  @override
  State<FolderViewer> createState() => _FolderViewerState();
}

class _FolderViewerState extends State<FolderViewer> {
  List _folderContent = [];
  List titles = [];
  String directoryPath = '';
  bool refreshing = false;
  final TextEditingController _textController = TextEditingController();

  openFolder() async {
    // creating a directory obj to deal with directories exists
    Directory? directory;
    if (await requestPermission(Permission.storage) &&
        // access media location needed for android 10/Q
        await requestPermission(Permission.accessMediaLocation) &&
        // manage external storage needed for android 11/R
        await requestPermission(Permission.manageExternalStorage)) {
      // here we get the path for the storage in case we had the access to it
      directory = await getExternalStorageDirectory();
      String newPath = '';
      List<String> folders = directory!.path.split('/');

      // this for loop helps us to create new path in the same hierarchy of Andrid folder
      for (int i = 1; i < folders.length; i++) {
        if (folders[i] != 'Android') {
          newPath += '/${folders[i]}';
        } else {
          break;
        }
      }
      // new path to save the files into it
      newPath += '/Media_downloader';
      directory = Directory(newPath);
    } else {
      return false;
    }
    // here we check if the directory we made exists or not
    // so on the first time it doesn't exist so we make a recursive creation for the directory
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      setState(() {
        directoryPath = directory!.path;
      });
      _loadFolderContent(directoryPath);
    } else {
      setState(() {
        directoryPath = directory!.path;
      });
      _loadFolderContent(directoryPath);
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    openFolder();
  }

  _showConfirmationDialog(BuildContext context, String filePath, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to delete : (${titles[index]}) ?',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 18,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteFile(context, filePath: filePath, index: index);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFile(BuildContext context,
      {required String filePath, required int index}) {
    try {
      File file = File(filePath);
      if (file.existsSync()) {
        file.deleteSync();
        _folderContent.removeAt(index);
        titles.removeAt(index);
        setState(() {});
        Navigator.of(context).pop(); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File deleted successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File does not exist'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting file: $e'),
        ),
      );
    }
  }

  void _loadFolderContent(String folderPath) {
    titles.clear();
    Directory folder = Directory(folderPath);
    List<FileSystemEntity> contents = folder.listSync();
    if (_textController.text.isEmpty) {
      for (var i in contents) {
        var title = i.path.split('/');

        titles.add(title[title.length - 1]);
      }

      setState(() {
        _folderContent = contents;
      });
    } else {
      List<FileSystemEntity> filtered_list = [];

      for (var i in contents) {
        var title = i.path.split('/');
        String selected = title[title.length - 1];
        if (selected
            .toLowerCase()
            .contains(_textController.text.toLowerCase())) {
          filtered_list.add(i);
          titles.add(title[title.length - 1]);
        }
      }
      setState(() {
        _folderContent = filtered_list;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.replay, color: Colors.white, size: 30),
            onPressed: () async {
              refreshing = true;
              setState(() {});
              await openFolder();
              refreshing = false;
              setState(() {});
            },
          ),
        ],
        title: const Text(
          'Downloaded Media',
          style: TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w500),
        ),
      ),
      body: refreshing
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                        label: Text('Medi Search'),
                        suffixIcon: Icon(
                          size: 24,
                          Icons.search_rounded,
                          color: Colors.blue,
                        )),
                    onChanged: (value) {
                      if (directoryPath.isNotEmpty) {
                        _loadFolderContent(directoryPath);
                      }
                      setState(() {});
                      // _searchVideos(query);
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: ListView.builder(
                    itemCount: _folderContent.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onLongPress: () async {
                          await _showConfirmationDialog(
                              context, _folderContent[index].path, index);
                        },
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => VideoPlayerWidget(
                                videoPath: _folderContent[index].path),
                          ));
                        },
                        child: ListTile(
                          leading: titles[index]
                                      .toString()[titles[index].length - 1] ==
                                  '3'
                              ? const Icon(
                                  Icons.audio_file_outlined,
                                  color: Colors.blue,
                                  size: 30,
                                )
                              : const Icon(
                                  Icons.ondemand_video_outlined,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                          title: Text(
                            maxLines: 2,
                            titles[index].toString(),
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

Future<bool> requestPermission(Permission permission) async {
  if (await permission.isGranted) {
    return true;
  } else {
    // here we ask to access the storage
    var result = await permission.request();
    if (result.isGranted) {
      return true;
    } else {
      return false;
    }
  }
}
