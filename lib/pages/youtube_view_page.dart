import 'package:downloading_app/pages/youtube_downloader_page.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeVideoSearch extends StatefulWidget {
  const YouTubeVideoSearch({super.key});

  @override
  State<YouTubeVideoSearch> createState() => _YouTubeVideoSearchState();
}

class _YouTubeVideoSearchState extends State<YouTubeVideoSearch> {
  final TextEditingController _textController = TextEditingController();
  final YoutubeExplode _ytExplode = YoutubeExplode();
  bool loading = false;

  List _searchResults = [];

  Future<void> _searchVideos(String query) async {
    var searchList = await _ytExplode.search.call(query);
    setState(() {
      _searchResults = searchList;
      setState(() {
        loading = false;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _ytExplode.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        title: const Text(
          'Youtube search video',
          style: TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w500),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                  label: Text('Video Search'),
                  suffixIcon: Icon(
                    size: 24,
                    Icons.search_rounded,
                    color: Colors.blue,
                  )),
              onSubmitted: (value) {
                setState(() {
                  loading = true;
                });
                String query = _textController.text.trim();
                _searchVideos(query);
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  loading = true;
                });
                String query = _textController.text.trim();
                _searchVideos(query);
              },
              child: const Text('Search Videos'),
            ),
            const SizedBox(height: 16.0),
            loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: ListView.builder(
                      // padding: EdgeInsets.symmetric(vertical: 20),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        var video = _searchResults[index];
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => YoutubeDownloader(
                                      url: video.url.toString(), video: video),
                                ));
                              },
                              child: Stack(
                                clipBehavior: Clip.antiAlias,
                                children: [
                                  Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    width: width,
                                    child: Image.network(
                                      video.thumbnails.highResUrl,
                                      height: height * .23,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 15,
                                    right: -56,
                                    child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Text(video.duration.toString())),
                                  )
                                ],
                              ),
                            ),
                            ListTile(
                              title: Text(
                                video.title,
                                maxLines: 2,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 18),
                              ),
                              subtitle: Text(video.description, maxLines: 2),
                            ),
                            const SizedBox(
                              height: 15,
                            )
                          ],
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
