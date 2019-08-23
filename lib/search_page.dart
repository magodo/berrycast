import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'bloc/itunes_bloc.dart';
import 'search_result_page.dart';
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
                'Search Podcast',
                style: TextStyle(color: accentColor, fontSize: 25.0),
              ),
              Padding(padding: EdgeInsets.only(top: 50.0)),
              TextFormField(
                controller: _ectrl,
                decoration: InputDecoration(
                  suffixIcon: _tfSuffix,
                  labelText: "Please enter a search term",
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(),
                  ),
                  //fillColor: Colors.green
                ),
                validator: (val) {
                  if (val.length == 0) {
                    return "Term cannot be empty";
                  } else {
                    return null;
                  }
                },
                onFieldSubmitted: (String term) =>
                    _submitUrl(context, _ectrl.text),
                keyboardType: TextInputType.text,
                style: TextStyle(
                  fontFamily: "Poppins",
                ),
              ),
            ]),
          )),
    );
  }

  void _submitUrl(BuildContext context, String term) async {
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

      try {
        await itunesBloc.searchPodcasts(term);
      } on Exception catch (e) {
        FlushbarHelper.createError(message: e.toString(), duration: Duration(seconds: 3)).show(context);
        return;
      }
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return SearchResultPage();
      }));
    }();

    // clear text field
    // TODO: There is bug in flutter 1.7.8, see [this](https://github.com/flutter/flutter/pull/38722)
//    _ectrl.clear();

    // release focus from text field
    FocusScope.of(context).unfocus();

    setState(() {
      _tfSuffix = IconButton(
        icon: Icon(Icons.done_outline),
        onPressed: () => _submitUrl(context, _ectrl.text),
      );
    });
  }
}
