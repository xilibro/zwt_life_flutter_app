import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:redux/redux.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_statusbar/flutter_statusbar.dart';
import 'package:zwt_life_flutter_app/common/localization/DefaultLocalizations.dart';
import 'package:zwt_life_flutter_app/common/net/Address.dart';
import 'package:zwt_life_flutter_app/common/redux/GlobalState.dart';
import 'package:zwt_life_flutter_app/common/redux/LocaleRedux.dart';
import 'package:zwt_life_flutter_app/common/redux/ThemeRedux.dart';
import 'package:zwt_life_flutter_app/common/style/GlobalStringBase.dart';
import 'package:zwt_life_flutter_app/common/style/GlobalStyle.dart';
import 'package:zwt_life_flutter_app/common/utils/NavigatorUtils.dart';
import 'package:zwt_life_flutter_app/common/utils/util/screen_util.dart';
import 'package:zwt_life_flutter_app/widget/otherwidget/MyCupertinoDialog.dart';
import 'package:zwt_life_flutter_app/widget/otherwidget/MyRaisedButton.dart';

class CommonUtils {

  static double sStaticBarHeight = 0.0;

  static void initStatusBarHeight(context) async {
    sStaticBarHeight =
        await FlutterStatusbar.height / MediaQuery.of(context).devicePixelRatio;
  }



  static getLocalPath() async {
    Directory appDir;
    if (Platform.isIOS) {
      appDir = await getApplicationDocumentsDirectory();
    } else {
      appDir = await getExternalStorageDirectory();
    }
    String appDocPath = appDir.path + "/gsygithubappflutter";
    Directory appPath = Directory(appDocPath);
    await appPath.create(recursive: true);
    return appPath;
  }

  static saveImage(String url) async {
  }

  static splitFileNameByPath(String path) {
    return path.substring(path.lastIndexOf("/"));
  }


  static getThemeData(Color color) {
    return ThemeData(primarySwatch: color);
  }

  /**
   * 切换语言
   */
  static changeLocale(Store<GlobalState> store, int index) {
  }

  static GlobalStringBase getLocale(BuildContext context) {
    return GlobalLocalizations.of(context).currentLocalized;
  }

  static List<Color> getThemeListColor() {
    return [
      GlobalColors.primarySwatch,
      Colors.brown,
      Colors.blue,
      Colors.teal,
      Colors.amber,
      Colors.blueGrey,
      Colors.deepOrange,
    ];
  }

  static const IMAGE_END = [".png", ".jpg", ".jpeg", ".gif", ".svg"];

  static launchOutURL(String url, BuildContext context) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Fluttertoast.showToast(
          msg: CommonUtils.getLocale(context).option_web_launcher_error +
              ": " +
              url);
    }
  }

  static Future<Null> showTipDialog(BuildContext context,
      {title, content, cancleText, confirmText, canclePress, confirmPress}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) => new MyCupertinoDialog(
              title: title,
              content: content,
              cancleText: cancleText,
              confirmText: confirmText,
              confirmPress: confirmPress,
              canclePress: canclePress,
            ));
  }

  static Future<Null> showLoadingDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return new Material(
              color: Colors.transparent,
              child: WillPopScope(
                onWillPop: () => new Future.value(false),
                child: Center(
                  child: new Container(
                    width: 200.0,
                    height: 200.0,
                    padding: new EdgeInsets.all(4.0),
                    decoration: new BoxDecoration(
                      color: Colors.transparent,
                      //用一个BoxDecoration装饰器提供背景图片
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(
                            child: SpinKitCubeGrid(
                                color: Color(GlobalColors.white))),
                        new Container(height: 10.0),
                        new Container(
                            child: new Text(
                                CommonUtils.getLocale(context).loading_text,
                                style: GlobalConstant.normalTextWhite)),
                      ],
                    ),
                  ),
                ),
              ));
        });
  }

  static Future<Null> showCommitOptionDialog(
    BuildContext context,
    List<String> commitMaps,
    ValueChanged<int> onTap, {
    width = 250.0,
    height = 400.0,
    List<Color> colorList,
  }) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: new Container(
              width: width,
              height: height,
              padding: new EdgeInsets.all(4.0),
              margin: new EdgeInsets.all(20.0),
              decoration: new BoxDecoration(
                color: Color(GlobalColors.white),
                //用一个BoxDecoration装饰器提供背景图片
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              child: new ListView.builder(
                  itemCount: commitMaps.length,
                  itemBuilder: (context, index) {
                    return MyRaisedButton(
                      maxLines: 2,
                      mainAxisAlignment: MainAxisAlignment.start,
                      fontSize: 14.0,
                      color: colorList != null
                          ? colorList[index]
                          : Theme.of(context).primaryColor,
                      text: commitMaps[index],
                      textColor: Color(GlobalColors.white),
                      onPress: () {
                        Navigator.pop(context);
                        onTap(index);
                      },
                    );
                  }),
            ),
          );
        });
  }

  ///版本更新
  static Future<Null> showUpdateDialog(
      BuildContext context, String contentMsg) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(CommonUtils.getLocale(context).app_version_title),
            content: new Text(contentMsg),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: new Text(CommonUtils.getLocale(context).app_cancel)),
              new FlatButton(
                  onPressed: () {
//                    launch(Address.updateUrl);
                    Navigator.pop(context);
                  },
                  child: new Text(CommonUtils.getLocale(context).app_ok)),
            ],
          );
        });
  }

//选择喜好
  static Future<Null> showLickeDialog(BuildContext context,
      VoidCallback onPressedleft, VoidCallback onPressedright) {
    return showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return new Material(
              color: Colors.transparent,
              child: Center(
                child: new Container(
                  width: ScreenUtil.getInstance().L(250),
                  height: ScreenUtil.getInstance().L(200),
                  padding: new EdgeInsets.all(4.0),
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    //用一个BoxDecoration装饰器提供背景图片
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Container(child: Text("将根据喜好推荐相应小说")),
                      new Container(height: 10.0),
                      new Container(child: Text("请选择您的喜好")),
                      new Container(height: 10.0),
                      Image(
                        image: AssetImage("static/images/gender.png"),
                      ),
                      new Container(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FlatButton(
                            onPressed: onPressedleft,
                            color: Colors.blue[700],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            child: Text(
                              "男生小说",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Container(
                            width: 40.0,
                          ),
                          FlatButton(
                            color: Colors.pinkAccent,
                            onPressed: onPressedright,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            child: Text(
                              "女生小说",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
        });
  }

  static Widget headerCtreate(BuildContext context, RefreshStatus mode) {
    return new ClassicIndicator(
        mode: mode,
        releaseText: '释放刷新',
        refreshingText: '正在刷新...',
        completeText: '刷新完成',
        noDataText: '没有更多数据了',
        failedText: '刷新失败',
        idleText: '下拉刷新');
  }

  static Widget footerCreate(BuildContext context, RefreshStatus mode) {
    return new ClassicIndicator(
      mode: mode,
      refreshingText: '加载中...',
      idleIcon: const Icon(Icons.arrow_upward),
      idleText: '上拉加载更多...',
      noDataText: '我是有底线的...',
        noMoreIcon:Icon(Icons.airport_shuttle,color:Colors.grey),
    );
  }
}
