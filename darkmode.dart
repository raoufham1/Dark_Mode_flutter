import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/provider/brightness_provider.dart';
import 'package:quran/provider/saves_provider.dart';
import 'package:quran/provider/zoom_notifier.dart';
import 'package:quran/screens/home/widgets/note_snackbar.dart';
import 'package:quran/services/save_service.dart';
import '../../../constants.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:async';
import '../../../services/dark_mode.dart';
import '../widgets/page_position.dart';

List<double> invert = [
  //R  G   B    A  Const
  0, 0, 0, 0, 255, //
  0, -1, 0, 0, 255, //
  0, 0, -1, 0, 255, //
  0, 0, 0, 1, 0, //
];

class SinglePage extends StatefulWidget {
  final int index;
  final Function onTap;
  final Function onZoom;
  final Function onUnZoom;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const SinglePage(
      {@required this.index,
      this.scaffoldKey,
      this.onTap,
      this.onZoom,
      this.onUnZoom})
      : assert(index != null);

  @override
  _SinglePageState createState() => _SinglePageState();
}

class _SinglePageState extends State<SinglePage> with TickerProviderStateMixin {
  // bool _showMenu = false;
  List<int> saves = <int>[];
  TransformationController _transformationController =
      TransformationController();
  ScrollController _scrollController = ScrollController();
  // bool isZoomed = false;
  void initSaves() async {
    saves = await SaveService.instance.getSaves();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    initSaves();
    _transformationController.addListener(() {
      widget.onZoom();

      if (isZoomed(_transformationController.value) !=
          Provider.of<ZoomNotifier>(context, listen: false).isZoomed) {
        Provider.of<ZoomNotifier>(context, listen: false)
            .setZoomed(isZoomed(_transformationController.value));
      }
    });
    // _scrollController.addListener(() {});
  }

  Widget _buildSoemthing(BuildContext context) {
    return Consumer<BrightnessProvider>(builder: (context, s, child) {
      return ColorFiltered(
        colorFilter: ColorFilter.mode(
            Color.fromARGB(
                (255 *
                        (1 -
                            Provider.of<BrightnessProvider>(context,
                                    listen: false)
                                .opacity))
                    .toInt(),
                0,
                0,
                0),
            BlendMode.darken),
        child: Container(
          height: MediaQuery.of(context).orientation == Orientation.landscape
              ? MediaQuery.of(context).size.width * 1.5
              : MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: DarkMode.isEnable
              ? ColorFiltered(
                  child: ColorFiltered(
                    
                    child: Image.asset(
                      '$path${widget.index.toString()}.jpg',
                      fit: BoxFit.fill,
                    ),
                    colorFilter: ColorFilter.matrix(
                      [
                        //R  G   B    A  Const
                        -1, 0, 0, 0, 190, //
                        0, -1, 0, 0, 255, //
                        0, 0, -1, 0, 255, //
                        0, 0, 0, 1, 0, //
                      ],
                    ),
                  ),
                  colorFilter: ColorFilter.mode(
                    Colors.white,
                    BlendMode.overlay,
                  ),
                )
              : Container(
                  child: Image.asset(
                    '$path${widget.index.toString()}.jpg',
                    fit: BoxFit.fill,
                  ),
                ),
        ),
      );
    });
  }

  Widget _buildLayout(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.portrait) {
        return InteractiveViewer(
            minScale: 1,
            maxScale: 2.5,
            transformationController: _transformationController,
            child: DoubleTapDetails(
              child: _buildSoemthing(context),
              onTapUp: (details) {
                widget.onTap();
              },
              onDoubleTap: (TapDownDetails details) {
                widget.onZoom();
                if (!Provider.of<ZoomNotifier>(context, listen: false)
                    .isZoomed) {
                  _transformationController.value = zoomMatrix(
                      2.5, details.localPosition.dx, details.localPosition.dy);
                } else {
                  _transformationController.value = unzoomMatrix();
                  widget.onUnZoom();
                }
              },
            ));
      }

      return SingleChildScrollView(
        controller: _scrollController,
        child: Consumer<BrightnessProvider>(
          builder: (context, s, child) => InkWell(
            onTap: () {
              widget.onTap();
            },
            child: _buildSoemthing(context),
          ),
        ),
      );
    });
  }

