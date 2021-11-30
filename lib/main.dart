import 'dart:typed_data';

import 'package:astra/astra.dart';
import 'package:flutter/material.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astra',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        backgroundColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: MyHomePage(title: 'Astra'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key) {
    initSpotifySdk();
  }

  initSpotifySdk() async {
    await SpotifySdk.connectToSpotifyRemote(
      clientId: "", // TODO in env
      redirectUrl: "http://localhost:57943/spotify.html",
      scope:
          "app-remote-control,user-modify-playback-state,playlist-read-private",
    );
  }

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PlayerState? state;
  Uint8List? image;

  _MyHomePageState() {
    SpotifySdk.subscribePlayerState().listen((state) async {
      var image = await SpotifySdk.getImage(imageUri: state.track!.imageUri);
      setState(() {
        this.state = state;
        this.image = image;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [Astra()],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    image != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Image.memory(image!,
                                width: 60, fit: BoxFit.cover))
                        : Container(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          state != null
                              ? Text(
                                  state!.track!.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    overflow: TextOverflow.fade,
                                    fontFamily: "IBM Plex Mono",
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                )
                              : const Text(
                                  "No song playing",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "IBM Plex Mono",
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                          state != null
                              ? Text(
                                  state!.track!.artist.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: "IBM Plex Mono",
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 32,
                    padding: const EdgeInsets.all(16),
                    onPressed: () {
                      SpotifySdk.skipPrevious();
                    },
                    icon: const Icon(
                      Icons.skip_previous_rounded,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    iconSize: 32,
                    padding: const EdgeInsets.all(16),
                    onPressed: () {
                      state!.isPaused
                          ? SpotifySdk.resume()
                          : SpotifySdk.pause();
                    },
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    iconSize: 32,
                    padding: const EdgeInsets.all(16),
                    onPressed: () {
                      SpotifySdk.skipNext();
                    },
                    icon: const Icon(
                      Icons.skip_next_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
