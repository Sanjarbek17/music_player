import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../widgets/carousel_slider.dart';

class PlayingPage extends StatefulWidget {
  final List<Audio>? audios;
  final int? index;

  const PlayingPage({
    super.key,
    this.audios,
    this.index,
  });

  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage> {
  final assetsAudioPlayer = AssetsAudioPlayer();
  final CarouselController carouselController = CarouselController();

  int second = 0;
  double range = 0;
  double wholeRange = 0;
  bool isPlaying = false;
  String time = '--:--';
  String lastTime = '--:--';

  @override
  void initState() {
    assetsAudioPlayer.open(
      Playlist(audios: widget.audios, startIndex: widget.index ?? 0),
    );

    assetsAudioPlayer.currentPosition.listen(
      (event) {
        if (event.inSeconds == second) return;
        setState(() {
          range = event.inSeconds.toDouble();
          time = ('${event.inMinutes.toString().padLeft(2, '0')}:${(event.inSeconds % 60).toString().padLeft(2, '0')}');
        });
        second = event.inSeconds;
      },
      onDone: () {
        setState(() {
          range = 0;
          time = '--:--';
        });
      },
    );
    assetsAudioPlayer.playlistFinished.listen((event) {
      if (event) {
        setState(() {
          range = 0;
          isPlaying = false;
          time = '00:00';
        });
      }
    });
    assetsAudioPlayer.current.listen((event) {
      isPlaying = true;
      lastTime = ('${assetsAudioPlayer.current.value?.audio.duration.inMinutes.toString().padLeft(2, '0')}:${(assetsAudioPlayer.current.value!.audio.duration.inSeconds % 60).toString().padLeft(2, '0')}');
      wholeRange = assetsAudioPlayer.current.value!.audio.duration.inSeconds.toDouble();
    });
    super.initState();
  }

  @override
  void dispose() {
    assetsAudioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Playing', style: TextStyle(color: Color(0xFF091227), fontSize: 20, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          CarouselCustom(carouselController: carouselController, assetsAudioPlayer: assetsAudioPlayer, audios: widget.audios),
          const Padding(
            padding: EdgeInsets.only(top: 35, right: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.favorite_outline),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.volume_mute_sharp),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.repeat),
                    SizedBox(width: 20),
                    Icon(Icons.shuffle),
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(time), Text(lastTime)],
            ),
          ),
          Slider(
            value: range,
            max: wholeRange,
            activeColor: Colors.black,
            inactiveColor: Colors.grey,
            thumbColor: Colors.black,
            overlayColor: const MaterialStatePropertyAll(Colors.transparent),
            onChanged: sliderValue,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(onTap: previousPage, child: const Icon(Icons.skip_previous_outlined, size: 60)),
              InkWell(onTap: playOrPause, child: isPlaying ? const Icon(Icons.pause_outlined, size: 60) : const Icon(Icons.play_arrow_outlined, size: 60)),
              InkWell(onTap: nextPage, child: const Icon(Icons.skip_next_outlined, size: 60)),
            ],
          )
        ],
      ),
    );
  }

  sliderValue(value) {
    setState(() => range = value);
    assetsAudioPlayer.seek(Duration(seconds: value.toInt()));
  }

  previousPage() {
    assetsAudioPlayer.previous();
    carouselController.previousPage();
  }

  playOrPause() {
    assetsAudioPlayer.playOrPause();
    setState(() => isPlaying = !isPlaying);
  }

  nextPage() {
    assetsAudioPlayer.next();
    carouselController.nextPage();
  }
}