//     ))
  // Widget _builLayout(BuildContext context) {
  //   return OrientationBuilder(
  //     builder: (context, orientation) {
  //       if (orientation == Orientation.portrait) {
  //         return SizedBox.expand(
  //           child: Image.asset(path + '${widget.index.toString()}' + '.jpg',
  //               fit: BoxFit.fill),
  //         );
  //       } else {
  //         return SingleChildScrollView(
  //           child: Column(
  //             children: <Widget>[
  //               Image.asset(path + '${widget.index.toString()}' + '.jpg',
  //                   fit: BoxFit.fill),
  //             ],
  //           ),
  //         );
  //       }
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Material(
        child: Stack(
          children: <Widget>[
            //show or hide menu
            // InkWell(
            //   splashColor: Color.fromARGB(0, 0, 0, 0),
            //   // onTap: () {
            //   //   setState(() {
            //   //     _showMenu = !_showMenu;
            //   //     SinglePage.showDrawer = false;
            //   //   });
            //   // showDialog(context: context, builder: (context) => BrightnessSlider());
            //   // },
            //   child:

            _buildLayout(context),

            // child: InteractiveViewer(

            //     minScale: 1,
            //     maxScale: 2.5,
            //     transformationController: _transformationController,
            //     child: DoubleTapDetails(
            //          child: _buildLayout(context),
            //       onTap: (details){
            //       setState(() {
            //     _showMenu = !_showMenu;
            //     SinglePage.showDrawer = false;
            //     print("TAP !!!!");

            //   });
            //     },
            //       onDoubleTap: (TapDownDetails details) {
            //         print(isZoomed( _transformationController.value));
            //         if (!Provider.of<ZoomNotifier>(context, listen: false).isZoomed) {
            //           _transformationController.value =
            //           zoomMatrix(2.5, details.localPosition.dx, details.localPosition.dy);
            //         } else {
            //           _transformationController.value = unzoomMatrix();

            //         }
            //       },
            //     )),
            // ),
            // _showMenu ? BottomMenu(index: widget.index) : Container(),
            // _showMenu
            //     ? TopMenu(
            //         index: widget.index.toString(),
            //         callBack: () {
            //           setState(() {
            //             SinglePage.showDrawer = !SinglePage.showDrawer;
            //           });
            //         })
            //     : Container(),
            // Drawer menu
            // HomePage.showDrawer
            //     ? DrawerMenu(
            //         index: widget.index,
            //         scaffoldKey: widget.scaffoldKey,
            //       )
            //     : Container(),
            //show snackbar if the page content a note
            NoteSnackbar(index: widget.index),

            PagePosition(index: widget.index),
            //shwo Alama of save
            Consumer<SavesProvider>(
              builder: (context, savesProvider, _) {
                if (savesProvider.marks.contains(widget.index)) {
                  return Positioned(
                    top: 0.0,
                    left: 8.0,
                    child: Image.asset(images + "alama.png",
                        height: 48.0, width: 24, fit: BoxFit.fill),
                  );
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}

bool isZoomed(Matrix4 matrix) {
  for (var i = 0; i < 4; i++) {
    if (matrix.entry(i, i) != 1.0) {
      return true;
    }
  }
  return false;
}

Matrix4 zoomMatrix(double zoom, double x, double y) {
  var m = Matrix4.identity();
  m.setDiagonal(vector.Vector4(zoom, zoom, zoom, 1));
  m.setEntry(0, 3, -(zoom - 1) * x);
  m.setEntry(1, 3, -(zoom - 1) * y);
  return m;
}

Matrix4 unzoomMatrix() {
  return Matrix4.identity();
}

typedef TapFunction = void Function(TapDownDetails);

class DoubleTapDetails extends StatelessWidget {
  Widget child;
  TapFunction onDoubleTap;
  TapFunction onTap;
  GestureTapUpCallback onTapUp;
  DoubleTapDetails({this.child, this.onDoubleTap, this.onTap, this.onTapUp});
  bool _tappedOnce = false;
  Timer _timer;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      onTapUp: onTapUp,
      onTapDown: (details) {
        if (!_tappedOnce) {
          _tappedOnce = true;
          _timer = Timer(Duration(milliseconds: 200), () {
            _tappedOnce = false;
          });
        } else {
          _timer.cancel();
          _tappedOnce = false;
          onDoubleTap(details);
        }
      },
    );
  }
}
