import 'package:flutter/material.dart';

import 'bloc/podcast.dart';
import 'model/podcast.dart';
import 'theme.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _ectrl;
  final _formKey = GlobalKey<FormState>();
  Widget _tfSuffix;

  @override
  void initState() {
    super.initState();
    _ectrl = TextEditingController();
    _tfSuffix = IconButton(
      icon: Icon(Icons.done_outline),
      onPressed: () => _submitUrl(context, _ectrl.text),
    );
  }

  @override
  void dispose() {
    _ectrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Container(
            child: Column(children: [
              Padding(padding: EdgeInsets.only(top: 40.0)),
              Text(
                'Subscribe Podcast',
                style: TextStyle(color: accentColor, fontSize: 25.0),
              ),
              Padding(padding: EdgeInsets.only(top: 50.0)),
              TextFormField(
                controller: _ectrl,
                decoration: InputDecoration(
                  suffixIcon: _tfSuffix,
                  labelText: "Enter RSS feed URL",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (val) {
                  if (val.length == 0) {
                    return "URL cannot be empty";
                  } else {
                    return null;
                  }
                },
                onFieldSubmitted: (String url) =>
                    _submitUrl(context, _ectrl.text),
                keyboardType: TextInputType.url,
                style: TextStyle(
                  fontFamily: "Poppins",
                ),
              ),
            ]),
          )),
    );
  }

  void _submitUrl(BuildContext context, String url) async {
    setState(() {
      _tfSuffix = Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircularProgressIndicator(),
      );
    });

    await () async {
      if (!_formKey.currentState.validate()) {
        return;
      }
      FocusScope.of(context).requestFocus(FocusNode());
      Podcast podcast;
      try {
        podcast = await Podcast.newPodcastByUrl(url);
        await podcastBloc.add(podcast);
      } on PodcastAlreadyExistException catch (e) {
        Scaffold.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.yellow[700],
            content: Text(
              "${e.toString()}",
              textAlign: TextAlign.center,
            )));
        return;
      } catch (e) {
        Scaffold.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "${e.toString()}",
              textAlign: TextAlign.center,
            )));
        return;
      }
      Scaffold.of(context).showSnackBar(SnackBar(
          backgroundColor: accentColor,
          content: Text("OK!", textAlign: TextAlign.center)));
    }();

    _ectrl.clear();

    setState(() {
      print("4");
      _tfSuffix = IconButton(
        icon: Icon(Icons.done_outline),
        onPressed: () => _submitUrl(context, _ectrl.text),
      );
    });
  }
}
