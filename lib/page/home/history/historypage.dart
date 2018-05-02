import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:beer_me_up/common/widget/beertile.dart';
import 'package:beer_me_up/common/widget/loadingwidget.dart';
import 'package:beer_me_up/common/widget/erroroccurredwidget.dart';
import 'package:beer_me_up/model/checkin.dart';
import 'package:beer_me_up/service/userdataservice.dart';
import 'package:beer_me_up/common/mvi/viewstate.dart';
import 'package:beer_me_up/common/widget/materialraisedbutton.dart';

import 'model.dart';
import 'intent.dart';
import 'state.dart';

class HistoryPage extends StatefulWidget {
  final HistoryIntent intent;
  final HistoryViewModel model;

  HistoryPage._({
    Key key,
    @required this.intent,
    @required this.model,
  }) : super(key: key);

  factory HistoryPage({Key key,
    HistoryIntent intent,
    HistoryViewModel model,
    UserDataService dataService}) {

    final _intent = intent ?? new HistoryIntent();
    final _model = model ?? new HistoryViewModel(
      dataService ?? UserDataService.instance,
      _intent.retry,
      _intent.loadMore,
    );

    return new HistoryPage._(key: key, intent: _intent, model: _model);
  }

  @override
  _HistoryPageState createState() => new _HistoryPageState(intent: intent, model: model);
}

class _HistoryPageState extends ViewState<HistoryPage, HistoryViewModel, HistoryIntent, HistoryState> {
  static final _listSectionDateFormatter = new DateFormat.yMMMMd();
  static final _listRowCheckInDateFormatter = new DateFormat().add_Hm();

  _HistoryPageState({
    @required HistoryIntent intent,
    @required HistoryViewModel model
  }): super(intent, model);

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<HistoryState> snapshot) {
        if( !snapshot.hasData ) {
          return new Container();
        }

        return snapshot.data.join(
          (loading) => _buildLoadingWidget(),
          (load) => _buildLoadWidget(items: load.items),
          (error) => _buildErrorWidget(error: error.error),
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return new Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 25.0),
      child: new LoadingWidget(),
    );
  }

  Widget _buildErrorWidget({@required String error}) {
    return new ErrorOccurredWidget(
      error,
      intent.retry
    );
  }

  Widget _buildLoadWidget({@required List<HistoryListItem> items}) {
    return new ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.only(top: 20.0, bottom: 36.0),
      itemBuilder: (BuildContext context, int index) {
        final item = items[index];

        if( item is HistoryListSection ) {
          return _buildListSectionWidget(item.date, index);
        } else if( item is HistoryListRow ) {
          return _buildListRow(item.checkIn);
        } else if( item is HistoryListLoadMore ) {
          return _buildListLoadMore(context);
        } else if( item is HistoryListLoading ) {
          return _buildListLoadingMore();
        }

        return new Container();
      },
    );
  }

  Widget _buildListSectionWidget(DateTime date, int index) {
    return new Container(
      padding: new EdgeInsets.only(top: index == 0 ? 0.0 : 30.0, left: 16.0, right: 16.0),
      child: new Text(
        _listSectionDateFormatter.format(date),
        style: new TextStyle(
          fontFamily: "Google Sans",
          color: Colors.blueGrey[900],
          fontSize: 18.0,
        ),
      ),
    );
  }

  Widget _buildListRow(CheckIn checkIn) {
    return new BeerTile(
      beer: checkIn.beer,
      title: checkIn.beer.name,
      subtitle: "${_listRowCheckInDateFormatter.format(checkIn.date)} - ${checkIn.quantity.toString()}",
    );
  }

  Widget _buildListLoadMore(BuildContext context) {
    return new Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 25.0),
      child: new Center(
        child: new MaterialRaisedButton.primary(
          context: context,
          text: "Load more",
          onPressed: intent.loadMore,
        ),
      ),
    );
  }

  Widget _buildListLoadingMore() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }
}