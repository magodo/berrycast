import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/podcast.dart';
import 'theme.dart';
import 'utils.dart';

class PodcastGalleryPage extends StatelessWidget {
  List<Widget> _buildPodcastThumb(BuildContext context) {
    final podcasts = Provider.of<List<Podcast>>(context);
    if (podcasts == null) return [];

    return List.generate(
      podcasts.length,
      (idx) => RawMaterialButton(
        shape: CircleBorder(),
        splashColor: lightAccentColor,
        highlightColor: lightAccentColor.withOpacity(0.5),
        elevation: 10.0,
        highlightElevation: 5.0,
        onPressed: () {},
        child: GridTile(
          child: InkResponse(
            enableFeedback: true,
            child: podcasts[idx].image,
            onTap: () {
              openPodcastPage(context, podcasts[idx]);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
//    return SafeArea(
//      child: Scaffold(
//        floatingActionButton: FancyFab(
//          onPressed: () {},
//          tooltip: "",
//          icon: Icons.add,
//        ),
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
      padding: const EdgeInsets.all(4.0),
      childAspectRatio: 1.0,
      children: _buildPodcastThumb(context),
    );
  }
}
