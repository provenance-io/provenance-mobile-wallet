import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tech_wallet/common/fw_design.dart';
import 'package:flutter_tech_wallet/dialogs/error_dialog.dart';

class ValidatePin extends StatefulHookWidget {
  final List<int>? code;

  ValidatePin({this.code});

  @override
  State<StatefulWidget> createState() {
    return ValidatePinState();
  }
}

class ValidatePinState extends State<ValidatePin> {
  var _currentCodeLength = 0;
  var _inputCodes = <int>[];
  var _currentState = 0;

  _deleteCode() {
    setState(() {
      if (_currentCodeLength > 0) {
        _currentState = 0;
        _currentCodeLength--;
        _inputCodes.removeAt(_currentCodeLength);
      }
    });
  }

  _deleteAllCode() {
    setState(() {
      if (_currentCodeLength > 0) {
        _currentState = 0;
        _currentCodeLength = 0;
        _inputCodes.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountNameProvider = useTextEditingController();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: IconButton(
            icon: FwIcon(
              FwIcons.back,
              size: 24,
              color: Color(0xFF3D4151),
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ),
        body: Container(
            color: Colors.white,
            child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FwText(
                            'Enter your pin code',
                            style: FwTextStyle.extraLarge,
                            textAlign: TextAlign.left,
                            color: FwColor.globalNeutral550,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: CodePanel(
                          codeLength: 6,
                          currentLength: _currentCodeLength,
                          status: _currentState,
                          deleteCode: _deleteCode,
                          borderColor:
                              Theme.of(context).colorScheme.globalNeutral550,
                        )),
                    SizedBox(
                      height: 60,
                    ),
                    Expanded(
                      flex: Platform.isIOS ? 5 : 6,
                      child: Container(
                        padding: EdgeInsets.only(left: 20, right: 20, top: 0),
                        child: NotificationListener<
                            OverscrollIndicatorNotification>(
                          onNotification: (overscroll) {
                            overscroll.disallowGlow();
                            return true;
                          },
                          child: GridView.count(
                            crossAxisCount: 3,
                            childAspectRatio: 1.6,
                            mainAxisSpacing: 35,
                            padding: EdgeInsets.all(8),
                            children: <Widget>[
                              buildContainerCircle(1),
                              buildContainerCircle(2),
                              buildContainerCircle(3),
                              buildContainerCircle(4),
                              buildContainerCircle(5),
                              buildContainerCircle(6),
                              buildContainerCircle(7),
                              buildContainerCircle(8),
                              buildContainerCircle(9),
                              // buildRemoveIcon(Icons.close),
                              Container(),
                              buildContainerCircle(0),
                              buildContainerIcon(Icons.arrow_back),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    SizedBox(
                      height: 40,
                    )
                  ],
                ))));
  }

  Widget buildContainerCircle(int number) {
    return InkResponse(
      highlightColor: Colors.red,
      onTap: () {
        _onCodeClick(number);
      },
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          // shape: BoxShape.circle,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black12,
          //     blurRadius: 10,
          //     spreadRadius: 0,
          //   )
          // ]
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).colorScheme.globalNeutral550),
          ),
        ),
      ),
    );
  }

  Widget buildRemoveIcon(IconData icon) {
    return InkResponse(
      onTap: () {
        if (0 < _currentCodeLength) {
          _deleteAllCode();
        }
      },
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          // shape: BoxShape.circle,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black12,
          //     blurRadius: 10,
          //     spreadRadius: 0,
          //   )
          // ]
        ),
        child: Center(
          child: Icon(
            icon,
            size: 30,
            color: Theme.of(context).colorScheme.globalNeutral550,
          ),
        ),
      ),
    );
  }

  _onCodeClick(int code) async {
    if (_currentCodeLength < 6) {
      setState(() {
        _currentCodeLength++;
        _inputCodes.add(code);
      });

      if (_currentCodeLength == 6) {
        Function eq = const ListEquality().equals;
        if (!eq(_inputCodes, widget.code)) {
          await showDialog(
              context: context,
              builder: (context) => ErrorDialog(
                    error: "Your pin doesn't match.",
                  ));
        } else {
          Navigator.of(context).pop(true);
        }
      }
    }
  }

  Color circleColor = Colors.white;

  Widget buildContainerIcon(IconData icon) {
    return InkResponse(
      onTap: () {
        if (0 < _currentCodeLength) {
          setState(() {
            circleColor = Colors.grey.shade300;
          });
          Future.delayed(Duration(milliseconds: 200)).then((func) {
            setState(() {
              circleColor = Colors.white;
            });
          });
        }
        _deleteCode();
      },
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: circleColor,
          // shape: BoxShape.circle,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black12,
          //     blurRadius: 10,
          //     spreadRadius: 0,
          //   )
          // ]
        ),
        child: Center(
          child: Icon(
            icon,
            size: 30,
            color: Theme.of(context).colorScheme.globalNeutral550,
          ),
        ),
      ),
    );
  }
}

