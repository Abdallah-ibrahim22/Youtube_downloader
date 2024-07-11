import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:downloading_app/widgets/custom_downloading_button.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeDownloader extends StatefulWidget {
  const YoutubeDownloader({super.key, required this.url, required this.video});

  final String url;
  final video;

  @override
  State<YoutubeDownloader> createState() => _YoutubeDownloaderState();
}

class _YoutubeDownloaderState extends State<YoutubeDownloader> {
  @override
  void initState() {
    super.initState();
    link = widget.url;
    getAudioData(link);
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  bool loading = false;
  double progress = 0;
  double fileSize = 0.0;
  Dio dio = Dio();
  TextEditingController textEditingController = TextEditingController();
  TextEditingController titleEditingController = TextEditingController();
  String link = '';
  bool sheetLoading = false;
  // ignore: unused_field
  var _video;
  var videoData = [];
  String audioData = '';
  bool writing = false;

  getData(String url) async {
    var yt = YoutubeExplode();
    var manifest = await yt.videos.streamsClient.getManifest(url);

    var videoStreams = manifest.muxed.sortByVideoQuality();
    setState(() {
      videoData = videoStreams;
    });
  }

  getAudioData(String url) async {
    var yt = YoutubeExplode();
    var manifest = await yt.videos.streamsClient.getManifest(url);

    var audioStreams = manifest.audioOnly.withHighestBitrate();
    setState(() {
      audioData = audioStreams.size.toString();
    });
  }

  downloadFromYoutube(String url, String path, String type, var size) async {
    var yt = YoutubeExplode();
    var manifest = await yt.videos.streamsClient.getManifest(url);

    var streamInfo = type == '.mp3'
        ? manifest.audioOnly.withHighestBitrate()
        : manifest.muxed.where((e) => e.size == size).last;

    setState(() {
      fileSize = streamInfo.size.totalMegaBytes;
    });

    var stream = yt.videos.streamsClient.get(streamInfo);
    var file = File(path + type);
    log(file.path);
    await file.create();
    var fileStream = file.openWrite();

// to apply stop action while downloading
      await for (var data in stream) {
        if (writing == false) {
          break;
        }
        fileStream.add(data);
        setState(() {
          progress = file.lengthSync() / (1024 * 1024);
        });
      }

    await fileStream.flush();
    await fileStream.close();
    // deleting the file
    if (writing == false && file.lengthSync() < 1222) {
      file.deleteSync();
    }
    yt.close();
    setState(() {
      writing = false;
      progress = 0;
      fileSize = 0;
    });
  }

  Future<bool> saveFile(
      {required String url,
      required String fileName,
      required String type,
      required var qualityLable}) async {
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
      log(directory.path);
    } else {
      return false;
    }
    // here we check if the directory we made exists or not
    // so on the first time it doesn't exist so we make a recursive creation for the directory
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    } else {
      File saveFile = File('${directory.path}/$fileName');

      link.isEmpty
          ? false
          : await downloadFromYoutube(url, saveFile.path, type, qualityLable);
    }

