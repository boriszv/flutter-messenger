import 'package:flutter/material.dart';
import 'package:pa_messenger/widgets/app_bottom_nav.dart';
import 'package:pa_messenger/widgets/app_round_image.dart';

class ConversationList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Text('Conversations'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return _ConversationListItem();
        },
        itemCount: 22,
      ),
    );
  }
}

class _ConversationListItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _image(),
                Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _title(context, 'Miroljub Petrovic'),
                        Container(height: 2),
                        _latestMessageText(context, 'What you say?')
                      ]),
                ),
              ],
            ),
            _timestamp(context, '6:32PM')
          ],
        ),
      ),
    );
  }

  _image() => AppRoundImage(
        'https://thispersondoesnotexist.com/image',
        width: 60,
        height: 60,
      );

  _title(BuildContext context, String text) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .headline6
            .apply(fontSizeDelta: -2, fontWeightDelta: 2));
  }

  _latestMessageText(BuildContext context, String text) {
    return Text(text, style: Theme.of(context).textTheme.caption);
  }

  _timestamp(BuildContext context, String timestamp) {
    return Padding(
      padding: EdgeInsets.only(top: 15.0, right: 4),
      child: Text(timestamp, style: Theme.of(context).textTheme.caption),
    );
  }
}
