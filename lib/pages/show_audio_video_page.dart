import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;

  const VideoPlayerWidget({super.key, required this.videoPath});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  var path;

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath));
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16 / 9,
      autoPlay: true,
      looping: true,
      allowFullScreen: true,
      allowMuting: true,
      allowedScreenSleep: true,
      allowPlaybackSpeedChanging: true,
      showControls: true,
      showOptions: true,
      zoomAndPan: true,
      transformationController: TransformationController(),
      // Add more customization options as needed
    );
  }

  @override
  Widget build(BuildContext context) {
    path = widget.videoPath.split('/');
    path = path[path.length - 1];
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(path),
      ),
      body: Center(
        child: widget.videoPath[widget.videoPath.length - 1] == '3'
            ? Stack(
                children: [
                  Positioned(
                    bottom: height * .8,
                    left: width * .15,
                    child: Container(
                      width: width * .7,
                      height: height * .5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50)),
                      child: Image.asset('assets/images/music.png'),
                    ),
                  ),
                  Chewie(
                    controller: _chewieController,
                  ),
                ],
              )
            : Chewie(
                controller: _chewieController,
              ),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