    return true;
  }

  void downloadingAudio() async {
    setState(() {
      loading = true;
      writing = true;
    });

    String validing = link.split('/')[0];

    if (link.isNotEmpty && validing == 'https:') {
      var yt = YoutubeExplode();
      var video = await yt.videos.get(link); // Returns a Video instance.
      var title = video.title; // "Scamazon Prime"
      var newTilte = '';
      int length = title.length;
      for (int i = 0; i < length; i++) {
        if (title[i] == '/' ||
            title[i] == '|' ||
            title[i] == ':' ||
            title[i] == '?' ||
            title[i] == '"') {
        } else {
          newTilte += title[i];
        }
      }

      await saveFile(
          fileName: newTilte, url: link, type: '.mp3', qualityLable: '');
    }

    setState(() {
      textEditingController.clear();
      loading = false;
    });
  }

  downloadingVideo({required var qualityLable}) async {
    setState(() {
      loading = true;
      writing = true;
    });

    String validing = link.split('/')[0];

    if (link.isNotEmpty && validing == 'https:') {
      var yt = YoutubeExplode();
      var video = await yt.videos.get(link); // Returns a Video instance.
      var title = video.title; // "Scamazon Prime"
      var newTilte = '';
      int length = title.length;
      for (int i = 0; i < length; i++) {
        if (title[i] == '/' ||
            title[i] == '|' ||
            title[i] == ':' ||
            title[i] == '?' ||
            title[i] == '"') {
        } else {
          newTilte += title[i];
        }
      }

      await saveFile(
          fileName: newTilte,
          url: link,
          type: '.mp4',
          qualityLable: qualityLable);
    }

    setState(() {
      textEditingController.clear();
      loading = false;
    });
  }

  fetchVideoThumbnail(String videoUrl) async {
    String validing = link.split('/')[0];

    if (link.isNotEmpty && validing == 'https:') {
      YoutubeExplode yt = YoutubeExplode();
      var video = await yt.videos.get(videoUrl);
      yt.close();
      setState(() {
        _video = video;
      });
    } else {
      setState(() {
        _video = null;
      });
    }
  }

  void showBottomSheet(BuildContext context, var data) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        double height = MediaQuery.of(context).size.height;
        return Container(
            height: height * .15,
            color: Colors.white,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: data.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop(); // Dismiss the bottom sheet
                    await downloadingVideo(qualityLable: data[index].size);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.ondemand_video_rounded,
                          size: 20,
                          color: Colors.blue,
                        ),
                        Text(
                            ' ${data[index].qualityLabel} : ${data[index].size.toString()}'),
                        const Spacer(flex: 1),
                        const Icon(
                          Icons.download,
                          size: 20,
                          color: Colors.blue,
                        )
                      ],
                    ),
                  ),
                );
              },
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: !loading,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[300],
          title: Text(
            'Download ${widget.video.title.toString()}',
            maxLines: 1,
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: sheetLoading,
          opacity: .1,
          color: Colors.blue,
          child: Center(
            child: loading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            Container(
                              color: Colors.grey[300],
                              child: Image.network(
                                widget.video.thumbnails.highResUrl,
                                width: width,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                              right: -58,
                              child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(20)),
                                  child:
                                      Text(widget.video.duration.toString())),
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Downloading ...',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: width * .7,
                              height: 20,
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.grey,
                                color: Colors.blue,
                                value: fileSize == 0 ? 0 : progress / fileSize,
                                minHeight: fileSize == 0 ? 100 : fileSize,
                              ),
                            )),
                        const SizedBox(height: 20),
                        Text(
                            '${progress.toStringAsFixed(2)} MB / ${fileSize.toStringAsFixed(2)} MB'),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: ElevatedButton.icon(
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all<double>(10),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                            ),
                            label: const Text(
                              'Stop',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w400),
                            ),
                            icon: const Icon(
                              Icons.stop,
                              color: Colors.red,
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() {
                                writing = false;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            color: Colors.grey[300],
                            child: Image.network(
                              widget.video.thumbnails.highResUrl,
                              width: width,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            bottom: 15,
                            right: -58,
                            child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(widget.video.duration.toString())),
                          )
                        ],
                      ),
                      SizedBox(height: height * .1),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        label: const Text(
                          'Show video qualities',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        icon: const Icon(Icons.ondemand_video_outlined),
                        onPressed: () async {
                          setState(() {
                            sheetLoading = true;
                          });
                          await getData(link);
                          // ignore: use_build_context_synchronously
                          showBottomSheet(context, videoData);
                          setState(() {
                            sheetLoading = false;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      audioData.isEmpty
                          ? const CircularProgressIndicator()
                          : CustomDownloadingButton(
                              quality: audioData,
                              fn: downloadingAudio,
                              type: Icons.music_video_sharp,
                            ),
                      const SizedBox(height: 15),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// this fn to check the permission to access the storage for the device
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