class _TextFormField extends StatelessWidget {
  const _TextFormField(
      {Key? key,
      required this.label,
      this.keyboardType,
      this.onChanged,
      this.validator,
      this.controller})
      : super(key: key);

  final String label;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FwText(label),
        const VerticalSpacer.small(),
        TextFormField(
          keyboardType: keyboardType,
          autocorrect: false,
          controller: controller,
          onChanged: onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.midGrey),
            ),
          ),
        ),
      ],
    );
  }
}

typedef void DeleteCode();
typedef Future<bool> PassCodeVerify(List<int> passcode);

// class LockScreen extends StatefulWidget {
//   /// Password on success method
//   final VoidCallback onSuccess;
//
//   /// Password finger function for auth
//   final VoidCallback? fingerFunction;
//
//   /// Password finger verify for auth
//   final bool? fingerVerify;
//
//   /// screen title
//   final String title;
//
//   /// Pass length
//   final int passLength;
//
//   /// Wrong password dialog
//   final bool? showWrongPassDialog;
//
//   /// Showing finger print area
//   final bool? showFingerPass;
//
//   /// Wrong password dialog title
//   final String? wrongPassTitle;
//
//   /// Wrong password dialog content
//   final String? wrongPassContent;
//
//   /// Wrong password dialog button text
//   final String? wrongPassCancelButtonText;
//
//   /// Background image
//   final String? bgImage;
//
//   /// Color for numbers
//   final Color? numColor;
//
//   /// Finger print image
//   final Widget? fingerPrintImage;
//
//   /// border color
//   final Color? borderColor;
//
//   /// foreground color
//   final Color? foregroundColor;
//
//   /// Password verify
//   final PassCodeVerify passCodeVerify;
//
//   /// Lock Screen constructer
//   LockScreen({
//     required this.onSuccess,
//     required this.title,
//     this.borderColor,
//     this.foregroundColor = Colors.transparent,
//     required this.passLength,
//     required this.passCodeVerify,
//     this.fingerFunction,
//     this.fingerVerify = false,
//     this.showFingerPass = false,
//     this.bgImage,
//     this.numColor = Colors.black,
//     this.fingerPrintImage,
//     this.showWrongPassDialog = false,
//     this.wrongPassTitle,
//     this.wrongPassContent,
//     this.wrongPassCancelButtonText,
//   })  : assert(passLength <= 8),
//         assert(bgImage != null),
//         assert(borderColor != null),
//         assert(foregroundColor != null);
//
//   @override
//   _LockScreenState createState() => _LockScreenState();
// }
//
// class _LockScreenState extends State<LockScreen> {
//   var _currentCodeLength = 0;
//   var _inputCodes = <int>[];
//   var _currentState = 0;
//   Color circleColor = Colors.white;
//
//   _onCodeClick(int code) {
//     if (_currentCodeLength < widget.passLength) {
//       setState(() {
//         _currentCodeLength++;
//         _inputCodes.add(code);
//       });
//
//       if (_currentCodeLength == widget.passLength) {
//         widget.passCodeVerify(_inputCodes).then((onValue) {
//           if (onValue) {
//             setState(() {
//               _currentState = 1;
//             });
//             widget.onSuccess();
//           } else {
//             _currentState = 2;
//             new Timer(new Duration(milliseconds: 1000), () {
//               setState(() {
//                 _currentState = 0;
//                 _currentCodeLength = 0;
//                 _inputCodes.clear();
//               });
//             });
//             if (widget.showWrongPassDialog!) {
//               showDialog(
//                   barrierDismissible: false,
//                   context: context,
//                   builder: (BuildContext context) {
//                     return Center(
//                       child: AlertDialog(
//                         title: Text(
//                           widget.wrongPassTitle!,
//                           style: TextStyle(fontFamily: "Open Sans"),
//                         ),
//                         content: Text(
//                           widget.wrongPassContent!,
//                           style: TextStyle(fontFamily: "Open Sans"),
//                         ),
//                         actions: <Widget>[
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: Text(
//                               widget.wrongPassCancelButtonText!,
//                               style: TextStyle(color: Colors.blue),
//                             ),
//                           )
//                         ],
//                       ),
//                     );
//                   });
//             }
//           }
//         });
//       }
//     }
//   }
//
//   _fingerPrint() {
//     if (widget.fingerVerify!) {
//       widget.onSuccess();
//     }
//   }
//
//   _deleteCode() {
//     setState(() {
//       if (_currentCodeLength > 0) {
//         _currentState = 0;
//         _currentCodeLength--;
//         _inputCodes.removeAt(_currentCodeLength);
//       }
//     });
//   }
//
//   _deleteAllCode() {
//     setState(() {
//       if (_currentCodeLength > 0) {
//         _currentState = 0;
//         _currentCodeLength = 0;
//         _inputCodes.clear();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Future.delayed(Duration(milliseconds: 200), () {
//       _fingerPrint();
//     });
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: <Widget>[
//           Container(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Expanded(
//                   flex: 3,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                     ),
//                     child: Stack(
//                       children: <Widget>[
//                         ClipPath(
//                           clipper: BgClipper(),
//                           child: Container(
//                             height: MediaQuery.of(context).size.height,
//                             width: MediaQuery.of(context).size.width,
//                             decoration: BoxDecoration(
//                               image: DecorationImage(
//                                 image: AssetImage(widget.bgImage!),
//                                 fit: BoxFit.cover,
//                                 colorFilter: ColorFilter.mode(
//                                   Colors.grey.shade800,
//                                   BlendMode.hardLight,
//                                 ),
//                               ),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: <Widget>[
//                                 SizedBox(
//                                   height: Platform.isIOS ? 60 : 40,
//                                 ),
//                                 Text(
//                                   widget.title,
//                                   style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       fontFamily: "Open Sans"),
//                                 ),
//                                 SizedBox(
//                                   height: Platform.isIOS ? 50 : 30,
//                                 ),
//                                 CodePanel(
//                                   codeLength: widget.passLength,
//                                   currentLength: _currentCodeLength,
//                                   borderColor: widget.borderColor,
//                                   foregroundColor: widget.foregroundColor,
//                                   deleteCode: _deleteCode,
//                                   fingerVerify: widget.fingerVerify!,
//                                   status: _currentState,
//                                 ),
//                                 SizedBox(
//                                   height: Platform.isIOS ? 30 : 15,
//                                 ),
//                                 Text(
//                                   "TYPE PASSCODE",
//                                   style: TextStyle(
//                                       color: Colors.white70.withOpacity(0.3),
//                                       fontSize: 18,
//                                       fontFamily: "Open Sans"),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         widget.showFingerPass!
//                             ? Positioned(
//                                 top: MediaQuery.of(context).size.height /
//                                     (Platform.isIOS ? 4 : 5),
//                                 left: 20,
//                                 bottom: 10,
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     widget.fingerFunction!();
//                                   },
//                                   child: widget.fingerPrintImage!,
//                                 ),
//                               )
//                             : Container(),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: Platform.isIOS ? 5 : 6,
//                   child: Container(
//                     padding: EdgeInsets.only(left: 0, top: 0),
//                     child:
//                         NotificationListener<OverscrollIndicatorNotification>(
//                       onNotification: (overscroll) {
//                         overscroll.disallowGlow();
//                         return true;
//                       },
//                       child: GridView.count(
//                         crossAxisCount: 3,
//                         childAspectRatio: 1.6,
//                         mainAxisSpacing: 35,
//                         padding: EdgeInsets.all(8),
//                         children: <Widget>[
//                           buildContainerCircle(1),
//                           buildContainerCircle(2),
//                           buildContainerCircle(3),
//                           buildContainerCircle(4),
//                           buildContainerCircle(5),
//                           buildContainerCircle(6),
//                           buildContainerCircle(7),
//                           buildContainerCircle(8),
//                           buildContainerCircle(9),
//                           buildRemoveIcon(Icons.close),
//                           buildContainerCircle(0),
//                           buildContainerIcon(Icons.arrow_back),
//                         ],
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildContainerCircle(int number) {
//     return InkResponse(
//       highlightColor: Colors.red,
//       onTap: () {
//         _onCodeClick(number);
//       },
//       child: Container(
//         height: 50,
//         width: 50,
//         decoration: BoxDecoration(
//             color: Colors.white,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black12,
//                 blurRadius: 10,
//                 spreadRadius: 0,
//               )
//             ]),
//         child: Center(
//           child: Text(
//             number.toString(),
//             style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.normal,
//                 color: widget.numColor),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildRemoveIcon(IconData icon) {
//     return InkResponse(
//       onTap: () {
//         if (0 < _currentCodeLength) {
//           _deleteAllCode();
//         }
//       },
//       child: Container(
//         height: 50,
//         width: 50,
//         decoration: BoxDecoration(
//             color: Colors.white,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black12,
//                 blurRadius: 10,
//                 spreadRadius: 0,
//               )
//             ]),
//         child: Center(
//           child: Icon(
//             icon,
//             size: 30,
//             color: widget.numColor,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildContainerIcon(IconData icon) {
//     return InkResponse(
//       onTap: () {
//         if (0 < _currentCodeLength) {
//           setState(() {
//             circleColor = Colors.grey.shade300;
//           });
//           Future.delayed(Duration(milliseconds: 200)).then((func) {
//             setState(() {
//               circleColor = Colors.white;
//             });
//           });
//         }
//         _deleteCode();
//       },
//       child: Container(
//         height: 50,
//         width: 50,
//         decoration: BoxDecoration(
//             color: circleColor,
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black12,
//                 blurRadius: 10,
//                 spreadRadius: 0,
//               )
//             ]),
//         child: Center(
//           child: Icon(
//             icon,
//             size: 30,
//             color: widget.numColor,
//           ),
//         ),
//       ),
//     );
//   }
// }

class CodePanel extends StatelessWidget {
  final codeLength;
  final currentLength;
  final borderColor;
  final bool? fingerVerify;
  final foregroundColor;
  final H = 16.0;
  final W = 16.0;
  final DeleteCode? deleteCode;
  final int? status;
  CodePanel(
      {this.codeLength,
      this.currentLength,
      this.borderColor,
      this.foregroundColor,
      this.deleteCode,
      this.fingerVerify,
      this.status})
      : assert(codeLength > 0),
        assert(currentLength >= 0),
        assert(currentLength <= codeLength),
        assert(deleteCode != null),
        assert(status == 0 || status == 1 || status == 2);

  @override
  Widget build(BuildContext context) {
    var circles = <Widget>[];
    var color = borderColor;
    int circlePice = 1;

    if (fingerVerify == true) {
      do {
        circles.add(
          SizedBox(
            width: W,
            height: H,
            child: new Container(
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                border: new Border.all(color: color, width: 1.0),
                color: Colors.green.shade500,
              ),
            ),
          ),
        );
        circlePice++;
      } while (circlePice <= codeLength);
    } else {
      if (status == 1) {
        color = Colors.green.shade500;
      }
      if (status == 2) {
        color = Colors.red.shade500;
      }
      for (int i = 1; i <= codeLength; i++) {
        if (i > currentLength) {
          circles.add(SizedBox(
              width: W,
              height: H,
              child: Container(
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    border: new Border.all(color: color, width: 1.0),
                    color: foregroundColor),
              )));
        } else {
          circles.add(new SizedBox(
              width: W,
              height: H,
              child: new Container(
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  border: new Border.all(color: color, width: 1.0),
                  color: color,
                ),
              )));
        }
      }
    }

    return new SizedBox.fromSize(
      size: new Size(MediaQuery.of(context).size.width, 30.0),
      child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox.fromSize(
                size: new Size(30.0 * codeLength, H),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: circles,
                )),
          ]),
    );
  }
}
//
// class BgClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.lineTo(0, size.height);
//     path.lineTo(size.width, size.height / 1.5);
//     path.lineTo(size.width, 0);
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) {
//     return false;
//   }
// }
