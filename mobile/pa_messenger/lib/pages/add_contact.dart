import 'package:flutter/material.dart';
import 'package:pa_messenger/widgets/app_round_image.dart';

class AddContact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Text('Select contact'),
        actions: [
          IconButton(icon: Icon(Icons.search), onPressed: () {},)
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return _ContactListItem();
        },
        itemCount: 22,
      ),
    );
  }
}

class _ContactListItem extends StatelessWidget {
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
                  padding: EdgeInsets.only(left: 14.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _title(context, 'Aleksandra Stankovic'),
                        Container(height: 4),
                        _latestMessageText(context, 'Hey there I use this app!')
                      ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _image() => AppRoundImage(
        'https://thispersondoesnotexist.com/image',
        width: 35,
        height: 35,
      );

  _title(BuildContext context, String text) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .subtitle1
            .apply(fontSizeDelta: -3, fontWeightDelta: 3));
  }

  _latestMessageText(BuildContext context, String text) {
    return Text(text, style: Theme.of(context).textTheme.caption.apply(fontSizeDelta: -2));
  }
}
