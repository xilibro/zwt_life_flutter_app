import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provide/provide.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:zwt_life_flutter_app/common/manager/settingmanager.dart';
import 'package:zwt_life_flutter_app/common/net/Code.dart';
import 'package:zwt_life_flutter_app/common/widgets/bookshelfwidget/ReaderMenu.dart';
import 'package:zwt_life_flutter_app/page/MainPage.dart';
import 'package:zwt_life_flutter_app/public.dart';
import 'package:package_info/package_info.dart';

List<RecommendBooks> recommendBooksList = new List();

class BookShelfPage extends StatefulWidget {
  static final String sName = "BookShelf";

  @override
  _BookShelfPageState createState() {
    // TODO: implement createState
    return _BookShelfPageState();
  }
}

class _BookShelfPageState extends State<BookShelfPage>
    with AutomaticKeepAliveClientMixin {
  RefreshController _refreshController;
  ScrollController _scrollController;
  final SlidableController slidableController = new SlidableController();
  BookShelfDbProvider bookShelfDbProvider = new BookShelfDbProvider();

//  @override
//  void didChangeAppLifecycleState(AppLifecycleState state) {}

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _refreshController = new RefreshController();
    _scrollController = new ScrollController();
    checkNewUser(context);
    checkUpdate();
  }

  void scrollTop() {
    _scrollController.animateTo(0.0,
        duration: new Duration(microseconds: 1000), curve: ElasticInCurve());
  }

  void enterRefresh() {
    _refreshController.requestRefresh(true);
  }

  returnUserItem(RecommendBooks item, int index) {
    return new GestureDetector(
      child: new Slidable(
        controller: slidableController,
        delegate: new SlidableDrawerDelegate(),
        actionExtentRatio: 0.13,
        child: Material(
          child: Ink(
            child: InkWell(
              onTap: () {
                tap(item);
              },
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          child: Stack(
                            children: <Widget>[
                              ExtendedImage.network(
                                (Constant.IMG_BASE_URL + '${item.cover}'),
                                height: ScreenUtil.getInstance().L(50),
                                fit: BoxFit.fitHeight,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                cache: true,
                              ),
                              Provide<DownloadStatusEvent>(builder:
                                  (context, child, downloadStatusEvent) {
                                DownloadEvent downloadEvent;
                                if (downloadEventList.length == 0) {
                                  return Text('');
                                }
                                for (int i = 0;
                                    i < downloadEventList.length;
                                    i++) {
                                  if (item.id == downloadEventList[i].bookId) {
                                    downloadEvent = downloadEventList[i];
                                    i = downloadEventList.length;
                                  }
                                }
                                if (item.id == downloadEvent?.bookId) {
                                  if (downloadEvent.type ==
                                          DownloadEventType.loading ||
                                      downloadEvent.type ==
                                          DownloadEventType.pause) {
                                    int total =
                                        downloadEvent.end - downloadEvent.start;
                                    int current = downloadEvent.current -
                                        downloadEvent.start;
                                    double progress = current / total;
                                    return Material(
                                      type: MaterialType.transparency,
                                      child: Opacity(
                                        opacity: 0.6,
                                        child: Container(
                                          height: ScreenUtil.getInstance().L(50),
                                          color: Colors.black,
                                          alignment: Alignment.center,
                                          child: Stack(
                                            children: <Widget>[
                                              Container(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                      '${(progress * 100.0).toStringAsFixed(1)}%',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ))),
                                              Container(
                                                alignment: Alignment.center,
                                                child:
                                                    CircularProgressIndicator(
                                                  value: progress,
                                                  backgroundColor: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Text('');
                                  }
                                } else {
                                  return Text('');
                                }
                              }),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    new Text('${item.title}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: ScreenUtil.getInstance()
                                                .setSp(16))),
                                    Container(
                                      width: 5,
                                    ),
                                    Offstage(
                                      offstage: item.noUpdate == null
                                          ? true
                                          : item.noUpdate,
                                      child: new Container(
                                        color: Colors.red,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 0),
                                        child: Text(
                                          "更新",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  height: ScreenUtil.getInstance().setSp(5),
                                ),
                                Text(
                                  '${item.lastChapter}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize:
                                          ScreenUtil.getInstance().setSp(11)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
//              trailing: new Text('${item.updated}'),
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 20,
                  )
                ],
              ),
            ),
          ),
        ),
        secondaryActions: <Widget>[
//          new IconSlideAction(
//              foregroundColor: Colors.grey,
//              color: Colors.grey[50],
//              caption: '养肥',
//              icon: Icons.collections_bookmark,
//              onTap: () {}),
          new IconSlideAction(
              foregroundColor: Colors.grey,
              color: Colors.grey[50],
              caption: '置顶',
              icon: Icons.vertical_align_top,
              onTap: () {
                toTop(item, index);
              }),
          Provide<DownloadStatusEvent>(
              builder: (context, child, downloadStatusEvent) {
            DownloadEvent downloadEvent;
            if (downloadEventList.length == 0) {
              return new IconSlideAction(
                  foregroundColor: Colors.grey,
                  color: Colors.grey[50],
                  caption: '缓存',
                  icon: Icons.file_download,
                  onTap: () {
                    download(item, DownloadEventType.start);
                  });
            } else {
              for (int i = 0; i < downloadEventList.length; i++) {
                if (item.id == downloadEventList[i].bookId) {
                  downloadEvent = downloadEventList[i];
                  i = downloadEventList.length;
                }
              }
              if (downloadEvent?.bookId == item.id) {
                if (downloadEvent.type == DownloadEventType.loading) {
                  return new IconSlideAction(
                      foregroundColor: Colors.grey,
                      color: Colors.grey[50],
                      caption: '取消缓存',
                      icon: Icons.cancel,
                      onTap: () {
                        download(item, DownloadEventType.remove);
                      });
                } else if (downloadEvent.type == DownloadEventType.finish) {
                  return new IconSlideAction(
                      foregroundColor: Colors.grey,
                      color: Colors.grey[50],
                      caption: '清除缓存',
                      icon: Icons.hourglass_empty,
                      onTap: () {
                        download(item, DownloadEventType.remove);
                      });
                } else {
                  return new IconSlideAction(
                      foregroundColor: Colors.grey,
                      color: Colors.grey[50],
                      caption: '缓存',
                      icon: Icons.file_download,
                      onTap: () {
                        download(item, DownloadEventType.start);
                      });
                }
              } else {
                return new IconSlideAction(
                    foregroundColor: Colors.grey,
                    color: Colors.grey[50],
                    caption: '缓存',
                    icon: Icons.file_download,
                    onTap: () {
                      download(item, DownloadEventType.start);
                    });
              }
            }
          }),

          new IconSlideAction(
              caption: '删除',
              foregroundColor: Colors.red,
              color: Colors.grey[50],
              icon: Icons.delete_outline,
              onTap: () {
                delete(item, index);
              }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: GlobalColors.appbarColor,
        leading: PopupMenuButton<String>(
          icon: Icon(
            Icons.menu,
            color: Colors.black,
          ),
          padding: EdgeInsets.zero,
          onSelected: showMenuSelection,
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'cache',
                  child: ListTile(
                    leading: Icon(
                      Icons.file_download,
                      color: Colors.black,
                    ),
                    title: Text('缓存管理'),
                  ),
                ),
//                const PopupMenuDivider(),
              ],
        ),
        middle: Text('书架'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Semantics(
            child: IconButton(
                onPressed: () {
                  NavigatorUtils.goSearchPage(context);
                },
                icon: Icon(CupertinoIcons.search, color: Colors.black)),
          ),
        ),
      ),
      child: DefaultTextStyle(
        style: CupertinoTheme.of(context).textTheme.textStyle,
        child: Center(
          child: CupertinoScrollbar(
              child: SmartRefresher(
                  controller: _refreshController,
                  headerBuilder: CommonUtils.headerCtreate,
                  enablePullDown: true,
                  enablePullUp: false,
                  onRefresh: (up) {
                    if (up) {
                      //上拉刷新重新刷新数据
                      checkNewUser(context);
                      new Future.delayed(const Duration(milliseconds: 2009))
                          .then((val) {
                        setState(() {
                          _refreshController.sendBack(
                              true, RefreshStatus.completed);
                        });
                      });
                    } else {
                      new Future.delayed(const Duration(milliseconds: 2009))
                          .then((val) {
                        setState(() {
                          _refreshController.sendBack(
                              false, RefreshStatus.idle);
                        });
                      });
                    }
                  },
                  child: new ListView.builder(
                      reverse: true,
                      controller: _scrollController,
                      itemCount: recommendBooksList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return returnUserItem(recommendBooksList[index], index);
                      }))),
        ),
      ),
    );
  }

  //菜单栏
  void showMenuSelection(String value) {
    if (value == 'cache') {
      NavigatorUtils.gotoBookCachePage(context);
    }
  }

  void checkNewUser(BuildContext context) async {
    //第一次登录 选择性别
    if (!SettingManager.getInstance().isUserChooseSex()) {
      Future.delayed(Duration(seconds: 1), () {
        CommonUtils.showLickeDialog(context, () {
          setSex(Constant.MALE);
        }, () {
          setSex(Constant.FEMALE);
        });
      });
    } else {
      //否则 从数据库中读取书架
      var data = await bookShelfDbProvider.getAllData();
      if (data != null) {
        recommendBooksList.clear();
        recommendBooksList.addAll(data);
        setState(() {});
        RecommendBooks recommendBooks;
        if (recommendBooksList?.length != null) {
          for (int i = 0; i < recommendBooksList.length; i++) {
            recommendBooks = recommendBooksList[i];
            Data data = await dioGetAToc(recommendBooks.id, "chapters");
            if (data.result && data.data.toString().length > 0) {
              MixToc mixToc = data.data;
              List<Chapters> chaptersList = mixToc.chapters;
              //章节是否更新
              if (!recommendBooks.lastChapter
                  .trim()
                  .contains(chaptersList.last.title.trim())) {
                //用户要点击阅读以后 更新才会清除 不然一直存在
                print("章节已更新");
                setState(() {
                  recommendBooksList[i].lastChapter = chaptersList.last.title;
                  recommendBooksList[i].noUpdate = false;
                });
                //是
                //数据库插入
                recommendBooks.noUpdate = false;
                recommendBooks.lastChapter = chaptersList.last.title;
                bookShelfDbProvider.insert(recommendBooks.id, DateTime.now(),
                    json.encode(recommendBooks.toJson()));
              }
            }
          }
        } else {
          //选择性别
          Future.delayed(Duration(seconds: 1), () {
            CommonUtils.showLickeDialog(context, () {
              setSex(Constant.MALE);
            }, () {
              setSex(Constant.FEMALE);
            });
          });
        }
      }
    }
  }

  toTop(RecommendBooks item, int index) {
    setState(() {
      recommendBooksList.removeAt(index);
      recommendBooksList.insert(0, item);
    });
    bookShelfDbProvider.insert(
        item.id, DateTime.now(), json.encode(item.toJson()));
  }

  delete(RecommendBooks item, int index) async {
    setState(() {
      recommendBooksList.removeAt(index);
    });
    bookShelfDbProvider.delete(item.id);
  }

  setSex(String sex) async {
    Navigator.pop(context);
    SettingManager.getInstance().saveUserChooseSex(sex);
    Data data = await dioGetRecommend(sex);
    if (data.result && data.data.toString().length > 0) {
      setState(() {
        recommendBooksList = data.data;
      });

      for (RecommendBooks recommendBooks in data.data) {
        //将书架目录加入数据库
        await bookShelfDbProvider.insert(recommendBooks.id, DateTime.now(),
            json.encode(recommendBooks.toJson()));
      }
    }
  }

  //点击阅读
  void tap(RecommendBooks item) async {
    NavigatorUtils.gotoReadBookPage(context, item.title, item.id);
    //更新阅读时间
    item.noUpdate = true;
    await bookShelfDbProvider.insert(
        item.id, DateTime.now(), json.encode(item.toJson()));
    var data = await bookShelfDbProvider.getAllData();
    setState(() {
      recommendBooksList = data;
    });
  }

  void download(RecommendBooks item, String type) async {
    print('点击缓存');
    Data data = await dioGetAToc(item.id, "chapters");
    MixToc mixToc = data.data;
    List<Chapters> chaptersList = mixToc.chapters;
    if (type == DownloadEventType.start) {
      showDownloadSheet(
          context: context,
          bookId: item.id,
          chaptersList: chaptersList,
          callback: () async {},
          currentIndex: 0);
    } else {
      Code.eventBus.fire(
          new DownloadEvent(item.id, chaptersList, 1, 1, type, current: 1));
    }
  }

  void checkUpdate() async {
    bool isupdate = false;
    bool ismustUpdate = false;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    bool isSupport = await FlutterAppBadger.isAppBadgeSupported();
    if (isSupport) {
      FlutterAppBadger.updateBadgeCount(1);
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
