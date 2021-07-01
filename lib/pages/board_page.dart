import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mobichan/api/api.dart';
import 'package:mobichan/classes/arguments/board_page_arguments.dart';
import 'package:mobichan/classes/arguments/thread_page_arguments.dart';
import 'package:mobichan/classes/models/post.dart';
import 'package:mobichan/enums/enums.dart';
import 'package:mobichan/extensions/string_extension.dart';
import 'package:mobichan/pages/thread_page.dart';
import 'package:mobichan/widgets/drawer_widget.dart';
import 'package:mobichan/widgets/form_widget.dart';
import 'package:mobichan/widgets/post_action_button_widget.dart';
import 'package:mobichan/widgets/thread_widget.dart';

class BoardPage extends StatefulWidget {
  static const routeName = '/board';
  final BoardPageArguments args;
  const BoardPage({Key? key, required this.args}) : super(key: key);

  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  late Future<List<Post>> _futureOPs;
  bool _postFormIsOpened = false;
  bool _isSearching = false;
  String _searchQuery = '';
  late TextEditingController _searchQueryController;

  @override
  void initState() {
    super.initState();
    _searchQueryController = TextEditingController();
    _refresh();
  }

  void _onPressPostActionButton() {
    setState(() {
      _postFormIsOpened = !_postFormIsOpened;
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _futureOPs = Api.fetchOPs(board: widget.args.board);
    });
  }

  void _onCloseForm() {
    setState(() {
      _postFormIsOpened = false;
    });
  }

  void _onFormPost(Response<String> response) async {
    _onCloseForm();
    await _refresh();
  }

  void _startSearching() {
    setState(() {
      ModalRoute.of(context)!
          .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));
      _isSearching = true;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();
    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      _updateSearchQuery('');
    });
  }

  void _updateSearchQuery(String newQuery) {
    print(newQuery);
    setState(() {
      _searchQuery = newQuery;
    });
  }

  bool _matchesSearchQuery(String? field) {
    if (field == null) {
      return false;
    }
    return field.toLowerCase().contains(_searchQuery.toLowerCase());
  }

  Widget Function(BuildContext, int) _listViewItemBuilder(
      AsyncSnapshot<List<Post>> snapshot) {
    return (BuildContext context, int index) {
      Post op = snapshot.data![index];
      return _matchesSearchQuery(op.com) || _matchesSearchQuery(op.sub)
          ? Padding(
              padding: EdgeInsets.only(top: 15, left: 10, right: 10),
              child: ThreadWidget(
                post: op,
                board: widget.args.board,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ThreadPage(
                      args: ThreadPageArguments(
                        board: widget.args.board,
                        thread: op.no,
                        title: op.sub ??
                            op.com?.replaceBrWithSpace.removeHtmlTags
                                .unescapeHtml ??
                            '',
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Container();
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      floatingActionButton: PostActionButton(
        onPressed: _onPressPostActionButton,
      ),
      appBar: AppBar(
        leading: _isSearching ? BackButton() : null,
        actions: [
          IconButton(
            onPressed: _startSearching,
            icon: Icon(Icons.search_rounded),
          ),
          PopupMenuButton(itemBuilder: (context) {
            return <PopupMenuEntry>[];
          })
        ],
        title: _isSearching
            ? TextField(
                controller: _searchQueryController,
                onChanged: _updateSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search...',
                ),
                autofocus: true,
              )
            : Text('/${widget.args.board}/ - ${widget.args.title}'),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refresh,
            child: buildFutureBuilder(),
          ),
          FormWidget(
            postType: PostType.thread,
            board: widget.args.board,
            isOpened: _postFormIsOpened,
            onPost: _onFormPost,
            onClose: _onCloseForm,
          ),
        ],
      ),
    );
  }

  FutureBuilder<List<Post>> buildFutureBuilder() {
    return FutureBuilder<List<Post>>(
      future: _futureOPs,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: _listViewItemBuilder(snapshot),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
